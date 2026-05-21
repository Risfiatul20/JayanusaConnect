class UserModel {
  final int id;
  final String name;
  final String? nim;
  final String email;
  final String role;
  final String? photo;
  final String? phone;
  final String? address;
  final String? angkatan;
  final String? prodi;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    this.nim,
    required this.email,
    required this.role,
    this.photo,
    this.phone,
    this.address,
    this.angkatan,
    this.prodi,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      nim: json['nim'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'mahasiswa',
      photo: json['photo'],
      phone: json['phone'],
      address: json['address'],
      angkatan: json['angkatan'],
      prodi: json['prodi'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nim': nim,
      'email': email,
      'role': role,
      'photo': photo,
      'phone': phone,
      'address': address,
      'angkatan': angkatan,
      'prodi': prodi,
      'created_at': createdAt,
    };
  }

  bool get isAdmin => role == 'admin_bem' || role == 'super_admin';
  bool get isSuperAdmin => role == 'super_admin';
  bool get isMahasiswa => role == 'mahasiswa';

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
