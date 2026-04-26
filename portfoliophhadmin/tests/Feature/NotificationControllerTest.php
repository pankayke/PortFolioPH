<?php

namespace Tests\Feature;

use App\Models\Application;
use App\Models\Job;
use App\Models\User;
use App\Notifications\ApplicationStatusUpdatedNotification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NotificationControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_notification_endpoints_require_authentication(): void
    {
        $this->getJson('/api/notifications')->assertStatus(401);
        $this->postJson('/api/notifications/read-all')->assertStatus(401);
        $this->postJson('/api/notifications/non-existent/read')->assertStatus(401);
    }

    public function test_list_notifications_returns_authenticated_users_notifications(): void
    {
        $seeker = User::factory()->create(['role' => 'job_seeker']);
        $otherSeeker = User::factory()->create(['role' => 'job_seeker']);
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id]);

        $application = Application::factory()->create([
            'user_id' => $seeker->id,
            'job_id' => $job->id,
            'status' => 'accepted',
        ]);

        $otherApplication = Application::factory()->create([
            'user_id' => $otherSeeker->id,
            'job_id' => $job->id,
            'status' => 'rejected',
        ]);

        $seeker->notify(new ApplicationStatusUpdatedNotification($application));
        $otherSeeker->notify(new ApplicationStatusUpdatedNotification($otherApplication));

        $token = $seeker->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/notifications');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.status', 'accepted');
    }

    public function test_mark_notification_as_read_updates_read_at(): void
    {
        $seeker = User::factory()->create(['role' => 'job_seeker']);
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id]);

        $application = Application::factory()->create([
            'user_id' => $seeker->id,
            'job_id' => $job->id,
            'status' => 'accepted',
        ]);

        $seeker->notify(new ApplicationStatusUpdatedNotification($application));
        $notificationId = $seeker->notifications()->value('id');

        $token = $seeker->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson("/api/notifications/{$notificationId}/read");

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.is_read', true);

        $this->assertDatabaseMissing('notifications', [
            'id' => $notificationId,
            'read_at' => null,
        ]);
    }

    public function test_mark_all_notifications_as_read_marks_all_unread_records(): void
    {
        $seeker = User::factory()->create(['role' => 'job_seeker']);
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $jobs = Job::factory()->count(2)->create(['recruiter_id' => $recruiter->id]);

        $acceptedApplication = Application::factory()->create([
            'user_id' => $seeker->id,
            'job_id' => $jobs[0]->id,
            'status' => 'accepted',
        ]);

        $rejectedApplication = Application::factory()->create([
            'user_id' => $seeker->id,
            'job_id' => $jobs[1]->id,
            'status' => 'rejected',
        ]);

        $seeker->notify(new ApplicationStatusUpdatedNotification($acceptedApplication));
        $seeker->notify(new ApplicationStatusUpdatedNotification($rejectedApplication));

        $token = $seeker->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/notifications/read-all');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.marked_count', 2);

        $this->assertSame(0, $seeker->unreadNotifications()->count());
    }

    public function test_mark_notification_as_read_for_other_user_returns_404(): void
    {
        $seeker = User::factory()->create(['role' => 'job_seeker']);
        $otherSeeker = User::factory()->create(['role' => 'job_seeker']);
        $recruiter = User::factory()->create(['role' => 'recruiter']);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id]);

        $otherApplication = Application::factory()->create([
            'user_id' => $otherSeeker->id,
            'job_id' => $job->id,
            'status' => 'accepted',
        ]);

        $otherSeeker->notify(new ApplicationStatusUpdatedNotification($otherApplication));
        $notificationId = $otherSeeker->notifications()->value('id');

        $token = $seeker->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson("/api/notifications/{$notificationId}/read");

        $response->assertStatus(404)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Notification not found');
    }

    public function test_notifications_index_caps_per_page_to_50(): void
    {
        $seeker = User::factory()->create(['role' => 'job_seeker']);
        $recruiter = User::factory()->create(['role' => 'recruiter']);

        $jobs = Job::factory()->count(55)->create(['recruiter_id' => $recruiter->id]);

        foreach ($jobs as $job) {
            $application = Application::factory()->create([
                'user_id' => $seeker->id,
                'job_id' => $job->id,
                'status' => 'accepted',
            ]);
            $seeker->notify(new ApplicationStatusUpdatedNotification($application));
        }

        $token = $seeker->createToken('api-token')->plainTextToken;
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/notifications?per_page=999');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonCount(50, 'data');
    }
}
