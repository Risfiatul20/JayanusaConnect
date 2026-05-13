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
        Schema::create('aspirations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('title');
            $table->text('content');
            $table->string('category')->nullable(); // Akademik, Fasilitas, BEM, dll
            $table->enum('status', ['dikirim', 'diproses', 'selesai'])->default('dikirim');
            $table->text('admin_notes')->nullable(); // Catatan dari admin
            $table->foreignId('handled_by')->nullable()->constrained('users')->onDelete('set null'); // Admin yang menangani
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('aspirations');
    }
};
