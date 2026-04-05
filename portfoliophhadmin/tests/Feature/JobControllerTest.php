<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Job;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class JobControllerTest extends TestCase
{
    use RefreshDatabase;

    // ─────────────────────────────────────────────────────────────────────────
    // List Tests (GET /api/jobs)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Test retrieve jobs list with pagination
     * 
     * Verifies:
     * - Status 200
     * - Paginated response structure
     * - Only approved jobs shown
     * - Returns recruiter relationship (eager loaded)
     */
    public function test_list_jobs_successfully(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $jobs = Job::factory()->count(5)->create([
            'recruiter_id' => $recruiter->id,
            'status' => 'approved',
        ]);

        $response = $this->getJson('/api/jobs');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'title',
                        'description',
                        'location',
                        'recruiter' => [
                            'id',
                            'name',
                            'email',
                        ],
                    ],
                ],
            ])
            ->assertJsonCount(5, 'data');
    }

    /**
     * Test jobs list pagination
     * 
     * Verifies:
     * - Per-page parameter limits results
     * - Next page offset works
     */
    public function test_list_jobs_with_pagination(): void
    {
        $recruiter = User::factory()->create();
        Job::factory()->count(20)->create([
            'recruiter_id' => $recruiter->id,
            'status' => 'approved',
        ]);

        $response = $this->getJson('/api/jobs?page=1&per_page=10');

        $response->assertStatus(200)
            ->assertJsonCount(10, 'data');

        // Second page
        $response2 = $this->getJson('/api/jobs?page=2&per_page=10');
        $response2->assertStatus(200)
            ->assertJsonCount(10, 'data');
    }

    /**
     * Test jobs list only shows approved jobs
     * 
     * Verifies:
     * - Draft/pending jobs excluded
     */
    public function test_list_jobs_excludes_unapproved_jobs(): void
    {
        $recruiter = User::factory()->create();
        Job::factory()->create(['recruiter_id' => $recruiter->id, 'status' => 'approved']);
        Job::factory()->create(['recruiter_id' => $recruiter->id, 'status' => 'draft']);
        Job::factory()->create(['recruiter_id' => $recruiter->id, 'status' => 'pending']);

        $response = $this->getJson('/api/jobs');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data');
    }

    /**
     * Test list jobs without authentication
     * 
     * Verifies:
     * - Public endpoint, returns 200
     */
    public function test_list_jobs_without_auth_succeeds(): void
    {
        $recruiter = User::factory()->create();
        Job::factory()->create(['recruiter_id' => $recruiter->id, 'status' => 'approved']);

        $response = $this->getJson('/api/jobs');

        $response->assertStatus(200);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Show Tests (GET /api/jobs/{id})
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Test retrieve single job
     * 
     * Verifies:
     * - Status 200
     * - Full job details returned
     * - Recruiter relationship included
     */
    public function test_show_job_successfully(): void
    {
        $recruiter = User::factory()->create();
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id]);

        $response = $this->getJson("/api/jobs/{$job->id}");

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'id',
                    'title',
                    'description',
                    'recruiter' => [
                        'id',
                        'name',
                    ],
                ],
            ])
            ->assertJson([
                'data' => [
                    'id' => $job->id,
                    'title' => $job->title,
                ],
            ]);
    }

    /**
     * Test show non-existent job returns 404
     * 
     * Verifies:
     * - Status 404
     * - Appropriate error message
     */
    public function test_show_nonexistent_job_returns_404(): void
    {
        $response = $this->getJson('/api/jobs/99999');

        $response->assertStatus(404)
            ->assertJsonPath('success', false);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Create Tests (POST /api/jobs)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Test create job as recruiter successfully
     * 
     * Verifies:
     * - Status 201
     * - Job created in database
     * - Recruiter ID set correctly
     */
    public function test_create_job_as_recruiter_successfully(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $token = $recruiter->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/jobs', [
                'title' => 'Senior Laravel Developer',
                'description' => 'We are looking for an experienced Laravel developer with 5+ years of experience.',
                'location' => 'Remote',
                'salary_min' => 80000,
                'salary_max' => 120000,
                'job_type' => 'full_time',
                'required_skills' => ['PHP', 'Laravel', 'MySQL'],
                'deadline' => now()->addDays(30),
            ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'id',
                    'title',
                    'recruiter_id',
                ],
            ])
            ->assertJson([
                'data' => [
                    'title' => 'Senior Laravel Developer',
                    'recruiter_id' => $recruiter->id,
                ],
            ]);

        $this->assertDatabaseHas('jobs', [
            'title' => 'Senior Laravel Developer',
            'recruiter_id' => $recruiter->id,
        ]);
    }

    /**
     * Test create job as job seeker fails (authorization)
     * 
     * Verifies:
     * - Status 403 (Forbidden)
     * - Only recruiters can create jobs
     */
    public function test_create_job_as_job_seeker_fails(): void
    {
        $jobSeeker = User::factory()->create(['role' => 'job_seeker']);
        $token = $jobSeeker->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/jobs', [
                'title' => 'Senior Laravel Developer',
                'description' => 'We are looking for an experienced Laravel developer.',
                'location' => 'Remote',
                'salary_min' => 80000,
                'salary_max' => 120000,
                'job_type' => 'full_time',
            ]);

        $response->assertStatus(403);
    }

    /**
     * Test create job without authentication fails
     * 
     * Verifies:
     * - Status 401
     * - Requires token
     */
    public function test_create_job_without_auth_fails(): void
    {
        $response = $this->postJson('/api/jobs', [
            'title' => 'Senior Laravel Developer',
            'description' => 'Description',
            'location' => 'Remote',
        ]);

        $response->assertStatus(401);
    }

    /**
     * Test create job with missing title fails
     * 
     * Verifies:
     * - Status 422
     * - Validation error for missing title
     */
    public function test_create_job_with_missing_title_fails(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $token = $recruiter->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/jobs', [
                'description' => 'Description',
                'location' => 'Remote',
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('errors.title.0', 'Job title is required');
    }

    /**
     * Test create job with title too short fails
     * 
     * Verifies:
     * - Status 422
     * - Min length validation
     */
    public function test_create_job_with_title_too_short_fails(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $token = $recruiter->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/jobs', [
                'title' => 'Dev', // Less than 5 chars
                'description' => 'Description',
                'location' => 'Remote',
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('errors.title.0', 'Job title must be at least 5 characters');
    }

    /**
     * Test create job with description too short fails
     * 
     * Verifies:
     * - Description min length validation
     */
    public function test_create_job_with_description_too_short_fails(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $token = $recruiter->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/jobs', [
                'title' => 'Senior Developer',
                'description' => 'Short', // Less than 20 chars
                'location' => 'Remote',
            ]);

        $response->assertStatus(422)
            ->assertJsonPath('errors.description.0', 'Description must be at least 20 characters');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Update Tests (PUT /api/jobs/{id})
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Test update own job successfully
     * 
     * Verifies:
     * - Status 200
     * - Job updated in database
     * - Only recruiter who created job can update
     */
    public function test_update_own_job_successfully(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id]);
        $token = $recruiter->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->putJson("/api/jobs/{$job->id}", [
                'title' => 'Updated Job Title',
                'description' => 'Updated job description that is long enough',
                'location' => 'On-site',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'data' => [
                    'title' => 'Updated Job Title',
                    'location' => 'On-site',
                ],
            ]);

        $this->assertDatabaseHas('jobs', [
            'id' => $job->id,
            'title' => 'Updated Job Title',
        ]);
    }

    /**
     * Test update someone else's job fails (authorization)
     * 
     * Verifies:
     * - Status 403
     * - Recruiters can only update their own jobs
     */
    public function test_update_others_job_fails(): void
    {
        $recruiter1 = User::factory()->create(['role' => 'recruiter']);
        $recruiter2 = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['recruiter_id' => $recruiter1->id]);
        $token = $recruiter2->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->putJson("/api/jobs/{$job->id}", [
                'title' => 'Updated Job Title',
                'description' => 'Updated job description',
            ]);

        $response->assertStatus(403)
            ->assertJsonPath('success', false);
    }

    /**
     * Test update non-existent job returns 404
     * 
     * Verifies:
     * - Status 404
     */
    public function test_update_nonexistent_job_returns_404(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $token = $recruiter->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->putJson("/api/jobs/99999", [
                'title' => 'Updated Title',
                'description' => 'Updated description',
            ]);

        $response->assertStatus(404);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Delete Tests (DELETE /api/jobs/{id})
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Test delete own job successfully
     * 
     * Verifies:
     * - Status 200
     * - Job deleted from database
     */
    public function test_delete_own_job_successfully(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id]);
        $token = $recruiter->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->deleteJson("/api/jobs/{$job->id}");

        $response->assertStatus(200)
            ->assertJsonPath('success', true);

        $this->assertDatabaseMissing('jobs', ['id' => $job->id]);
    }

    /**
     * Test delete someone else's job fails (authorization)
     * 
     * Verifies:
     * - Status 403
     */
    public function test_delete_others_job_fails(): void
    {
        $recruiter1 = User::factory()->create(['role' => 'recruiter']);
        $recruiter2 = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['recruiter_id' => $recruiter1->id]);
        $token = $recruiter2->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->deleteJson("/api/jobs/{$job->id}");

        $response->assertStatus(403)
            ->assertJsonPath('success', false);

        // Job still exists
        $this->assertDatabaseHas('jobs', ['id' => $job->id]);
    }

    /**
     * Test delete non-existent job returns 404
     * 
     * Verifies:
     * - Status 404
     */
    public function test_delete_nonexistent_job_returns_404(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $token = $recruiter->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->deleteJson("/api/jobs/99999");

        $response->assertStatus(404);
    }
}
