class UserModel {
  final int? id;
  final String name;
  final String? nim; // NIM dari backend kita
  final String? nobp; // NOBP dari sistem kampus
  final String email;
  final String role;
  final String? photo;
  final String? phone;
  final String? address;
  final String? angkatan;
  final String? prodi;
  final String? createdAt;

  // Flag untuk tahu user login via sistem kampus atau backend kita
  final bool isKampusLogin;

  UserModel({
    this.id,
    required this.name,
    this.nim,
    this.nobp,
    required this.email,
    required this.role,
    this.photo,
    this.phone,
    this.address,
    this.angkatan,
    this.prodi,
    this.createdAt,
    this.isKampusLogin = false,
  });

  /// Dari response backend Laravel kita
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      nim: json['nim'],
      nobp: json['nobp'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'mahasiswa',
      photo: json['photo'],
      phone: json['phone'],
      address: json['address'],
      angkatan: json['angkatan'],
      prodi: json['prodi'],
      createdAt: json['created_at'],
      isKampusLogin: false,
    );
  }

  /// Dari response API kampus JAYANUSA
  /// Response: {"nobp": "20101152610001", "nama": "NAMA MAHASISWA"}
  factory UserModel.fromKampusJson(Map<String, dynamic> json) {
    final nobp = json['nobp']?.toString() ?? '';
    return UserModel(
      id: null,
      name: json['nama'] ?? '',
      nim: nobp, // pakai NOBP sebagai NIM untuk display
      nobp: nobp,
      email: '$nobp@mahasiswa.jayanusa.ac.id', // email generated
      role: 'mahasiswa',
      isKampusLogin: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nim': nim,
      'nobp': nobp,
      'email': email,
      'role': role,
      'photo': photo,
      'phone': phone,
      'address': address,
      'angkatan': angkatan,
      'prodi': prodi,
      'created_at': createdAt,
      'is_kampus_login': isKampusLogin,
    };
  }

  bool get isAdmin => role == 'admin_bem' || role == 'super_admin';
  bool get isSuperAdmin => role == 'super_admin';
  bool get isMahasiswa => role == 'mahasiswa';

  /// Identifier utama user — NOBP jika dari kampus, NIM jika dari backend kita
  String get identifier => nobp ?? nim ?? '';

  String get displayRole {
    switch (role) {
      case 'admin_bem':
        return 'Admin BEM';
      case 'super_admin':
        return 'Super Admin';
      default:
        return 'Mahasiswa';
    }
  }
}
