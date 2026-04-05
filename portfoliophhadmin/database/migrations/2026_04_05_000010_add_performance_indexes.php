<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        $driver = DB::connection()->getDriverName();
        
        Schema::table('jobs', function (Blueprint $table) use ($driver) {
            // ✅ Add indexes for pagination and filtering queries
            if (!$this->indexExists('jobs', 'jobs_status_index', $driver)) {
                $table->index('status');
            }
            if (!$this->indexExists('jobs', 'jobs_created_at_index', $driver)) {
                $table->index('created_at');
            }
            if (!$this->indexExists('jobs', 'jobs_recruiter_id_index', $driver)) {
                $table->index('recruiter_id');
            }
            if (!$this->indexExists('jobs', 'jobs_recruiter_id_status_index', $driver)) {
                $table->index(['recruiter_id', 'status']);
            }
        });

        Schema::table('applications', function (Blueprint $table) use ($driver) {
            // ✅ Add indexes for query performance
            if (!$this->indexExists('applications', 'applications_user_id_index', $driver)) {
                $table->index('user_id');
            }
            if (!$this->indexExists('applications', 'applications_job_id_index', $driver)) {
                $table->index('job_id');
            }
            if (!$this->indexExists('applications', 'applications_status_index', $driver)) {
                $table->index('status');
            }
            if (!$this->indexExists('applications', 'applications_created_at_index', $driver)) {
                $table->index('created_at');
            }
            if (!$this->indexExists('applications', 'applications_job_id_user_id_index', $driver)) {
                $table->index(['job_id', 'user_id']);
            }
        });

        Schema::table('users', function (Blueprint $table) use ($driver) {
            // ✅ Add indexes for authentication and search
            if (!$this->indexExists('users', 'users_email_index', $driver)) {
                $table->index('email');
            }
            if (!$this->indexExists('users', 'users_role_index', $driver)) {
                $table->index('role');
            }
        });
    }
    
    private function indexExists($table, $indexName, $driver): bool
    {
        if ($driver === 'sqlite') {
            $indexes = DB::select("PRAGMA index_list($table)");
            return collect($indexes)->pluck('name')->contains($indexName);
        } elseif ($driver === 'mysql') {
            $indexes = DB::select("SHOW INDEXES FROM $table");
            return collect($indexes)->pluck('Key_name')->contains($indexName);
        } elseif ($driver === 'pgsql') {
            $indexes = DB::select("SELECT indexname FROM pg_indexes WHERE tablename = ?", [$table]);
            return collect($indexes)->pluck('indexname')->contains($indexName);
        }
        return false;
    }

    public function down(): void
    {
        Schema::table('jobs', function (Blueprint $table) {
            $table->dropIndex(['status']);
            $table->dropIndex(['created_at']);
            $table->dropIndex(['recruiter_id']);
            $table->dropIndex(['recruiter_id', 'status']);
        });

        Schema::table('applications', function (Blueprint $table) {
            $table->dropIndex(['user_id']);
            $table->dropIndex(['job_id']);
            $table->dropIndex(['status']);
            $table->dropIndex(['created_at']);
            $table->dropIndex(['job_id', 'user_id']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['email']);
            $table->dropIndex(['role']);
        });
    }
};
