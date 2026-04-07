<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Ensure at least one admin account is always available.
        $adminAccounts = [
            'admin@portfolio.ph',
            'admin@portfolioph.com',
        ];

        foreach ($adminAccounts as $email) {
            User::updateOrCreate(
                ['email' => $email],
                [
                    'name' => 'Admin',
                    'password' => Hash::make('password'),
                    'role' => 'admin',
                    'active' => true,
                ]
            );
        }

        echo "Admin users created/verified:\n";
        echo "- admin@portfolio.ph\n";
        echo "- admin@portfolioph.com\n";
        echo "Password: password\n";
    }
}
