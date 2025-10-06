class NewsModel {
  final String id;
  final String title;
  final String content;
  final String excerpt;
  final String imageUrl;
  final String category;
  final DateTime publishedAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String author;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    this.imageUrl = '',
    required this.category,
    required this.publishedAt,
    this.updatedAt,
    this.isActive = true,
    required this.author,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      excerpt: json['excerpt'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
      publishedAt: DateTime.parse(
        json['published_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      isActive: json['is_active'] ?? true,
      author: json['author'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'image_url': imageUrl,
      'category': category,
      'published_at': publishedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
      'author': author,
    };
  }
}

class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'info', 'warning', 'urgent'
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'is_active': isActive,
    };
  }
}
