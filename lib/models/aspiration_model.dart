class AspirationModel {
  final int id;
  final int userId;
  final String title;
  final String content;
  final String? category;
  final String status; // dikirim | diproses | selesai
  final String? adminNotes;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? handler;

  AspirationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.category,
    required this.status,
    this.adminNotes,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.handler,
  });

  factory AspirationModel.fromJson(Map<String, dynamic> json) {
    return AspirationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'],
      status: json['status'] ?? 'dikirim',
      adminNotes: json['admin_notes'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? Map<String, dynamic>.from(json['user']) : null,
      handler: json['handler'] != null ? Map<String, dynamic>.from(json['handler']) : null,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'diproses': return 'Diproses';
      case 'selesai':  return 'Selesai';
      default:         return 'Dikirim';
    }
  }

  String get timeAgo {
    if (createdAt == null) return '';
    final dt = DateTime.tryParse(createdAt!);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
