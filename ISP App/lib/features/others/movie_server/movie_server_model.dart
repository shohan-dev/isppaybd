class MovieServer {
  final String id;
  final String name;
  final String image;
  final String url;
  final String details;
  final String rating;
  final String createdAt;

  MovieServer({
    required this.id,
    required this.name,
    required this.image,
    required this.url,
    required this.details,
    required this.rating,
    required this.createdAt,
  });

  factory MovieServer.fromJson(Map<String, dynamic> json) {
    return MovieServer(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
