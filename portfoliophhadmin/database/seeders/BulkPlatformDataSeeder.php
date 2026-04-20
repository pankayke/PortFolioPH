<?php

namespace Database\Seeders;

use App\Models\Application;
use App\Models\Job;
use App\Models\User;
use Illuminate\Database\Seeder;

class BulkPlatformDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->seedJobs();
        $this->seedApplications();
    }

    private function seedJobs(): void
    {
        $recruiterIds = User::query()
            ->where('role', 'recruiter')
            ->pluck('id')
            ->all();

        if (empty($recruiterIds)) {
            return;
        }

        $this->topUpJobsForStatus('approved', 180, $recruiterIds);
        $this->topUpJobsForStatus('pending', 30, $recruiterIds);
        $this->topUpJobsForStatus('draft', 20, $recruiterIds);
        $this->topUpJobsForStatus('closed', 10, $recruiterIds);
    }

    private function topUpJobsForStatus(string $status, int $targetCount, array $recruiterIds): void
    {
        $currentCount = Job::query()->where('status', $status)->count();
        $missing = max(0, $targetCount - $currentCount);

        if ($missing === 0) {
            return;
        }

        for ($i = 0; $i < $missing; $i++) {
            Job::factory()->create([
                'recruiter_id' => $recruiterIds[array_rand($recruiterIds)],
                'status' => $status,
            ]);
        }
    }

    private function seedApplications(): void
    {
        $targetApplications = 1200;
        $currentCount = Application::query()->count();

        if ($currentCount >= $targetApplications) {
            return;
        }

        $jobSeekerIds = User::query()
            ->where('role', 'job_seeker')
            ->pluck('id')
            ->all();

        $approvedJobIds = Job::query()
            ->where('status', 'approved')
            ->pluck('id')
            ->all();

        if (empty($jobSeekerIds) || empty($approvedJobIds)) {
            return;
        }

        $statuses = ['pending', 'reviewed', 'shortlisted', 'rejected', 'accepted'];

        foreach ($approvedJobIds as $jobId) {
            if (Application::query()->count() >= $targetApplications) {
                break;
            }

            $perJob = random_int(4, 10);
            $selectedUserIds = collect($jobSeekerIds)->shuffle()->take($perJob);

            foreach ($selectedUserIds as $userId) {
                if (Application::query()->count() >= $targetApplications) {
                    break;
                }

                Application::query()->firstOrCreate(
                    [
                        'user_id' => $userId,
                        'job_id' => $jobId,
                    ],
                    [
                        'cover_letter' => fake()->sentence(18),
                        'status' => $statuses[array_rand($statuses)],
                    ]
                );
            }
        }
    }
}
