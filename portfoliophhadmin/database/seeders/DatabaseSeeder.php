<?php

namespace Database\Seeders;

use App\Models\Application;
use App\Models\Job;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Always ensure admin accounts exist first.
        $this->call(AdminSeeder::class);

        // Create test job seeker
        $jobSeeker = User::factory()->jobSeeker()->create([
            'name' => 'Test Job Seeker',
            'email' => 'jobseeker@example.com',
        ]);

        // Create test recruiter
        $recruiter = User::factory()->recruiter()->create([
            'name' => 'Test Recruiter',
            'email' => 'recruiter@example.com',
        ]);

        // Create additional users for testing
        User::factory(5)->jobSeeker()->create();
        User::factory(3)->recruiter()->create();

        // Create jobs posted by recruiter
        $jobs = Job::factory(8)
            ->for($recruiter, 'recruiter')
            ->create();

        // Create some applications
        foreach ($jobs->take(3) as $job) {
            Application::factory(5)->create([
                'job_id' => $job->id,
            ]);
        }
    }
}
