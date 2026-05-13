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
        Schema::create('alumni', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('nim', 20)->nullable();
            $table->string('angkatan', 4); // Tahun angkatan
            $table->string('prodi')->nullable(); // Program studi
            $table->string('profession')->nullable(); // Profesi saat ini
            $table->string('company')->nullable(); // Perusahaan tempat bekerja
            $table->string('position')->nullable(); // Jabatan
            $table->string('email')->nullable();
            $table->string('phone', 20)->nullable();
            $table->string('linkedin')->nullable(); // URL LinkedIn
            $table->string('photo_url')->nullable();
            $table->text('bio')->nullable(); // Biografi singkat
            $table->boolean('available_for_mentoring')->default(false);
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('set null'); // Link ke user jika alumni punya akun
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('alumni');
    }
};
