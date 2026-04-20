<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'last_login_ip')) {
                $table->string('last_login_ip', 45)->nullable()->after('remember_token');
            }

            if (! Schema::hasColumn('users', 'last_user_agent')) {
                $table->text('last_user_agent')->nullable()->after('last_login_ip');
            }
        });

        Schema::table('applications', function (Blueprint $table) {
            if (! Schema::hasColumn('applications', 'source')) {
                $table->string('source')->nullable()->after('status');
            }

            if (! Schema::hasColumn('applications', 'device')) {
                $table->string('device')->nullable()->after('source');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('applications', function (Blueprint $table) {
            if (Schema::hasColumn('applications', 'device')) {
                $table->dropColumn('device');
            }

            if (Schema::hasColumn('applications', 'source')) {
                $table->dropColumn('source');
            }
        });

        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'last_user_agent')) {
                $table->dropColumn('last_user_agent');
            }

            if (Schema::hasColumn('users', 'last_login_ip')) {
                $table->dropColumn('last_login_ip');
            }
        });
    }
};
