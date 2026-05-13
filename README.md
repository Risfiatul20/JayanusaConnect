# JAYANUSA Connect API

Platform Digital BEM Kampus JAYANUSA - Backend API

## 📱 Tentang Project

JAYANUSA Connect adalah aplikasi mobile berbasis Flutter dan Laravel API yang dirancang untuk menghubungkan mahasiswa, BEM, alumni, dan mitra industri dalam satu ekosistem digital terintegrasi.

### Visi
Mewujudkan JAYANUSA sebagai kampus yang progresif dan berdaya, yang menjamin setiap mahasiswa didengar, dibekali secara optimal, dan siap bersaing di dunia nyata.

## 🚀 Tech Stack

- **Framework**: Laravel 11
- **Database**: MySQL
- **Authentication**: Laravel Sanctum (Token-based)
- **API Format**: RESTful JSON API
- **PHP Version**: 8.3+

## 📦 Fitur Utama

### 5 Modul Terintegrasi:

1. **Aspirasi & Dialog** - Mahasiswa menyampaikan aspirasi dengan tracking status real-time
2. **Transparansi BEM** - Publikasi program kerja dan laporan anggaran BEM
3. **Pelatihan & Sertifikasi** - Katalog dan pendaftaran pelatihan teknologi
4. **Showcase Portofolio** - Platform publikasi karya akademik mahasiswa
5. **Jejaring Industri** - Info lowongan kerja, magang, dan direktori alumni

## 🗄️ Database Structure (8 Tables)

- `users` - Data pengguna (mahasiswa, admin BEM, super admin)
- `aspirations` - Aspirasi dan pengaduan mahasiswa
- `bem_programs` - Program kerja BEM
- `trainings` - Katalog pelatihan
- `portfolios` - Karya mahasiswa
- `jobs` - Lowongan kerja dan magang
- `alumni` - Direktori alumni
- `registrations` - Pendaftaran pelatihan & mentoring

## 🛠️ Installation

### Prerequisites
- PHP >= 8.3
- Composer
- MySQL
- Git

### Setup Steps

1. Clone repository
```bash
git clone https://github.com/Risfiatul20/JayanusaConnect.git
cd JayanusaConnect
```

2. Install dependencies
```bash
composer install
```

3. Setup environment
```bash
cp .env.example .env
php artisan key:generate
```

4. Configure database di `.env`
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=jayanusa_connect
DB_USERNAME=root
DB_PASSWORD=
```

5. Run migrations
```bash
php artisan migrate
```

6. Start development server
```bash
php artisan serve
```

API akan berjalan di `http://localhost:8000`

## 📚 API Documentation

### Authentication Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register mahasiswa baru |
| POST | `/api/auth/login` | Login pengguna |
| POST | `/api/auth/logout` | Logout (protected) |
| GET | `/api/auth/me` | Get user profile (protected) |

### Protected Endpoints (Require Bearer Token)

| Resource | Endpoints |
|----------|-----------|
| Aspirations | `/api/aspirations` (CRUD) |
| BEM Programs | `/api/bem-programs` (CRUD) |
| Trainings | `/api/trainings` (CRUD) |
| Portfolios | `/api/portfolios` (CRUD) |
| Jobs | `/api/jobs` (CRUD) |
| Alumni | `/api/alumni` (CRUD) |
| Registrations | `/api/registrations` (CRUD) |

### Special Endpoints

- `PUT /api/aspirations/{id}/status` - Update status aspirasi (admin)
- `POST /api/trainings/{id}/register` - Daftar pelatihan
- `POST /api/portfolios/{id}/like` - Like portfolio
- `PUT /api/registrations/{id}/status` - Update status registrasi (admin)

## 🔐 Authentication

API menggunakan Laravel Sanctum dengan Bearer Token:

```bash
# Login request
POST /api/auth/login
{
  "email": "mahasiswa@jayanusa.ac.id",
  "password": "password123"
}

# Response
{
  "success": true,
  "data": {
    "user": {...},
    "token": "1|xxxxxxxxxxxxx",
    "token_type": "Bearer"
  }
}

# Use token in headers
Authorization: Bearer 1|xxxxxxxxxxxxx
```

## 👥 User Roles

- **mahasiswa** - Mahasiswa (default role)
- **admin_bem** - Admin BEM
- **super_admin** - Super Admin Kampus

## 📝 Development Timeline

- **Week 1-2**: Backend setup + database structure ✅
- **Week 3-5**: API development (5 modules)
- **Week 6-7**: Flutter UI + API integration
- **Week 8**: Testing & documentation

## 🤝 Contributing

Project ini adalah tugas akhir mata kuliah Pemrograman Mobile.

**Developer**: Risfiatul  
**Dosen Pengampu**: Isnardi, M.Kom  
**Institusi**: STMIK/AMIK JAYANUSA  
**Tahun Akademik**: 2024/2025

## 📄 License

This project is developed for educational purposes.

---

**Repository**: [https://github.com/Risfiatul20/JayanusaConnect](https://github.com/Risfiatul20/JayanusaConnect)
