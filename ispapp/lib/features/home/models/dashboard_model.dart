class DashboardStats {
  final double uploadSpeed;
  final double downloadSpeed;
  final double uptime;
  final double uploadUsage;
  final double downloadUsage;
  final List<ChartData> usageChart;
  final List<NewsItem> recentNews;

  DashboardStats({
    required this.uploadSpeed,
    required this.downloadSpeed,
    required this.uptime,
    required this.uploadUsage,
    required this.downloadUsage,
    required this.usageChart,
    required this.recentNews,
  });
}

class ChartData {
  final DateTime date;
  final double upload;
  final double download;
  final int hour;

  ChartData({
    required this.date,
    required this.upload,
    required this.download,
    required this.hour,
  });
}

class NewsItem {
  final String id;
  final String title;
  final String description;
  final DateTime publishedAt;
  final String imageUrl;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.publishedAt,
    this.imageUrl = '',
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      publishedAt: DateTime.parse(
        json['published_at'] ?? DateTime.now().toIso8601String(),
      ),
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'published_at': publishedAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}
