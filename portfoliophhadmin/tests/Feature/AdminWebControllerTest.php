<?php

namespace Tests\Feature;

use App\Models\Application;
use App\Models\Job;
use App\Models\Setting;
use App\Models\User;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminWebControllerTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->withoutMiddleware(VerifyCsrfToken::class);

        $this->admin = User::factory()->create([
            'role' => 'admin',
            'active' => true,
        ]);
    }

    public function test_admin_routes_require_authentication(): void
    {
        $response = $this->get(route('admin.dashboard'));

        $response->assertRedirect(route('login'));
    }

    public function test_non_admin_cannot_access_admin_dashboard(): void
    {
        $recruiter = User::factory()->create([
            'role' => 'recruiter',
            'active' => true,
        ]);

        $response = $this->actingAs($recruiter)->get(route('admin.dashboard'));

        $response->assertRedirect('/');
        $response->assertSessionHas('error', 'Access denied. Admin privileges required.');
    }

    public function test_admin_dashboard_loads_with_stats_payload(): void
    {
        User::factory()->create(['role' => 'recruiter', 'active' => true]);
        User::factory()->create(['role' => 'job_seeker', 'active' => true]);

        $recruiter = User::factory()->create(['role' => 'recruiter', 'active' => true]);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id, 'status' => 'approved']);
        Application::factory()->create(['job_id' => $job->id, 'status' => 'pending']);

        $response = $this->actingAs($this->admin)->get(route('admin.dashboard'));

        $response->assertOk();
        $response->assertViewHas('stats', function (array $stats): bool {
            return isset(
                $stats['total_users'],
                $stats['admins'],
                $stats['recruiters'],
                $stats['job_seekers'],
                $stats['total_jobs'],
                $stats['active_jobs'],
                $stats['total_applications'],
                $stats['pending_applications'],
            );
        });
    }

    public function test_admin_audit_page_loads_with_recent_actions_and_metrics(): void
    {
        $this->actingAs($this->admin);

        $recruiter = User::factory()->create(['role' => 'recruiter', 'active' => true]);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id, 'status' => 'approved']);
        $seeker = User::factory()->create(['role' => 'job_seeker', 'active' => true]);

        Application::factory()->create([
            'job_id' => $job->id,
            'user_id' => $seeker->id,
        ]);

        $response = $this->get(route('admin.audit'));

        $response->assertOk();
        $response->assertViewHasAll(['auditLogs', 'activeSessions', 'serverLoad']);
        $response->assertViewHas('auditLogs', function ($auditLogs): bool {
            return $auditLogs->first() !== null && $auditLogs->first()->relationLoaded('user');
        });
    }

    public function test_suspend_and_unsuspend_user_updates_active_flag(): void
    {
        $managedUser = User::factory()->create(['role' => 'job_seeker', 'active' => true]);

        $this->actingAs($this->admin)
            ->post(route('admin.users.suspend', $managedUser))
            ->assertRedirect(route('admin.users.show', $managedUser));

        $this->assertDatabaseHas('users', [
            'id' => $managedUser->id,
            'active' => false,
        ]);

        $this->actingAs($this->admin)
            ->post(route('admin.users.unsuspend', $managedUser))
            ->assertRedirect(route('admin.users.show', $managedUser));

        $this->assertDatabaseHas('users', [
            'id' => $managedUser->id,
            'active' => true,
        ]);
    }

    public function test_delete_user_removes_user_and_own_applications(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter', 'active' => true]);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id, 'status' => 'approved']);

        $jobSeeker = User::factory()->create(['role' => 'job_seeker', 'active' => true]);
        $application = Application::factory()->create([
            'user_id' => $jobSeeker->id,
            'job_id' => $job->id,
        ]);

        $this->actingAs($this->admin)
            ->delete(route('admin.users.delete', $jobSeeker))
            ->assertRedirect(route('admin.users.index'));

        $this->assertDatabaseMissing('users', ['id' => $jobSeeker->id]);
        $this->assertDatabaseMissing('applications', ['id' => $application->id]);
    }

    public function test_approve_and_suspend_job_updates_status(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter', 'active' => true]);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id, 'status' => 'pending']);

        $this->actingAs($this->admin)
            ->post(route('admin.jobs.approve', $job))
            ->assertRedirect(route('admin.jobs.show', $job));

        $this->assertDatabaseHas('jobs', ['id' => $job->id, 'status' => 'approved']);

        $this->actingAs($this->admin)
            ->post(route('admin.jobs.suspend', $job))
            ->assertRedirect(route('admin.jobs.show', $job));

        $this->assertDatabaseHas('jobs', ['id' => $job->id, 'status' => 'closed']);
    }

    public function test_delete_job_removes_job_and_applications(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter', 'active' => true]);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id, 'status' => 'approved']);
        $application = Application::factory()->create(['job_id' => $job->id]);

        $this->actingAs($this->admin)
            ->delete(route('admin.jobs.delete', $job))
            ->assertRedirect(route('admin.jobs.index'));

        $this->assertDatabaseMissing('jobs', ['id' => $job->id]);
        $this->assertDatabaseMissing('applications', ['id' => $application->id]);
    }

    public function test_settings_update_persists_session_preferences(): void
    {
        $payload = [
            'maintenance_mode' => '1',
            'new_user_alerts' => '1',
            'moderation_alerts' => '0',
            'digest_frequency' => 'weekly',
            'dashboard_density' => 'compact',
            'session_timeout' => 45,
        ];

        $response = $this->actingAs($this->admin)
            ->put(route('admin.settings.update'), $payload);

        $response->assertRedirect(route('admin.settings'));
        $response->assertSessionHas('success', 'Admin command center settings updated.');

        $this->assertTrue((bool) Setting::get('maintenance_mode'));
        $this->assertTrue((bool) Setting::get('new_user_alerts'));
        $this->assertFalse((bool) Setting::get('moderation_alerts'));
        $this->assertSame('weekly', Setting::get('digest_frequency'));
        $this->assertSame('compact', Setting::get('dashboard_density'));
        $this->assertSame(45, Setting::get('session_timeout'));
    }

    public function test_applications_page_contains_aggregated_stats(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter', 'active' => true]);
        $seeker = User::factory()->create(['role' => 'job_seeker', 'active' => true]);

        $statuses = ['pending', 'reviewed', 'shortlisted', 'accepted', 'rejected'];

        foreach ($statuses as $status) {
            $job = Job::factory()->create(['recruiter_id' => $recruiter->id, 'status' => 'approved']);
            Application::factory()->create([
                'job_id' => $job->id,
                'user_id' => $seeker->id,
                'status' => $status,
            ]);
        }

        $response = $this->actingAs($this->admin)->get(route('admin.applications.index'));

        $response->assertOk();
        $response->assertViewHas('stats', function (array $stats): bool {
            return $stats['pending'] === 1
                && $stats['reviewed'] === 1
                && $stats['shortlisted'] === 1
                && $stats['accepted'] === 1
                && $stats['rejected'] === 1;
        });
    }

    public function test_admin_application_inspect_page_loads(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter', 'active' => true]);
        $seeker = User::factory()->create(['role' => 'job_seeker', 'active' => true]);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id, 'status' => 'approved']);
        $application = Application::factory()->create([
            'job_id' => $job->id,
            'user_id' => $seeker->id,
            'status' => 'reviewed',
        ]);

        $response = $this->actingAs($this->admin)->get(route('admin.applications.show', $application));

        $response->assertOk();
        $response->assertSee($application->job->title);
        $response->assertSee($application->user->email);
    }

    public function test_applications_page_links_inspect_to_detail_view(): void
    {
        $recruiter = User::factory()->create(['role' => 'recruiter', 'active' => true]);
        $seeker = User::factory()->create(['role' => 'job_seeker', 'active' => true]);
        $job = Job::factory()->create(['recruiter_id' => $recruiter->id, 'status' => 'approved']);
        $application = Application::factory()->create([
            'job_id' => $job->id,
            'user_id' => $seeker->id,
            'status' => 'pending',
        ]);

        $response = $this->actingAs($this->admin)->get(route('admin.applications.index'));

        $response->assertOk();
        $response->assertSee(route('admin.applications.show', $application), false);
    }

    public function test_update_settings_rejects_invalid_payload(): void
    {
        $response = $this->actingAs($this->admin)
            ->from(route('admin.settings'))
            ->put(route('admin.settings.update'), [
                'digest_frequency' => 'invalid-frequency',
                'dashboard_density' => 'ultra',
                'session_timeout' => 1,
            ]);

        $response->assertRedirect(route('admin.settings'));
        $response->assertSessionHasErrors([
            'digest_frequency',
            'dashboard_density',
            'session_timeout',
        ]);
    }

    public function test_settings_page_uses_expected_defaults_without_session(): void
    {
        $response = $this->actingAs($this->admin)->get(route('admin.settings'));

        $response->assertOk();
        $response->assertViewHas('settings', function (array $settings): bool {
            return $settings['maintenance_mode'] === false
                && $settings['new_user_alerts'] === true
                && $settings['moderation_alerts'] === true
                && $settings['digest_frequency'] === 'daily'
                && $settings['dashboard_density'] === 'high'
                && $settings['session_timeout'] === 30;
        });
    }

    public function test_update_user_rejects_invalid_role(): void
    {
        $managedUser = User::factory()->create([
            'role' => 'job_seeker',
            'active' => true,
        ]);

        $response = $this->actingAs($this->admin)
            ->from(route('admin.users.edit', $managedUser))
            ->put(route('admin.users.update', $managedUser), [
                'name' => $managedUser->name,
                'email' => $managedUser->email,
                'role' => 'super_admin',
            ]);

        $response->assertRedirect(route('admin.users.edit', $managedUser));
        $response->assertSessionHasErrors(['role']);
    }

    public function test_recruiter_demoted_to_job_seeker_closes_jobs_and_reviews_applications(): void
    {
        $recruiter = User::factory()->create([
            'role' => 'recruiter',
            'active' => true,
        ]);

        $job = Job::factory()->create([
            'recruiter_id' => $recruiter->id,
            'status' => 'approved',
        ]);

        $seeker = User::factory()->create([
            'role' => 'job_seeker',
            'active' => true,
        ]);

        $application = Application::factory()->create([
            'job_id' => $job->id,
            'user_id' => $seeker->id,
            'status' => 'pending',
        ]);

        $response = $this->actingAs($this->admin)
            ->put(route('admin.users.update', $recruiter), [
                'name' => $recruiter->name,
                'email' => $recruiter->email,
                'role' => 'job_seeker',
            ]);

        $response->assertRedirect(route('admin.users.show', $recruiter));
        $response->assertSessionHas('success');

        $this->assertDatabaseHas('users', [
            'id' => $recruiter->id,
            'role' => 'job_seeker',
        ]);

        $this->assertDatabaseHas('jobs', [
            'id' => $job->id,
            'status' => 'closed',
        ]);

        $this->assertDatabaseHas('applications', [
            'id' => $application->id,
            'status' => 'reviewed',
        ]);
    }

    public function test_users_index_search_matches_name_email_and_username_terms(): void
    {
        $target = User::factory()->create([
            'name' => 'Alice Santos',
            'email' => 'alice.santos@example.com',
            'username' => 'alice.dev',
            'role' => 'job_seeker',
            'active' => true,
        ]);

        User::factory()->create([
            'name' => 'Bob Cruz',
            'email' => 'bob.cruz@example.com',
            'username' => 'bobby',
            'role' => 'job_seeker',
            'active' => true,
        ]);

        $response = $this->actingAs($this->admin)
            ->get(route('admin.users.index', ['search' => 'alice dev']));

        $response->assertOk();
        $response->assertViewHas('users', function ($users) use ($target): bool {
            $collection = $users->getCollection();

            return $collection->count() === 1
                && (int) $collection->first()->id === (int) $target->id;
        });
    }

    public function test_users_index_role_filter_accepts_job_seeker_aliases(): void
    {
        $jobSeeker = User::factory()->create([
            'role' => 'job_seeker',
            'active' => true,
        ]);

        User::factory()->create([
            'role' => 'recruiter',
            'active' => true,
        ]);

        $response = $this->actingAs($this->admin)
            ->get(route('admin.users.index', ['role' => 'job seeker']));

        $response->assertOk();
        $response->assertViewHas('users', function ($users) use ($jobSeeker): bool {
            $collection = $users->getCollection();

            return $collection->contains('id', $jobSeeker->id)
                && $collection->every(fn ($user) => $user->role === 'job_seeker');
        });
    }

    public function test_users_index_status_filter_suspended_returns_only_inactive_users(): void
    {
        $inactiveUser = User::factory()->create([
            'role' => 'job_seeker',
            'active' => false,
        ]);

        User::factory()->create([
            'role' => 'job_seeker',
            'active' => true,
        ]);

        $response = $this->actingAs($this->admin)
            ->get(route('admin.users.index', ['status' => 'suspended']));

        $response->assertOk();
        $response->assertViewHas('users', function ($users) use ($inactiveUser): bool {
            $collection = $users->getCollection();

            return $collection->contains('id', $inactiveUser->id)
                && $collection->every(fn ($user) => (int) ($user->active ?? 0) === 0);
        });
    }

    public function test_users_index_sort_by_active_desc_prioritizes_active_users(): void
    {
        $activeUser = User::factory()->create([
            'role' => 'job_seeker',
            'active' => true,
        ]);

        $inactiveUser = User::factory()->create([
            'role' => 'job_seeker',
            'active' => false,
        ]);

        $response = $this->actingAs($this->admin)
            ->get(route('admin.users.index', [
                'sort_by' => 'active',
                'sort_dir' => 'desc',
                'role' => 'job_seeker',
            ]));

        $response->assertOk();
        $response->assertViewHas('users', function ($users) use ($activeUser, $inactiveUser): bool {
            $collection = $users->getCollection();

            if ($collection->count() < 2) {
                return false;
            }

            $firstActive = (int) ($collection->first()->active ?? 0);
            $lastActive = (int) ($collection->last()->active ?? 0);

            return $collection->contains('id', $activeUser->id)
                && $collection->contains('id', $inactiveUser->id)
                && $firstActive >= $lastActive;
        });
    }

    public function test_users_index_invalid_sort_falls_back_to_created_at_desc(): void
    {
        // Keep admin out of top ordering to ensure deterministic assertions.
        $this->admin->forceFill([
            'created_at' => now()->subYears(1),
            'updated_at' => now()->subYears(1),
        ])->save();

        User::factory()->create([
            'name' => 'Older User',
            'created_at' => now()->subDays(5),
            'updated_at' => now()->subDays(5),
        ]);

        $newerUser = User::factory()->create([
            'name' => 'Newest User',
            'created_at' => now()->subDay(),
            'updated_at' => now()->subDay(),
        ]);

        $response = $this->actingAs($this->admin)
            ->get(route('admin.users.index', ['sort_by' => 'not_a_real_column']));

        $response->assertOk();
        $response->assertViewHas('users', function ($users) use ($newerUser): bool {
            $first = $users->getCollection()->first();

            return $first !== null && (int) $first->id === (int) $newerUser->id;
        });
    }
}
