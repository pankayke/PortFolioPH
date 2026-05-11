<?php

namespace Database\Seeders;

use App\Models\Application;
use App\Models\Job;
use App\Models\User;
use Illuminate\Database\Seeder;

class BulkPlatformDataSeeder extends Seeder
{
    /**
     * @var array<int, array{title: string, job_type: string, skills: array<int, string>, summary: string}>
     */
    private array $jobProfiles = [
        [
            'title' => 'Frontend Developer (React)',
            'job_type' => 'full_time',
            'skills' => ['React', 'TypeScript', 'Tailwind CSS', 'REST APIs'],
            'summary' => 'Build responsive web interfaces and collaborate with product and backend teams.',
        ],
        [
            'title' => 'Backend Developer (Laravel)',
            'job_type' => 'full_time',
            'skills' => ['PHP', 'Laravel', 'MySQL', 'API Design'],
            'summary' => 'Design robust APIs, optimize queries, and maintain secure backend services.',
        ],
        [
            'title' => 'Mobile Developer (Flutter)',
            'job_type' => 'full_time',
            'skills' => ['Flutter', 'Dart', 'Firebase', 'State Management'],
            'summary' => 'Develop cross-platform mobile apps with clean architecture and test coverage.',
        ],
        [
            'title' => 'UI/UX Designer',
            'job_type' => 'contract',
            'skills' => ['Figma', 'Wireframing', 'Design Systems', 'Usability Testing'],
            'summary' => 'Create user-centered flows, polished interfaces, and reusable design patterns.',
        ],
        [
            'title' => 'DevOps Engineer',
            'job_type' => 'full_time',
            'skills' => ['Docker', 'CI/CD', 'Nginx', 'AWS'],
            'summary' => 'Automate deployment pipelines and keep cloud environments scalable and stable.',
        ],
        [
            'title' => 'Data Analyst',
            'job_type' => 'part_time',
            'skills' => ['SQL', 'Power BI', 'Python', 'Data Visualization'],
            'summary' => 'Translate business questions into dashboards and actionable data insights.',
        ],
        [
            'title' => 'Technical Recruiter',
            'job_type' => 'full_time',
            'skills' => ['Talent Sourcing', 'Interviewing', 'ATS', 'Stakeholder Management'],
            'summary' => 'Source and manage top engineering talent pipelines for growing teams.',
        ],
        [
            'title' => 'Customer Success Specialist',
            'job_type' => 'freelance',
            'skills' => ['Client Support', 'CRM', 'Onboarding', 'Communication'],
            'summary' => 'Drive customer onboarding, retention, and long-term account health.',
        ],
    ];

    /**
     * @var array<int, string>
     */
    private array $locations = [
        'Makati City, Metro Manila',
        'Taguig City, Metro Manila',
        'Cebu City, Cebu',
        'Davao City, Davao del Sur',
        'Iloilo City, Iloilo',
        'Clark, Pampanga',
        'Baguio City, Benguet',
        'Ortigas, Pasig City',
    ];

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

        // Normalize legacy seeded jobs so dashboards look realistic immediately.
        $this->refreshLegacyRecruiterJobs($recruiterIds);

        $this->topUpJobsForStatus('approved', 180, $recruiterIds);
        $this->topUpJobsForStatus('pending', 30, $recruiterIds);
        $this->topUpJobsForStatus('draft', 20, $recruiterIds);
        $this->topUpJobsForStatus('closed', 10, $recruiterIds);
    }

    private function refreshLegacyRecruiterJobs(array $recruiterIds): void
    {
        $jobs = Job::query()
            ->whereIn('recruiter_id', $recruiterIds)
            ->orderBy('id')
            ->get();

        if ($jobs->isEmpty()) {
            return;
        }

        $profileCount = count($this->jobProfiles);
        $locationCount = count($this->locations);
        $knownTitles = array_column($this->jobProfiles, 'title');

        foreach ($jobs as $index => $job) {
            $hasLegacyTitle = ! in_array($job->title, $knownTitles, true);
            $hasLegacyLocation = ! in_array($job->location, $this->locations, true);

            if (! $hasLegacyTitle && ! $hasLegacyLocation) {
                continue;
            }

            $profile = $this->jobProfiles[$index % $profileCount];
            $salaryMin = 22000 + (($index % 12) * 4000);
            $salaryMax = $salaryMin + 24000 + (($index % 5) * 4000);

            $job->title = $profile['title'];
            $job->description = $profile['summary'].' Ideal candidates should be comfortable with fast-paced delivery and cross-functional collaboration.';
            $job->location = $this->locations[$index % $locationCount];
            $job->salary_min = $salaryMin;
            $job->salary_max = $salaryMax;
            $job->job_type = $profile['job_type'];
            $job->required_skills = $profile['skills'];

            if ($job->deadline === null) {
                $job->deadline = now()->addWeeks(($index % 10) + 2);
            }

            $job->save();
        }
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
