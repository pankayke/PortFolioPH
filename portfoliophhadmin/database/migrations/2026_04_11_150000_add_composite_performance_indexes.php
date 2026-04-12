<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        $driver = DB::connection()->getDriverName();

        Schema::table('jobs', function (Blueprint $table) use ($driver) {
            if (!$this->indexExists('jobs', 'jobs_status_created_at_index', $driver)) {
                $table->index(['status', 'created_at'], 'jobs_status_created_at_index');
            }

            if (!$this->indexExists('jobs', 'jobs_recruiter_id_status_created_at_index', $driver)) {
                $table->index(['recruiter_id', 'status', 'created_at'], 'jobs_recruiter_id_status_created_at_index');
            }
        });

        Schema::table('applications', function (Blueprint $table) use ($driver) {
            if (!$this->indexExists('applications', 'applications_user_id_created_at_index', $driver)) {
                $table->index(['user_id', 'created_at'], 'applications_user_id_created_at_index');
            }

            if (!$this->indexExists('applications', 'applications_job_id_status_created_at_index', $driver)) {
                $table->index(['job_id', 'status', 'created_at'], 'applications_job_id_status_created_at_index');
            }
        });

        if (Schema::hasColumn('users', 'role') && Schema::hasColumn('users', 'active')) {
            Schema::table('users', function (Blueprint $table) use ($driver) {
                if (!$this->indexExists('users', 'users_role_active_created_at_index', $driver)) {
                    $table->index(['role', 'active', 'created_at'], 'users_role_active_created_at_index');
                }
            });
        }
    }

    public function down(): void
    {
        $driver = DB::connection()->getDriverName();

        Schema::table('jobs', function (Blueprint $table) use ($driver) {
            if ($this->indexExists('jobs', 'jobs_status_created_at_index', $driver)) {
                $table->dropIndex('jobs_status_created_at_index');
            }

            if ($this->indexExists('jobs', 'jobs_recruiter_id_status_created_at_index', $driver)) {
                $table->dropIndex('jobs_recruiter_id_status_created_at_index');
            }
        });

        Schema::table('applications', function (Blueprint $table) use ($driver) {
            if ($this->indexExists('applications', 'applications_user_id_created_at_index', $driver)) {
                $table->dropIndex('applications_user_id_created_at_index');
            }

            if ($this->indexExists('applications', 'applications_job_id_status_created_at_index', $driver)) {
                $table->dropIndex('applications_job_id_status_created_at_index');
            }
        });

        if (Schema::hasColumn('users', 'role') && Schema::hasColumn('users', 'active')) {
            Schema::table('users', function (Blueprint $table) use ($driver) {
                if ($this->indexExists('users', 'users_role_active_created_at_index', $driver)) {
                    $table->dropIndex('users_role_active_created_at_index');
                }
            });
        }
    }

    private function indexExists(string $table, string $indexName, string $driver): bool
    {
        if ($driver === 'sqlite') {
            $indexes = DB::select("PRAGMA index_list($table)");
            return collect($indexes)->pluck('name')->contains($indexName);
        }

        if ($driver === 'mysql') {
            $indexes = DB::select("SHOW INDEXES FROM $table");
            return collect($indexes)->pluck('Key_name')->contains($indexName);
        }

        if ($driver === 'pgsql') {
            $indexes = DB::select('SELECT indexname FROM pg_indexes WHERE tablename = ?', [$table]);
            return collect($indexes)->pluck('indexname')->contains($indexName);
        }

        return false;
    }
};
