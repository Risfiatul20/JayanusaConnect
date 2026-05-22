class AppConstants {
  // API Base URL JAYANUSA Connect (Laravel backend kita)
  // EMULATOR Android  → 10.0.2.2 (alias localhost dari emulator)
  // HP Fisik          → IP laptop di jaringan yang sama
  // Ganti sesuai kebutuhan:
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  // static const String baseUrl = 'http://192.168.1.219:8000/api'; // HP fisik (IP terbaru)

  // API Kampus JAYANUSA (sistem voting/akademik eksternal)
  static const String kampusApiUrl = 'https://api.novinaldi.my.id/api';
  static const String kampusLoginEndpoint = '/login-voting';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';
  static const String nobpKey = 'auth_nobp'; // NOBP dari sistem kampus

  // Pagination
  static const int perPage = 10;

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // App Info
  static const String appName = 'JAYANUSA Connect';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Platform Digital BEM Kampus JAYANUSA';

  // Aspiration Status
  static const String statusDikirim = 'dikirim';
  static const String statusDiproses = 'diproses';
  static const String statusSelesai = 'selesai';

  // Registration Status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusCompleted = 'completed';

  // User Roles
  static const String roleMahasiswa = 'mahasiswa';
  static const String roleAdminBem = 'admin_bem';
  static const String roleSuperAdmin = 'super_admin';

  // Job Types
  static const String jobKerja = 'kerja';
  static const String jobMagang = 'magang';
  static const String jobBeasiswa = 'beasiswa';
  static const String jobKompetisi = 'kompetisi';

  // Training Status
  static const String trainingOpen = 'open';
  static const String trainingClosed = 'closed';
  static const String trainingCompleted = 'completed';
}
