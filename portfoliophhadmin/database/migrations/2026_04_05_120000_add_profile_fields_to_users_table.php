<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Add profile fields to users table for complete user profile support.
     *
     * Fields added:
     *   - username: Unique username for the user
     *   - full_name: Alternative to 'name' field
     *   - bio: User biography/description
     *   - avatar_path: Path to user's profile picture
     *   - phone_number: User's contact phone
     *   - location: User's location
     *   - website_url: User's portfolio/website URL
     *   - resume_path: Path to user's resume PDF
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('username')->unique()->nullable()->after('email');
            $table->string('full_name')->nullable()->after('username');
            $table->text('bio')->nullable()->after('full_name');
            $table->string('avatar_path')->nullable()->after('bio');
            $table->string('phone_number', 20)->nullable()->after('avatar_path');
            $table->string('location')->nullable()->after('phone_number');
            $table->string('website_url')->nullable()->after('location');
            $table->string('resume_path')->nullable()->after('website_url');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'username',
                'full_name',
                'bio',
                'avatar_path',
                'phone_number',
                'location',
                'website_url',
                'resume_path',
            ]);
        });
    }
};
