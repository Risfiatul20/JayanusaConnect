<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('otp_verifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('phone', 20);           // nomor HP alumni
            $table->string('otp_code', 6);         // 6 digit OTP
            $table->boolean('is_verified')->default(false);
            $table->timestamp('expires_at');        // expired 30 menit
            $table->timestamp('verified_at')->nullable();
            $table->foreignId('verified_by')->nullable()->constrained('users')->onDelete('set null'); // admin yang verifikasi
            $table->timestamps();
        });

        // Tambah kolom is_verified & phone ke users untuk tracking status
        Schema::table('users', function (Blueprint $table) {
            $table->boolean('is_verified')->default(true)->after('role'); // default true untuk user lama
            $table->string('phone_verified', 20)->nullable()->after('phone');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('otp_verifications');
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['is_verified', 'phone_verified']);
        });
    }
};
