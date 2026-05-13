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
        Schema::create('bem_programs', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->decimal('budget', 15, 2)->default(0); // Anggaran program
            $table->decimal('realization', 15, 2)->default(0); // Realisasi anggaran
            $table->integer('progress')->default(0); // Persentase progress 0-100
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->string('category')->nullable(); // Kategori program
            $table->string('document_url')->nullable(); // URL dokumen laporan PDF
            $table->foreignId('created_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bem_programs');
    }
};
