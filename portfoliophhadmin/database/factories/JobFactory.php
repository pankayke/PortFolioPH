<?php

namespace Database\Factories;

use App\Models\Job;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Job>
 */
class JobFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $jobTypes = ['full_time', 'part_time', 'contract', 'freelance'];
        $jobStatuses = ['draft', 'pending', 'approved', 'closed'];

        $jobProfiles = [
            [
                'title' => 'Frontend Developer (React)',
                'skills' => ['React', 'TypeScript', 'Tailwind CSS', 'REST APIs'],
                'summary' => 'Build responsive web interfaces and collaborate with product and backend teams.',
            ],
            [
                'title' => 'Backend Developer (Laravel)',
                'skills' => ['PHP', 'Laravel', 'MySQL', 'API Design'],
                'summary' => 'Design robust APIs, optimize queries, and maintain secure backend services.',
            ],
            [
                'title' => 'Mobile Developer (Flutter)',
                'skills' => ['Flutter', 'Dart', 'Firebase', 'State Management'],
                'summary' => 'Develop cross-platform mobile apps with clean architecture and test coverage.',
            ],
            [
                'title' => 'UI/UX Designer',
                'skills' => ['Figma', 'Wireframing', 'Design Systems', 'Usability Testing'],
                'summary' => 'Create user-centered flows, polished interfaces, and reusable design patterns.',
            ],
            [
                'title' => 'DevOps Engineer',
                'skills' => ['Docker', 'CI/CD', 'Nginx', 'AWS'],
                'summary' => 'Automate deployment pipelines and keep cloud environments scalable and stable.',
            ],
            [
                'title' => 'Data Analyst',
                'skills' => ['SQL', 'Power BI', 'Python', 'Data Visualization'],
                'summary' => 'Translate business questions into dashboards and actionable data insights.',
            ],
            [
                'title' => 'Technical Recruiter',
                'skills' => ['Talent Sourcing', 'Interviewing', 'ATS', 'Stakeholder Management'],
                'summary' => 'Source and manage top engineering talent pipelines for growing teams.',
            ],
            [
                'title' => 'Customer Success Specialist',
                'skills' => ['Client Support', 'CRM', 'Onboarding', 'Communication'],
                'summary' => 'Drive customer onboarding, retention, and long-term account health.',
            ],
        ];

        $cities = [
            'Makati City, Metro Manila',
            'Taguig City, Metro Manila',
            'Cebu City, Cebu',
            'Davao City, Davao del Sur',
            'Iloilo City, Iloilo',
            'Clark, Pampanga',
            'Baguio City, Benguet',
            'Ortigas, Pasig City',
        ];

        $profile = $jobProfiles[array_rand($jobProfiles)];
        $salaryMin = fake()->numberBetween(22000, 90000);
        $salaryMax = $salaryMin + fake()->numberBetween(12000, 70000);

        return [
            'recruiter_id' => User::factory()->recruiter(),
            'title' => $profile['title'],
            'description' => $profile['summary'].' Ideal candidates should be comfortable with fast-paced delivery and cross-functional collaboration.',
            'location' => $cities[array_rand($cities)],
            'salary_min' => $salaryMin,
            'salary_max' => $salaryMax,
            'job_type' => fake()->randomElement($jobTypes),
            'status' => fake()->randomElement($jobStatuses),
            'required_skills' => $profile['skills'],
            'deadline' => fake()->dateTimeBetween('+1 week', '+3 months'),
        ];
    }

    /**
     * Create an approved job.
     */
    public function approved(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'approved',
            'deadline' => fake()->dateTimeBetween('+1 week', '+3 months'),
        ]);
    }

    /**
     * Create a draft job.
     */
    public function draft(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'draft',
        ]);
    }

    /**
     * Create a pending job (awaiting review).
     */
    public function pending(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'pending',
        ]);
    }

    /**
     * Create a closed job.
     */
    public function closed(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'closed',
        ]);
    }

    /**
     * Create a full-time job.
     */
    public function fullTime(): static
    {
        return $this->state(fn (array $attributes) => [
            'job_type' => 'full_time',
        ]);
    }
}
