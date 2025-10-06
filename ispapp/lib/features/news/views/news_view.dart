import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/news_controller.dart';
import '../models/news_model.dart';

class NewsView extends StatelessWidget {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    final NewsController controller = Get.put(NewsController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('News & Events'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshNews(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshNews,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.newsList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final news = controller.newsList[index];
              return _buildNewsCard(news, context);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNewsCard(NewsModel news, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
              ),
              child:
                  news.imageUrl.isNotEmpty
                      ? Image.network(
                        news.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage(news.category);
                        },
                      )
                      : _buildPlaceholderImage(news.category),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    news.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  news.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),

                const SizedBox(height: 8),

                // Excerpt
                Text(
                  news.excerpt,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 16,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          news.author,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(news.publishedAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(String category) {
    IconData icon;
    Color color;

    switch (category.toLowerCase()) {
      case 'network updates':
        icon = Icons.wifi;
        color = const Color(0xFF4A90E2);
        break;
      case 'service updates':
        icon = Icons.speed;
        color = const Color(0xFF357ABD);
        break;
      case 'payment':
        icon = Icons.payment;
        color = const Color(0xFF81C784);
        break;
      case 'maintenance':
        icon = Icons.build;
        color = const Color(0xFFFFB74D);
        break;
      default:
        icon = Icons.article;
        color = const Color(0xFF4A90E2);
    }

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(color: color.withOpacity(0.1)),
      child: Center(child: Icon(icon, size: 60, color: color)),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    }
  }
}
