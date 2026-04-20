<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

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

        // Populate role-distributed dummy users for development/testing.
        $this->call(BulkUserSeeder::class);

        // Populate jobs and applications for realistic dashboard and workflow data.
        $this->call(BulkPlatformDataSeeder::class);

        // Create test job seeker
        User::updateOrCreate(
            ['email' => 'jobseeker@example.com'],
            [
                'name' => 'Test Job Seeker',
                'password' => Hash::make('password'),
                'role' => 'job_seeker',
                'active' => true,
                'email_verified_at' => now(),
            ]
        );

        // Create test recruiter
        User::updateOrCreate(
            ['email' => 'recruiter@example.com'],
            [
                'name' => 'Test Recruiter',
                'password' => Hash::make('password'),
                'role' => 'recruiter',
                'active' => true,
                'email_verified_at' => now(),
            ]
        );
    }
}
