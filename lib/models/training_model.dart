class TrainingModel {
  final int id;
  final String title;
  final String category;
  final String description;
  final int quota;
  final int registered;
  final String date;
  final String? location;
  final String? instructor;
  final String? imageUrl;
  final String status;
  final int? registrationsCount;

  TrainingModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.quota,
    required this.registered,
    required this.date,
    this.location,
    this.instructor,
    this.imageUrl,
    required this.status,
    this.registrationsCount,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'],
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      quota: json['quota'] ?? 0,
      registered: json['registered'] ?? 0,
      date: json['date'] ?? '',
      location: json['location'],
      instructor: json['instructor'],
      imageUrl: json['image_url'],
      status: json['status'] ?? 'open',
      registrationsCount: json['registrations_count'],
    );
  }

  double get quotaPercent => quota > 0 ? registered / quota : 0.0;
  int get remainingSlots => quota - registered;
  bool get isFull => registered >= quota;
  bool get isOpen => status == 'open';

  String get formattedDate {
    try {
      final dt = DateTime.parse(date);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return date;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'closed':    return 'Ditutup';
      case 'completed': return 'Selesai';
      default:          return 'Buka';
    }
  }
}
