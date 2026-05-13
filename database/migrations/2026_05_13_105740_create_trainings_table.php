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
        Schema::create('trainings', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('category'); // AI, Cybersecurity, Programming, Design, dll
            $table->text('description');
            $table->integer('quota')->default(0); // Kuota peserta
            $table->integer('registered')->default(0); // Jumlah yang sudah daftar
            $table->dateTime('date'); // Tanggal & waktu pelatihan
            $table->string('location')->nullable(); // Lokasi pelatihan
            $table->string('instructor')->nullable(); // Nama instruktur
            $table->string('image_url')->nullable(); // Gambar banner pelatihan
            $table->enum('status', ['open', 'closed', 'completed'])->default('open');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('trainings');
    }
};
