<?php

namespace Database\Factories;

use App\Models\Application;
use App\Models\Job;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Application>
 */
class ApplicationFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $statuses = ['pending', 'reviewed', 'shortlisted', 'rejected', 'accepted'];

        return [
            'user_id' => User::factory()->jobSeeker(),
            'job_id' => Job::factory(),
            'cover_letter' => fake()->sentences(10, true),
            'status' => fake()->randomElement($statuses),
        ];
    }

    /**
     * Create a pending application.
     */
    public function pending(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'pending',
        ]);
    }

    /**
     * Create an accepted application.
     */
    public function accepted(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'accepted',
        ]);
    }

    /**
     * Create a rejected application.
     */
    public function rejected(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'rejected',
        ]);
    }

    /**
     * Create a shortlisted application.
     */
    public function shortlisted(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'shortlisted',
        ]);
    }
}
