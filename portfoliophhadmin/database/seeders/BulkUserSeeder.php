<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class BulkUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Keep these deterministic so local QA data size is predictable.
        $targetJobSeekerCount = 260;
        $targetRecruiterCount = 60;

        $this->topUpUsersForRole('job_seeker', $targetJobSeekerCount);
        $this->topUpUsersForRole('recruiter', $targetRecruiterCount);
    }

    private function topUpUsersForRole(string $role, int $targetCount): void
    {
        $currentCount = User::query()->where('role', $role)->count();
        $missing = max(0, $targetCount - $currentCount);

        if ($missing === 0) {
            return;
        }

        $now = now();
        $passwordHash = Hash::make('password');
        $timestampToken = $now->format('YmdHis');
        $rows = [];

        for ($i = 1; $i <= $missing; $i++) {
            $rows[] = [
                'name' => ucfirst(str_replace('_', ' ', $role))." Seed {$i}",
                'email' => "seed.{$role}.{$timestampToken}.{$i}@example.test",
                'email_verified_at' => $now,
                'password' => $passwordHash,
                'remember_token' => Str::random(10),
                'role' => $role,
                'active' => true,
                'created_at' => $now,
                'updated_at' => $now,
            ];
        }

        foreach (array_chunk($rows, 100) as $chunk) {
            User::query()->insert($chunk);
        }
    }
}
