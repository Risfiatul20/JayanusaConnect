<?php

namespace Database\Seeders;

use App\Models\Alumni;
use App\Models\Aspiration;
use App\Models\BemProgram;
use App\Models\Job;
use App\Models\Portfolio;
use App\Models\Registration;
use App\Models\Training;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        // ── 1. USERS ──────────────────────────────────────────────────────────

        $superAdmin = User::create([
            'name'     => 'Super Admin JAYANUSA',
            'email'    => 'superadmin@jayanusa.ac.id',
            'password' => Hash::make('password123'),
            'role'     => 'super_admin',
            'phone'    => '081234567890',
            'prodi'    => 'Sistem Informasi',
        ]);

        $adminBem = User::create([
            'name'     => 'Admin BEM JAYANUSA',
            'email'    => 'admin.bem@jayanusa.ac.id',
            'password' => Hash::make('password123'),
            'role'     => 'admin_bem',
            'phone'    => '081234567891',
            'prodi'    => 'Sistem Informasi',
        ]);

        // 5 mahasiswa dengan data lengkap
        $mahasiswa = collect([
            [
                'name'     => 'Budi Santoso',
                'nim'      => '2021001',
                'email'    => 'budi@mahasiswa.jayanusa.ac.id',
                'angkatan' => '2021',
                'prodi'    => 'Sistem Informasi',
            ],
            [
                'name'     => 'Siti Rahayu',
                'nim'      => '2021002',
                'email'    => 'siti@mahasiswa.jayanusa.ac.id',
                'angkatan' => '2021',
                'prodi'    => 'Teknik Informatika',
            ],
            [
                'name'     => 'Ahmad Fauzi',
                'nim'      => '2022001',
                'email'    => 'ahmad@mahasiswa.jayanusa.ac.id',
                'angkatan' => '2022',
                'prodi'    => 'Sistem Informasi',
            ],
            [
                'name'     => 'Dewi Lestari',
                'nim'      => '2022002',
                'email'    => 'dewi@mahasiswa.jayanusa.ac.id',
                'angkatan' => '2022',
                'prodi'    => 'Manajemen Informatika',
            ],
            [
                'name'     => 'Rizky Pratama',
                'nim'      => '2023001',
                'email'    => 'rizky@mahasiswa.jayanusa.ac.id',
                'angkatan' => '2023',
                'prodi'    => 'Teknik Informatika',
            ],
        ])->map(fn ($data) => User::create(array_merge($data, [
            'password' => Hash::make('password123'),
            'role'     => 'mahasiswa',
            'phone'    => '08' . rand(100000000, 999999999),
        ])));

        // ── 2. BEM PROGRAMS ───────────────────────────────────────────────────

        $bemPrograms = collect([
            [
                'title'       => 'Pelatihan AI & Machine Learning 2024',
                'description' => 'Program pelatihan kecerdasan buatan untuk mahasiswa JAYANUSA bekerjasama dengan Google Developer.',
                'budget'      => 15000000,
                'realization' => 12500000,
                'progress'    => 85,
                'start_date'  => '2024-03-01',
                'end_date'    => '2024-06-30',
                'category'    => 'Pelatihan Teknologi',
            ],
            [
                'title'       => 'Dialog Mahasiswa & Pimpinan Kampus',
                'description' => 'Forum dialog terbuka antara mahasiswa dengan pimpinan kampus untuk menyampaikan aspirasi secara langsung.',
                'budget'      => 5000000,
                'realization' => 4800000,
                'progress'    => 100,
                'start_date'  => '2024-02-15',
                'end_date'    => '2024-02-15',
                'category'    => 'Aspirasi & Dialog',
            ],
            [
                'title'       => 'Career Fair JAYANUSA 2024',
                'description' => 'Pameran karir yang menghadirkan 20+ perusahaan mitra untuk membuka peluang kerja dan magang bagi mahasiswa.',
                'budget'      => 25000000,
                'realization' => 0,
                'progress'    => 30,
                'start_date'  => '2024-07-01',
                'end_date'    => '2024-07-03',
                'category'    => 'Jejaring Industri',
            ],
        ])->map(fn ($data) => BemProgram::create(array_merge($data, [
            'created_by' => $adminBem->id,
        ])));

        // ── 3. TRAININGS ──────────────────────────────────────────────────────

        $trainings = collect([
            [
                'title'       => 'Workshop Cybersecurity Dasar',
                'category'    => 'Cybersecurity',
                'description' => 'Pelatihan keamanan siber dasar mencakup ethical hacking, network security, dan vulnerability assessment.',
                'quota'       => 30,
                'registered'  => 0,
                'date'        => now()->addDays(14)->format('Y-m-d H:i:s'),
                'location'    => 'Lab Komputer 1, Gedung A JAYANUSA',
                'instructor'  => 'Ir. Budi Hacker, CEH',
                'status'      => 'open',
            ],
            [
                'title'       => 'Bootcamp Flutter Mobile Development',
                'category'    => 'Programming',
                'description' => 'Bootcamp intensif pengembangan aplikasi mobile menggunakan Flutter dan Dart selama 3 hari.',
                'quota'       => 25,
                'registered'  => 0,
                'date'        => now()->addDays(21)->format('Y-m-d H:i:s'),
                'location'    => 'Aula Kampus JAYANUSA',
                'instructor'  => 'Rizal Flutter, Google Developer Expert',
                'status'      => 'open',
            ],
            [
                'title'       => 'Pelatihan UI/UX Design dengan Figma',
                'category'    => 'Desain',
                'description' => 'Pelatihan desain antarmuka dan pengalaman pengguna menggunakan Figma dari dasar hingga mahir.',
                'quota'       => 20,
                'registered'  => 0,
                'date'        => now()->addDays(7)->format('Y-m-d H:i:s'),
                'location'    => 'Lab Multimedia JAYANUSA',
                'instructor'  => 'Sari Designer, Senior UI/UX at Tokopedia',
                'status'      => 'open',
            ],
        ])->map(fn ($data) => Training::create($data));

        // ── 4. PORTFOLIOS ─────────────────────────────────────────────────────

        Portfolio::create([
            'user_id'     => $mahasiswa[0]->id,
            'title'       => 'Sistem Informasi Manajemen Perpustakaan',
            'category'    => 'Aplikasi',
            'description' => 'Aplikasi web untuk manajemen perpustakaan kampus menggunakan Laravel dan Vue.js. Fitur: katalog buku, peminjaman, pengembalian, dan laporan.',
            'github_url'  => 'https://github.com/example/perpustakaan',
            'demo_url'    => 'https://perpustakaan-demo.example.com',
            'likes'       => 12,
            'views'       => 45,
        ]);

        Portfolio::create([
            'user_id'     => $mahasiswa[1]->id,
            'title'       => 'Analisis Sentimen Media Sosial dengan Python',
            'category'    => 'Riset',
            'description' => 'Penelitian analisis sentimen komentar media sosial menggunakan algoritma LSTM dan BERT untuk klasifikasi opini publik.',
            'github_url'  => 'https://github.com/example/sentimen',
            'likes'       => 8,
            'views'       => 30,
        ]);

        Portfolio::create([
            'user_id'     => $mahasiswa[2]->id,
            'title'       => 'Desain UI/UX Aplikasi E-Commerce Lokal',
            'category'    => 'Desain',
            'description' => 'Rancangan antarmuka aplikasi e-commerce untuk UMKM lokal Pekanbaru dengan pendekatan user-centered design.',
            'demo_url'    => 'https://www.figma.com/example',
            'likes'       => 20,
            'views'       => 78,
        ]);

        // ── 5. JOBS ───────────────────────────────────────────────────────────

        Job::create([
            'title'         => 'Junior Web Developer',
            'company'       => 'PT. Teknologi Riau Digital',
            'type'          => 'kerja',
            'location'      => 'Pekanbaru, Riau',
            'description'   => 'Kami mencari Junior Web Developer yang bersemangat untuk bergabung dengan tim kami. Akan mengerjakan pengembangan aplikasi web berbasis Laravel dan React.',
            'requirements'  => "- Fresh graduate atau pengalaman 1 tahun\n- Menguasai PHP, Laravel, JavaScript\n- Memahami HTML, CSS, Bootstrap\n- Mampu bekerja dalam tim",
            'salary_range'  => 'Rp 4.000.000 - Rp 6.000.000',
            'deadline'      => now()->addDays(30)->format('Y-m-d'),
            'contact_email' => 'hr@teknologiriau.co.id',
            'apply_url'     => 'https://teknologiriau.co.id/karir',
            'status'        => 'active',
            'posted_by'     => $adminBem->id,
        ]);

        Job::create([
            'title'         => 'Magang Mobile Developer (Flutter)',
            'company'       => 'CV. Inovasi Digital Nusantara',
            'type'          => 'magang',
            'location'      => 'Pekanbaru, Riau (WFO)',
            'description'   => 'Program magang 3 bulan untuk mahasiswa aktif yang ingin belajar pengembangan aplikasi mobile menggunakan Flutter.',
            'requirements'  => "- Mahasiswa aktif semester 5 ke atas\n- Mengenal dasar Flutter/Dart\n- Bersedia WFO di Pekanbaru\n- Komitmen 3 bulan",
            'salary_range'  => 'Rp 1.500.000 - Rp 2.500.000 / bulan',
            'deadline'      => now()->addDays(20)->format('Y-m-d'),
            'contact_email' => 'rekrutmen@inovasidigi.id',
            'status'        => 'active',
            'posted_by'     => $adminBem->id,
        ]);

        Job::create([
            'title'         => 'Data Analyst Intern',
            'company'       => 'Bank Riau Kepri',
            'type'          => 'magang',
            'location'      => 'Pekanbaru, Riau',
            'description'   => 'Program magang analis data di divisi IT Bank Riau Kepri. Akan terlibat dalam pengolahan data nasabah dan pembuatan dashboard laporan.',
            'requirements'  => "- Mahasiswa aktif jurusan SI/TI/MI\n- Menguasai Excel, SQL dasar\n- Nilai IPK minimal 3.00\n- Berpenampilan rapi",
            'salary_range'  => 'Uang saku Rp 2.000.000 / bulan',
            'deadline'      => now()->addDays(15)->format('Y-m-d'),
            'contact_email' => 'magang@bankrk.co.id',
            'status'        => 'active',
            'posted_by'     => $adminBem->id,
        ]);

        // ── 6. ALUMNI ─────────────────────────────────────────────────────────

        $alumniList = collect([
            [
                'name'                    => 'Hendra Wijaya',
                'nim'                     => '2018001',
                'angkatan'                => '2018',
                'prodi'                   => 'Sistem Informasi',
                'profession'              => 'Software Engineer',
                'company'                 => 'Gojek Indonesia',
                'position'                => 'Backend Engineer',
                'email'                   => 'hendra.wijaya@gmail.com',
                'linkedin'                => 'https://linkedin.com/in/hendrawijaya',
                'bio'                     => 'Alumni JAYANUSA 2018, kini bekerja sebagai Backend Engineer di Gojek. Berpengalaman di Go, PHP, dan microservices.',
                'available_for_mentoring' => true,
            ],
            [
                'name'                    => 'Putri Handayani',
                'nim'                     => '2019001',
                'angkatan'                => '2019',
                'prodi'                   => 'Teknik Informatika',
                'profession'              => 'UI/UX Designer',
                'company'                 => 'Tokopedia',
                'position'                => 'Senior Product Designer',
                'email'                   => 'putri.handayani@gmail.com',
                'linkedin'                => 'https://linkedin.com/in/putrihandayani',
                'bio'                     => 'Desainer produk dengan 4 tahun pengalaman di industri e-commerce. Passionate tentang user research dan design thinking.',
                'available_for_mentoring' => true,
            ],
            [
                'name'                    => 'Doni Kurniawan',
                'nim'                     => '2019002',
                'angkatan'                => '2019',
                'prodi'                   => 'Sistem Informasi',
                'profession'              => 'Data Scientist',
                'company'                 => 'Telkom Indonesia',
                'position'                => 'Data Scientist',
                'email'                   => 'doni.kurniawan@gmail.com',
                'linkedin'                => 'https://linkedin.com/in/donikurniawan',
                'bio'                     => 'Data scientist dengan keahlian Python, machine learning, dan big data analytics. Aktif berbagi ilmu di komunitas data.',
                'available_for_mentoring' => false,
            ],
            [
                'name'                    => 'Rina Marlina',
                'nim'                     => '2020001',
                'angkatan'                => '2020',
                'prodi'                   => 'Manajemen Informatika',
                'profession'              => 'Project Manager',
                'company'                 => 'PT. Pertamina Digital',
                'position'                => 'IT Project Manager',
                'email'                   => 'rina.marlina@gmail.com',
                'linkedin'                => 'https://linkedin.com/in/rinamarlina',
                'bio'                     => 'Project manager berpengalaman di industri energi. Certified PMP dan Scrum Master.',
                'available_for_mentoring' => true,
            ],
            [
                'name'                    => 'Fajar Nugroho',
                'nim'                     => '2020002',
                'angkatan'                => '2020',
                'prodi'                   => 'Teknik Informatika',
                'profession'              => 'Mobile Developer',
                'company'                 => 'Startup Lokal Pekanbaru',
                'position'                => 'Lead Mobile Developer',
                'email'                   => 'fajar.nugroho@gmail.com',
                'linkedin'                => 'https://linkedin.com/in/fajarnugroho',
                'bio'                     => 'Flutter developer dengan 3 tahun pengalaman. Pernah publish 5 aplikasi di Play Store dan App Store.',
                'available_for_mentoring' => true,
            ],
        ])->map(fn ($data) => Alumni::create($data));

        // ── 7. ASPIRATIONS ────────────────────────────────────────────────────

        Aspiration::create([
            'user_id'     => $mahasiswa[0]->id,
            'title'       => 'Permohonan Penambahan Jam Akses Lab Komputer',
            'content'     => 'Kami mahasiswa semester 6 memohon agar jam akses lab komputer diperpanjang hingga pukul 21.00 WIB, terutama menjelang ujian akhir semester dan pengerjaan tugas akhir.',
            'category'    => 'Fasilitas',
            'status'      => 'diproses',
            'admin_notes' => 'Aspirasi sedang dikaji bersama pihak keamanan kampus.',
            'handled_by'  => $adminBem->id,
        ]);

        Aspiration::create([
            'user_id'  => $mahasiswa[1]->id,
            'title'    => 'Usulan Penambahan Mata Kuliah Kecerdasan Buatan',
            'content'  => 'Mengusulkan agar kurikulum ditambahkan mata kuliah AI/Machine Learning sebagai mata kuliah wajib, mengingat tingginya permintaan industri terhadap kompetensi ini.',
            'category' => 'Akademik',
            'status'   => 'dikirim',
        ]);

        Aspiration::create([
            'user_id'     => $mahasiswa[2]->id,
            'title'       => 'Perbaikan Koneksi WiFi di Gedung B',
            'content'     => 'Koneksi WiFi di Gedung B sangat tidak stabil, terutama di lantai 2 dan 3. Mohon segera diperbaiki karena mengganggu kegiatan belajar mengajar.',
            'category'    => 'Fasilitas',
            'status'      => 'selesai',
            'admin_notes' => 'Telah dilakukan penggantian access point di lantai 2 dan 3 Gedung B. Masalah sudah teratasi.',
            'handled_by'  => $adminBem->id,
        ]);

        Aspiration::create([
            'user_id'  => $mahasiswa[3]->id,
            'title'    => 'Permohonan Beasiswa Prestasi Akademik',
            'content'  => 'Mengusulkan agar BEM memperjuangkan penambahan kuota beasiswa prestasi akademik bagi mahasiswa dengan IPK di atas 3.5 yang berasal dari keluarga kurang mampu.',
            'category' => 'Beasiswa',
            'status'   => 'dikirim',
        ]);

        // ── 8. REGISTRATIONS ─────────────────────────────────────────────────

        // Mahasiswa daftar pelatihan
        Registration::create([
            'user_id'     => $mahasiswa[0]->id,
            'type'        => 'training',
            'training_id' => $trainings[0]->id,
            'status'      => 'approved',
        ]);
        $trainings[0]->increment('registered');

        Registration::create([
            'user_id'     => $mahasiswa[1]->id,
            'type'        => 'training',
            'training_id' => $trainings[1]->id,
            'status'      => 'pending',
        ]);
        $trainings[1]->increment('registered');

        Registration::create([
            'user_id'     => $mahasiswa[2]->id,
            'type'        => 'training',
            'training_id' => $trainings[0]->id,
            'status'      => 'pending',
        ]);
        $trainings[0]->increment('registered');

        // Mahasiswa daftar mentoring alumni
        Registration::create([
            'user_id'   => $mahasiswa[3]->id,
            'type'      => 'mentoring',
            'alumni_id' => $alumniList[0]->id,
            'status'    => 'approved',
            'message'   => 'Saya ingin belajar tentang backend development dan karir di perusahaan teknologi besar.',
        ]);

        Registration::create([
            'user_id'   => $mahasiswa[4]->id,
            'type'      => 'mentoring',
            'alumni_id' => $alumniList[4]->id,
            'status'    => 'pending',
            'message'   => 'Saya sedang belajar Flutter dan ingin mendapat bimbingan dari Kak Fajar yang sudah berpengalaman.',
        ]);

        $this->command->info('✅ Seeder selesai! Data dummy berhasil dibuat:');
        $this->command->info('   - Users     : ' . User::count() . ' (1 super_admin, 1 admin_bem, 5 mahasiswa)');
        $this->command->info('   - BEM Prog  : ' . BemProgram::count());
        $this->command->info('   - Trainings : ' . Training::count());
        $this->command->info('   - Portfolios: ' . Portfolio::count());
        $this->command->info('   - Jobs      : ' . Job::count());
        $this->command->info('   - Alumni    : ' . Alumni::count());
        $this->command->info('   - Aspirasi  : ' . Aspiration::count());
        $this->command->info('   - Registrasi: ' . Registration::count());
        $this->command->info('');
        $this->command->info('🔑 Login credentials:');
        $this->command->info('   Super Admin : superadmin@jayanusa.ac.id / password123');
        $this->command->info('   Admin BEM   : admin.bem@jayanusa.ac.id / password123');
        $this->command->info('   Mahasiswa   : budi@mahasiswa.jayanusa.ac.id / password123');
    }
}
