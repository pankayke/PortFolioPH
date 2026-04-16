<?php

namespace Tests\Feature;

use App\Models\Application;
use App\Models\Job;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RecruiterDashboardControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_recruiter_dashboard_returns_aggregates(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $jobOne = Job::factory()->create([
            'recruiter_id' => $recruiter->id,
            'status' => 'approved',
        ]);
        $jobTwo = Job::factory()->create([
            'recruiter_id' => $recruiter->id,
            'status' => 'closed',
        ]);
        $seekerOne = User::factory()->create(['role' => 'job_seeker']);
        $seekerTwo = User::factory()->create(['role' => 'job_seeker']);
        $seekerThree = User::factory()->create(['role' => 'job_seeker']);

        Application::factory()->create([
            'job_id' => $jobOne->id,
            'user_id' => $seekerOne->id,
            'status' => 'pending',
            'created_at' => now()->subHours(3),
            'updated_at' => now()->subHours(3),
        ]);
        Application::factory()->create([
            'job_id' => $jobOne->id,
            'user_id' => $seekerTwo->id,
            'status' => 'reviewed',
            'created_at' => now()->subDays(2),
            'updated_at' => now()->subDays(2),
        ]);
        Application::factory()->create([
            'job_id' => $jobTwo->id,
            'user_id' => $seekerThree->id,
            'status' => 'shortlisted',
            'created_at' => now()->subHours(8),
            'updated_at' => now()->subHours(8),
        ]);

        $token = $recruiter->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/recruiter/dashboard');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.total_jobs', 2)
            ->assertJsonPath('data.active_jobs', 1)
            ->assertJsonPath('data.total_applications', 3)
            ->assertJsonPath('data.new_applications_count', 2)
            ->assertJsonPath('data.jobs_with_application_count', 2)
            ->assertJsonStructure([
                'data' => [
                    'ats_summary' => ['pending', 'reviewed', 'shortlisted', 'rejected'],
                    'application_stats_by_day' => [
                        '*' => ['date', 'label', 'count'],
                    ],
                    'top_jobs' => [
                        '*' => ['id', 'title', 'status', 'applications_count'],
                    ],
                    'recent_applications' => [
                        '*' => ['id', 'job_id', 'user_id', 'status'],
                    ],
                ],
            ]);
    }

    public function test_non_recruiter_cannot_access_recruiter_dashboard(): void
    {
        $user = User::factory()->create(['role' => 'job_seeker']);
        $token = $user->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/recruiter/dashboard');

        $response->assertStatus(403);
    }
}