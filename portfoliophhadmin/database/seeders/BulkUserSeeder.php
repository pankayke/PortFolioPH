<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class BulkUserSeeder extends Seeder
{
    /**
     * Curated names make admin tables look more realistic during demos.
     *
     * @var array<string, list<string>>
     */
    private array $namePools = [
        'job_seeker' => [
            'Miguel Santos',
            'Andrea Dela Cruz',
            'Paolo Reyes',
            'Jessa Villanueva',
            'Carlo Bautista',
            'Patricia Mendoza',
            'Mark Angelo Navarro',
            'Aira Gonzales',
            'John Michael Ramos',
            'Camille Flores',
            'Renz Aquino',
            'Samantha Lim',
            'Kyle Fernandez',
            'Nicole Valdez',
            'Jared Castillo',
        ],
        'recruiter' => [
            'Angela Sy - Northstar Talent',
            'Rafael Co - HarborBridge HR',
            'Bea Garcia - Talently PH',
            'Marco Lim - VertexWorks Careers',
            'Trisha Ong - Brightlane People Ops',
            'Kevin Yu - Pinnacle Search Group',
            'Ivy Tan - Arcadia Hiring Desk',
            'Nico Chua - Eastline Workforce',
            'Louise Torres - PrimeScale Recruitment',
            'James Go - Bluepeak Talent Team',
            'Mara Santos - Firstwave Hiring',
            'Daniel Cruz - Metrocore Recruiters',
        ],
    ];

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
        $this->relabelExistingSeedUsersForRole($role);

        $currentCount = User::query()->where('role', $role)->count();
        $missing = max(0, $targetCount - $currentCount);

        if ($missing === 0) {
            return;
        }

        $now = now();
        $passwordHash = Hash::make('password');
        $timestampToken = $now->format('YmdHis');
        $rows = [];
        $namePool = $this->namePools[$role] ?? ['PortfolioPH User'];
        $poolSize = count($namePool);

        for ($i = 1; $i <= $missing; $i++) {
            $baseName = $namePool[($i - 1) % $poolSize];
            $displayName = $missing > $poolSize ? "{$baseName} #{$i}" : $baseName;

            $rows[] = [
                'name' => $displayName,
                'email' => $this->buildSeedEmail($role, $displayName, $timestampToken, $i),
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

    private function relabelExistingSeedUsersForRole(string $role): void
    {
        $seedUsers = User::query()
            ->where('role', $role)
            ->where('email', 'like', "seed.{$role}.%")
            ->orderBy('id')
            ->get(['id', 'name']);

        if ($seedUsers->isEmpty()) {
            return;
        }

        $namePool = $this->namePools[$role] ?? ['PortfolioPH User'];
        $poolSize = count($namePool);

        foreach ($seedUsers as $index => $seedUser) {
            $position = $index + 1;
            $baseName = $namePool[$index % $poolSize];
            $newName = $seedUsers->count() > $poolSize ? "{$baseName} #{$position}" : $baseName;

            if ($seedUser->name !== $newName) {
                User::query()->whereKey($seedUser->id)->update(['name' => $newName]);
            }
        }
    }

    private function buildSeedEmail(string $role, string $displayName, string $timestampToken, int $i): string
    {
        $normalizedName = mb_strtolower($displayName);
        $normalizedName = preg_replace('/[^a-z0-9]+/u', '.', $normalizedName) ?? 'user';
        $normalizedName = trim($normalizedName, '.');

        return "seed.{$role}.{$normalizedName}.{$timestampToken}.{$i}@example.test";
    }
}
