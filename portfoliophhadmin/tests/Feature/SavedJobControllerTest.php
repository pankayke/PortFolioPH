<?php

namespace Tests\Feature;

use App\Models\Job;
use App\Models\SavedJob;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SavedJobControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_job_seeker_can_save_job(): void
    {
        $seeker = User::factory()->create(['role' => 'job_seeker']);
        $job = Job::factory()->create(['status' => 'approved']);

        $response = $this->actingAs($seeker, 'sanctum')->postJson('/api/saved-jobs', [
            'job_id' => $job->id,
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('saved_jobs', [
            'user_id' => $seeker->id,
            'job_id' => $job->id,
        ]);
    }

    public function test_job_seeker_can_list_saved_jobs(): void
    {
        $seeker = User::factory()->create(['role' => 'job_seeker']);
        $job = Job::factory()->create(['status' => 'approved']);
        SavedJob::create(['user_id' => $seeker->id, 'job_id' => $job->id]);

        $response = $this->actingAs($seeker, 'sanctum')->getJson('/api/saved-jobs');

        $response->assertStatus(200);
        $response->assertJsonPath('data.0.job_id', $job->id);
    }

    public function test_job_seeker_can_unsave_job(): void
    {
        $seeker = User::factory()->create(['role' => 'job_seeker']);
        $job = Job::factory()->create(['status' => 'approved']);
        SavedJob::create(['user_id' => $seeker->id, 'job_id' => $job->id]);

        $response = $this->actingAs($seeker, 'sanctum')->deleteJson('/api/saved-jobs/'.$job->id);

        $response->assertStatus(200);
        $this->assertDatabaseMissing('saved_jobs', [
            'user_id' => $seeker->id,
            'job_id' => $job->id,
        ]);
    }

    public function test_non_job_seeker_cannot_save_job(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['status' => 'approved']);

        $response = $this->actingAs($recruiter, 'sanctum')->postJson('/api/saved-jobs', [
            'job_id' => $job->id,
        ]);

        $response->assertStatus(403)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Only job seekers can save jobs.');
    }

    public function test_duplicate_save_job_returns_conflict(): void
    {
        $seeker = User::factory()->create(['role' => 'job_seeker']);
        $job = Job::factory()->create(['status' => 'approved']);

        SavedJob::create(['user_id' => $seeker->id, 'job_id' => $job->id]);

        $response = $this->actingAs($seeker, 'sanctum')->postJson('/api/saved-jobs', [
            'job_id' => $job->id,
        ]);

        $response->assertStatus(409)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Job already saved.');
    }

    public function test_unsave_missing_saved_job_returns_404(): void
    {
        $seeker = User::factory()->create(['role' => 'job_seeker']);
        $job = Job::factory()->create(['status' => 'approved']);

        $response = $this->actingAs($seeker, 'sanctum')->deleteJson('/api/saved-jobs/'.$job->id);

        $response->assertStatus(404)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Saved job not found.');
    }

    public function test_saved_jobs_endpoints_require_authentication(): void
    {
        $job = Job::factory()->create(['status' => 'approved']);

        $this->getJson('/api/saved-jobs')->assertStatus(401);
        $this->postJson('/api/saved-jobs', ['job_id' => $job->id])->assertStatus(401);
        $this->deleteJson('/api/saved-jobs/'.$job->id)->assertStatus(401);
    }
}
