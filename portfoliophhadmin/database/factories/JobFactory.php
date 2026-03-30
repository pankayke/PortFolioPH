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
        $jobStatuses = ['open', 'closed'];

        return [
            'recruiter_id' => User::factory()->recruiter(),
            'title' => fake()->jobTitle(),
            'description' => fake()->sentences(5, true),
            'location' => fake()->city() . ', ' . fake()->state(),
            'salary_min' => fake()->numberBetween(25000, 75000),
            'salary_max' => fake()->numberBetween(80000, 150000),
            'job_type' => fake()->randomElement($jobTypes),
            'status' => fake()->randomElement($jobStatuses),
            'required_skills' => fake()->words(fake()->numberBetween(3, 6)),
            'deadline' => fake()->dateTimeBetween('+1 week', '+3 months'),
        ];
    }

    /**
     * Create an open job.
     */
    public function open(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'open',
            'deadline' => fake()->dateTimeBetween('+1 week', '+3 months'),
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
