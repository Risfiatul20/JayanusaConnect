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
        Schema::create('portfolios', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('title');
            $table->string('category'); // Skripsi, Aplikasi, Desain, Riset, dll
            $table->text('description');
            $table->string('file_url')->nullable(); // URL file karya
            $table->string('thumbnail_url')->nullable(); // URL thumbnail
            $table->string('demo_url')->nullable(); // URL demo jika aplikasi web
            $table->string('github_url')->nullable(); // URL repository GitHub
            $table->integer('likes')->default(0); // Jumlah likes
            $table->integer('views')->default(0); // Jumlah views
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('portfolios');
    }
};
