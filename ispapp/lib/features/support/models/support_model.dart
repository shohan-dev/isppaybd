class SupportTicketModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String category;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final List<SupportMessageModel> messages;

  SupportTicketModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.createdAt,
    this.resolvedAt,
    this.messages = const [],
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
      category: json['category'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      messages: (json['messages'] as List? ?? [])
          .map((m) => SupportMessageModel.fromJson(m))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}

class SupportMessageModel {
  final String id;
  final String ticketId;
  final String message;
  final String senderType; // 'user' or 'admin'
  final DateTime createdAt;

  SupportMessageModel({
    required this.id,
    required this.ticketId,
    required this.message,
    required this.senderType,
    required this.createdAt,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: json['id'] ?? '',
      ticketId: json['ticket_id'] ?? '',
      message: json['message'] ?? '',
      senderType: json['sender_type'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'message': message,
      'sender_type': senderType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
