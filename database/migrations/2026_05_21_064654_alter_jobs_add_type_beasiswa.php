<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Extend enum type jobs: tambah beasiswa & kompetisi
        DB::statement("ALTER TABLE jobs MODIFY COLUMN type ENUM('kerja','magang','beasiswa','kompetisi') NOT NULL");
    }

    public function down(): void
    {
        DB::statement("ALTER TABLE jobs MODIFY COLUMN type ENUM('kerja','magang') NOT NULL");
    }
};
