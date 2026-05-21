class AppConstants {
  // API Base URL - ganti sesuai IP komputer saat testing di device fisik
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // Web/iOS simulator
  // static const String baseUrl = 'http://192.168.1.x:8000/api'; // Device fisik (ganti IP)

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

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
