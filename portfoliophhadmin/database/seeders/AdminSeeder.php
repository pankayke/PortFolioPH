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
            [
                'email' => 'admin@portfolio.ph',
                'name' => 'Dummy Admin (Primary)',
            ],
            [
                'email' => 'admin@portfolioph.com',
                'name' => 'Dummy Admin (Backup)',
            ],
        ];

        foreach ($adminAccounts as $account) {
            User::updateOrCreate(
                ['email' => $account['email']],
                [
                    'name' => $account['name'],
                    'password' => Hash::make('password'),
                    'role' => 'admin',
                    'active' => true,
                    'email_verified_at' => now(),
                ]
            );
        }

        echo "Admin dummy accounts created/verified:\n";
        echo "- Dummy Admin (Primary): admin@portfolio.ph\n";
        echo "- Dummy Admin (Backup): admin@portfolioph.com\n";
        echo "Password: password\n";
    }
}
