<?php

namespace Tests\Feature;

use App\Models\Application;
use App\Models\Job;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CVAndExportEndpointsTest extends TestCase
{
    use RefreshDatabase;

    private function writeResumeFile(string $filename = 'test_cv.pdf'): string
    {
        $relative = 'resumes/'.$filename;
        $absolute = storage_path('app/public/'.$relative);
        $directory = dirname($absolute);

        if (! is_dir($directory)) {
            mkdir($directory, 0777, true);
        }

        file_put_contents($absolute, '%PDF-1.4 test cv file');

        return $relative;
    }

    public function test_user_can_download_own_cv_via_api(): void
    {
        $user = User::factory()->create([
            'role' => 'job_seeker',
            'resume_path' => $this->writeResumeFile('own_cv.pdf'),
        ]);

        $token = $user->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->get('/api/profile/cv');

        $response->assertOk();
        $response->assertHeader('content-disposition');
        $this->assertStringContainsString('CV_', (string) $response->headers->get('content-disposition'));
    }

    public function test_cv_download_returns_404_when_user_has_no_cv(): void
    {
        $user = User::factory()->create([
            'role' => 'job_seeker',
            'resume_path' => null,
        ]);

        $token = $user->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->get('/api/profile/cv');

        $response->assertStatus(404);
    }

    public function test_recruiter_can_download_applicant_cv_via_application_endpoint(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $seeker = User::factory()->create([
            'role' => 'job_seeker',
            'resume_path' => $this->writeResumeFile('applicant_cv.pdf'),
        ]);

        $job = Job::factory()->create([
            'recruiter_id' => $recruiter->id,
            'status' => 'approved',
        ]);

        $application = Application::factory()->create([
            'user_id' => $seeker->id,
            'job_id' => $job->id,
        ]);

        $token = $recruiter->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->get("/api/applications/{$application->id}/cv");

        $response->assertOk();
        $response->assertHeader('content-disposition');
        $this->assertStringContainsString('.pdf', (string) $response->headers->get('content-disposition'));
    }

    public function test_admin_can_download_users_jobs_and_applications_exports(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('api-token')->plainTextToken;

        $usersExport = $this->withHeader('Authorization', "Bearer {$token}")
            ->get('/api/admin/users/export/csv');
        $usersExport->assertOk();
        $this->assertStringContainsString('users_export_', (string) $usersExport->headers->get('content-disposition'));

        $jobsExport = $this->withHeader('Authorization', "Bearer {$token}")
            ->get('/api/admin/jobs/export/xlsx');
        $jobsExport->assertOk();
        $this->assertStringContainsString('jobs_export_', (string) $jobsExport->headers->get('content-disposition'));

        $applicationsExport = $this->withHeader('Authorization', "Bearer {$token}")
            ->get('/api/admin/applications/export/csv');
        $applicationsExport->assertOk();
        $this->assertStringContainsString('applications_export_', (string) $applicationsExport->headers->get('content-disposition'));
    }

    public function test_non_admin_cannot_access_admin_exports_api(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $token = $recruiter->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->get('/api/admin/users/export/csv');

        $response->assertStatus(403);
    }

    public function test_admin_can_access_admin_stats_api(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $jobSeeker = User::factory()->create(['role' => 'job_seeker']);

        $job = Job::factory()->create([
            'recruiter_id' => $recruiter->id,
            'status' => 'approved',
        ]);

        Application::factory()->create([
            'user_id' => $jobSeeker->id,
            'job_id' => $job->id,
            'status' => 'pending',
        ]);

        $token = $admin->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->get('/api/admin/stats');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.users.recruiters', 1)
            ->assertJsonPath('data.users.job_seekers', 1)
            ->assertJsonPath('data.jobs.approved', 1)
            ->assertJsonPath('data.applications.pending', 1);
    }

    public function test_non_admin_cannot_access_admin_stats_api(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $token = $recruiter->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->get('/api/admin/stats');

        $response->assertStatus(403);
    }
}
