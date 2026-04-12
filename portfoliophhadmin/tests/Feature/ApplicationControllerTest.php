<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Job;
use App\Models\Application;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ApplicationControllerTest extends TestCase
{
    use RefreshDatabase;

    // ─────────────────────────────────────────────────────────────────────────
    // List Tests (GET /api/applications)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Test retrieve applications list (paginated)
     * 
     * Verifies:
     * - Status 200
     * - Returns paginated applications
     * - Only includes own applications (for job seekers)
     */
    public function test_list_applications_successfully(): void
    {
        $jobSeeker = User::factory()->create(['role' => 'job_seeker']);
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        
        // Create multiple jobs and applications to avoid UNIQUE constraint violation
        $jobs = Job::factory()->count(3)->create(['recruiter_id' => $recruiter->id]);
        
        $applications = [];
        foreach ($jobs as $job) {
            $applications[] = Application::factory()->create([
                'user_id' => $jobSeeker->id,
                'job_id' => $job->id,
            ]);
        }

        $token = $jobSeeker->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/applications');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'user_id',
                        'job_id',
                        'status',
                    ],
                ],
            ])
            ->assertJsonCount(3, 'data');
    }

    /**
     * Test list applications without authentication fails
     * 
     * Verifies:
     * - Status 401
     * - Requires token
     */
    public function test_list_applications_without_auth_fails(): void
    {
        $response = $this->getJson('/api/applications');

        $response->assertStatus(401)
            ->assertJsonPath('success', false);
    }

    /**
     * Test job seeker sees only own applications
     * 
     * Verifies:
     * - Job seeker 1 only sees own applications
     * - Does not see job seeker 2's applications
     */
    public function test_job_seeker_sees_only_own_applications(): void
    {
        $jobSeeker1 = User::factory()->create(['role' => 'job_seeker']);
        $jobSeeker2 = User::factory()->create(['role' => 'job_seeker']);
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        
        // Create 3 jobs to avoid UNIQUE constraint violation
        $jobs = Job::factory()->count(3)->create(['recruiter_id' => $recruiter->id]);

        // Job seeker 1 applies to job 1
        Application::factory()->create([
            'user_id' => $jobSeeker1->id,
            'job_id' => $jobs[0]->id,
        ]);
        
        // Job seeker 2 applies to jobs 2 and 3
        Application::factory()->create([
            'user_id' => $jobSeeker2->id,
            'job_id' => $jobs[1]->id,
        ]);
        
        Application::factory()->create([
            'user_id' => $jobSeeker2->id,
            'job_id' => $jobs[2]->id,
        ]);

        $token = $jobSeeker1->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/applications');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.user_id', $jobSeeker1->id);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Show Tests (GET /api/applications/{id})
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Test show application
     * 
     * Verifies:
     * - Status 200
     * - Full application details returned
     */
    public function test_show_application_successfully(): void
    {
        $jobSeeker = User::factory()->create();
        $recruiter = User::factory()->create();
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id]);
        $application = Application::factory()->create([
            'user_id' => $jobSeeker->id,
            'job_id' => $job->id,
        ]);

        $token = $jobSeeker->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson("/api/applications/{$application->id}");

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'id',
                    'job_id',
                    'user_id',
                    'status',
                    'cover_letter',
                ],
            ])
            ->assertJson([
                'data' => [
                    'id' => $application->id,
                    'job_id' => $job->id,
                ],
            ]);
    }

    /**
     * Test show application from another user fails (authorization)
     * 
     * Verifies:
     * - Status 403
     * - Users can only view own applications
     */
    public function test_show_others_application_fails(): void
    {
        $jobSeeker1 = User::factory()->create();
        $jobSeeker2 = User::factory()->create();
        $recruiter = User::factory()->create();
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id]);
        $application = Application::factory()->create([
            'user_id' => $jobSeeker1->id,
            'job_id' => $job->id,
        ]);

        $token = $jobSeeker2->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson("/api/applications/{$application->id}");

        $response->assertStatus(403)
            ->assertJsonPath('success', false);
    }

    /**
     * Test show non-existent application returns 404
     * 
     * Verifies:
     * - Status 404
     */
    public function test_show_nonexistent_application_returns_404(): void
    {
        $jobSeeker = User::factory()->create();
        $token = $jobSeeker->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson("/api/applications/99999");

        $response->assertStatus(404);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Create Tests (POST /api/applications)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Test create application successfully
     * 
     * Verifies:
     * - Status 201
     * - Application created in database
     * - Status defaults to pending
     */
    public function test_create_application_successfully(): void
    {
        $jobSeeker = User::factory()->create(['role' => 'job_seeker']);
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id, 'status' => 'approved']);

        $token = $jobSeeker->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/applications', [
                'job_id' => $job->id,
                'cover_letter' => 'I am very interested in this position. I have 5+ years of experience.',
            ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'id',
                    'job_id',
                    'user_id',
                    'status',
                ],
            ])
            ->assertJson([
                'data' => [
                    'job_id' => $job->id,
                    'user_id' => $jobSeeker->id,
                    'status' => 'pending',
                ],
            ]);

        $this->assertDatabaseHas('applications', [
            'job_id' => $job->id,
            'user_id' => $jobSeeker->id,
            'status' => 'pending',
        ]);
    }

    /**
     * Test create application with optional cover letter
     * 
     * Verifies:
     * - Cover letter is optional
     */
    public function test_create_application_without_cover_letter_succeeds(): void
    {
        $jobSeeker = User::factory()->create();
        $recruiter = User::factory()->create();
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id, 'status' => 'approved']);

        $token = $jobSeeker->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/applications', [
                'job_id' => $job->id,
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'data' => [
                    'job_id' => $job->id,
                ],
            ]);
    }

    /**
     * Test create application without authentication fails
     * 
     * Verifies:
     * - Status 401
     * - Requires token
     */
    public function test_create_application_without_auth_fails(): void
    {
        $recruiter = User::factory()->create();
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id]);

        $response = $this->postJson('/api/applications', [
            'job_id' => $job->id,
        ]);

        $response->assertStatus(401)
            ->assertJsonPath('success', false);
    }

    /**
     * Test create application as non-job-seeker fails
     *
     * Verifies:
     * - Status 403
     * - Clear role restriction message
     */
    public function test_create_application_as_recruiter_fails(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $jobOwner = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['recruiter_id' => $jobOwner->id, 'status' => 'approved']);

        $token = $recruiter->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/applications', [
                'job_id' => $job->id,
                'cover_letter' => 'Trying to apply as recruiter',
            ]);

        $response->assertStatus(403)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Only job seekers can apply for jobs.');
    }

    /**
     * Test create application for non-existent job fails
     * 
     * Verifies:
     * - Status 422
     * - Job validation
     */
    public function test_create_application_for_nonexistent_job_fails(): void
    {
        $jobSeeker = User::factory()->create();
        $token = $jobSeeker->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/applications', [
                'job_id' => 99999,
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('errors.job_id.0', 'Job not found');
    }

    /**
     * Test create duplicate application fails
     * 
     * Verifies:
     * - User cannot apply to same job twice
     */
    public function test_create_duplicate_application_fails(): void
    {
        $jobSeeker = User::factory()->create();
        $recruiter = User::factory()->create();
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id]);
        
        // First application
        Application::factory()->create([
            'user_id' => $jobSeeker->id,
            'job_id' => $job->id,
        ]);

        $token = $jobSeeker->createToken('api-token')->plainTextToken;
        // Try duplicate
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/applications', [
                'job_id' => $job->id,
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('errors.job_id', ['You have already applied to this job.']);
    }

    /**
     * Test create application with missing job_id fails
     * 
     * Verifies:
     * - Status 422
     * - Job ID required
     */
    public function test_create_application_with_missing_job_id_fails(): void
    {
        $jobSeeker = User::factory()->create();
        $token = $jobSeeker->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/applications', [
                'cover_letter' => 'Some cover letter',
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('errors.job_id.0', 'Job is required');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Update Status Tests (PUT /api/applications/{id}/status)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Test update application status as recruiter successfully
     * 
     * Verifies:
     * - Status 200
     * - Application status updated
     * - Only recruiter of the job can update status
     */
    public function test_update_application_status_as_recruiter_successfully(): void
    {
        $jobSeeker = User::factory()->create();
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id]);
        $application = Application::factory()->create([
            'user_id' => $jobSeeker->id,
            'job_id' => $job->id,
            'status' => 'pending',
        ]);

        $token = $recruiter->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->putJson("/api/applications/{$application->id}/status", [
                'status' => 'accepted',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'data' => [
                    'status' => 'accepted',
                ],
            ]);

        $this->assertDatabaseHas('applications', [
            'id' => $application->id,
            'status' => 'accepted',
        ]);
    }

    /**
     * Test update application status with invalid status fails
     * 
     * Verifies:
     * - Status must be valid enum value
     */
    public function test_update_application_status_with_invalid_status_fails(): void
    {
        $jobSeeker = User::factory()->create();
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id]);
        $application = Application::factory()->create([
            'user_id' => $jobSeeker->id,
            'job_id' => $job->id,
        ]);

        $token = $recruiter->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->putJson("/api/applications/{$application->id}/status", [
                'status' => 'invalid_status',
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('errors.status.0', 'Invalid status');
    }

    /**
     * Test update application status as job seeker fails (authorization)
     * 
     * Verifies:
     * - Status 403
     * - Only recruiter can update status
     */
    public function test_update_application_status_as_job_seeker_fails(): void
    {
        $jobSeeker = User::factory()->create(['role' => 'job_seeker']);
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id]);
        $application = Application::factory()->create([
            'user_id' => $jobSeeker->id,
            'job_id' => $job->id,
        ]);

        $token = $jobSeeker->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->putJson("/api/applications/{$application->id}/status", [
                'status' => 'accepted',
            ]);

        $response->assertStatus(403)
            ->assertJsonPath('success', false);
    }

    /**
     * Test update application status for job from another recruiter fails
     * 
     * Verifies:
     * - Status 403
     * - Only recruiter who posted job can update application
     */
    public function test_update_others_application_status_fails(): void
    {
        $jobSeeker = User::factory()->create();
        $recruiter1 = User::factory()->create(['role' => 'recruiter']);
        $recruiter2 = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['recruiter_id' => $recruiter1->id]);
        $application = Application::factory()->create([
            'user_id' => $jobSeeker->id,
            'job_id' => $job->id,
        ]);

        $token = $recruiter2->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->putJson("/api/applications/{$application->id}/status", [
                'status' => 'accepted',
            ]);

        $response->assertStatus(403)
            ->assertJsonPath('success', false);
    }

    /**
     * Test update non-existent application returns 404
     * 
     * Verifies:
     * - Status 404
     */
    public function test_update_nonexistent_application_status_returns_404(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $token = $recruiter->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->putJson("/api/applications/99999/status", [
                'status' => 'accepted',
            ]);

        $response->assertStatus(404);
    }

    /**
     * Test update application without authentication fails
     * 
     * Verifies:
     * - Status 401
     * - Requires token
     */
    public function test_update_application_status_without_auth_fails(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id]);
        $application = Application::factory()->create(['job_id' => $job->id]);

        $response = $this->putJson("/api/applications/{$application->id}/status", [
            'status' => 'accepted',
        ]);

        $response->assertStatus(401)
            ->assertJsonPath('success', false);
    }
}
