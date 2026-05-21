<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Tambah role 'alumni' ke enum users
        DB::statement("ALTER TABLE users MODIFY COLUMN role ENUM('mahasiswa','admin_bem','super_admin','alumni') DEFAULT 'mahasiswa'");
    }

    public function down(): void
    {
        DB::statement("ALTER TABLE users MODIFY COLUMN role ENUM('mahasiswa','admin_bem','super_admin') DEFAULT 'mahasiswa'");
    }
};
