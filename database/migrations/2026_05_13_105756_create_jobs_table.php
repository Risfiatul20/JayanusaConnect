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
        Schema::create('jobs', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('company');
            $table->enum('type', ['kerja', 'magang']); // Jenis lowongan
            $table->string('location');
            $table->text('description');
            $table->text('requirements')->nullable();
            $table->string('salary_range')->nullable();
            $table->date('deadline')->nullable(); // Deadline pendaftaran
            $table->string('contact_email')->nullable();
            $table->string('contact_phone')->nullable();
            $table->string('apply_url')->nullable(); // URL untuk apply
            $table->string('logo_url')->nullable(); // Logo perusahaan
            $table->enum('status', ['active', 'closed'])->default('active');
            $table->foreignId('posted_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('jobs');
    }
};
