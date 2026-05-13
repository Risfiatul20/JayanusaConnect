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
        Schema::create('registrations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->enum('type', ['training', 'mentoring']); // Jenis registrasi
            $table->foreignId('training_id')->nullable()->constrained()->onDelete('cascade'); // Untuk training
            $table->foreignId('alumni_id')->nullable()->constrained('alumni')->onDelete('cascade'); // Untuk mentoring
            $table->enum('status', ['pending', 'approved', 'rejected', 'completed'])->default('pending');
            $table->text('message')->nullable(); // Pesan dari mahasiswa (untuk mentoring)
            $table->text('admin_notes')->nullable(); // Catatan admin
            $table->string('certificate_url')->nullable(); // URL sertifikat (untuk training)
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('registrations');
    }
};
