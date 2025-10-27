import 'dart:convert';
import 'dart:developer' as developer;

class SupportTicketModel {
  final String id;
  final String userId;
  final String adminIds;
  final String transfer;
  final String subject;
  final String category;
  final String priority;
  final List<SupportMessageModel> messages;
  final DateTime datetime;
  final String? remarks;
  final String viewed;
  final String status;

  SupportTicketModel({
    required this.id,
    required this.userId,
    required this.adminIds,
    required this.transfer,
    required this.subject,
    required this.category,
    required this.priority,
    required this.messages,
    required this.datetime,
    this.remarks,
    required this.viewed,
    required this.status,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    try {
      developer.log('Parsing ticket: ${json['id']}', name: 'SupportModel');

      // Parse details JSON string to get messages
      List<SupportMessageModel> messagesList = [];
      if (json['details'] != null && json['details'].toString().isNotEmpty) {
        try {
          final detailsJson = jsonDecode(json['details']);
          if (detailsJson is List) {
            messagesList =
                detailsJson
                    .map((msg) => SupportMessageModel.fromJson(msg))
                    .toList();
          }
        } catch (e) {
          developer.log('Error parsing details: $e', name: 'SupportModel');
        }
      }

      return SupportTicketModel(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        adminIds: json['admin_ids']?.toString() ?? '',
        transfer: json['transfer']?.toString() ?? '',
        subject: json['subject']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        priority: json['priority']?.toString() ?? '',
        messages: messagesList,
        datetime: _parseDateTime(json['datetime']?.toString()),
        remarks: json['remarks']?.toString(),
        viewed: json['viewed']?.toString() ?? 'no',
        status: json['status']?.toString() ?? '',
      );
    } catch (e) {
      developer.log('Error in fromJson: $e', name: 'SupportModel');
      rethrow;
    }
  }

  static DateTime _parseDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      developer.log('Error parsing date: $dateStr', name: 'SupportModel');
      return DateTime.now();
    }
  }

  // Helper getters
  bool get isOpened => status.toLowerCase() == 'opened';
  bool get isClosed => status.toLowerCase() == 'closed';
  bool get isViewed => viewed.toLowerCase() == 'yes';
  bool get isHighPriority => priority.toLowerCase() == 'high';
  bool get isMediumPriority => priority.toLowerCase() == 'medium';
  bool get isLowPriority => priority.toLowerCase() == 'low';

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(datetime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${datetime.day}-${datetime.month.toString().padLeft(2, '0')}-${datetime.year}';
    }
  }
}

class SupportMessageModel {
  final String sender;
  final String datetime;
  final String msg;

  SupportMessageModel({
    required this.sender,
    required this.datetime,
    required this.msg,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      sender: json['sender']?.toString() ?? '',
      datetime: json['datetime']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'sender': sender, 'datetime': datetime, 'msg': msg};
  }

  // Helper to check if message is from user
  bool isFromUser(String userId) {
    return sender == userId;
  }
}
