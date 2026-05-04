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

        // Create labeled dummy job seeker account.
        User::updateOrCreate(
            ['email' => 'jobseeker@example.com'],
            [
                'name' => 'Miguel Santos',
                'password' => Hash::make('password'),
                'role' => 'job_seeker',
                'active' => true,
                'email_verified_at' => now(),
            ]
        );

        // Create labeled dummy recruiter account.
        User::updateOrCreate(
            ['email' => 'recruiter@example.com'],
            [
                'name' => 'Angela Sy - Northstar Talent',
                'password' => Hash::make('password'),
                'role' => 'recruiter',
                'active' => true,
                'email_verified_at' => now(),
            ]
        );

        echo "Core dummy accounts created/verified:\n";
        echo "- Dummy Admin (Primary): admin@portfolio.ph\n";
        echo "- Dummy Admin (Backup): admin@portfolioph.com\n";
        echo "- Miguel Santos (Job Seeker): jobseeker@example.com\n";
        echo "- Angela Sy - Northstar Talent (Recruiter): recruiter@example.com\n";
        echo "Password: password\n";
    }
}
