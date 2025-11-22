import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ispapp/core/config/constants/color.dart';
import 'package:url_launcher/url_launcher_string.dart';
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
        title: const Text('Notification & News'),
        backgroundColor: AppColors.primary,
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
              return Obx(() => _buildNewsCard(news, context, controller));
            },
          ),
        );
      }),
    );
  }

  Widget _buildNewsCard(
    NewsModel news,
    BuildContext context,
    NewsController controller,
  ) {
    final isSeen = controller.isNewsSeen(news.id);
    return InkWell(
      onTap: () async {
        controller.markAsSeen(news.id);
        try {
          if (news.url.isNotEmpty) {
            await launchUrlString(
              news.url,
              mode: LaunchMode.externalApplication,
            );
          }
        } catch (_) {}
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSeen ? Colors.white : const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left image (fixed width)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 110,
                    height: 82,
                    color: const Color(0xFF4A90E2).withOpacity(0.08),
                    child:
                        news.imageUrl.isNotEmpty
                            ? Image.network(
                              news.imageUrl,
                              fit: BoxFit.cover,
                              width: 110,
                              height: 82,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage(news.category);
                              },
                            )
                            : _buildPlaceholderImage(news.category),
                  ),
                ),
                if (!isSeen)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Right content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: title and small category badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          news.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          news.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Excerpt
                  Text(
                    news.excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF616161),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Footer: date and Read button
                  Row(
                    children: [
                      Text(
                        _formatDate(news.publishedAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF9800),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (news.url.isNotEmpty)
                        TextButton.icon(
                          onPressed: () async {
                            try {
                              await launchUrlString(
                                news.url,
                                mode: LaunchMode.externalApplication,
                              );
                            } catch (_) {}
                          },
                          icon: const Icon(
                            Icons.open_in_new,
                            size: 16,
                            color: Color(0xFFFF9800),
                          ),
                          label: const Text(
                            'Read',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            minimumSize: const Size(0, 0),
                            backgroundColor: Colors.orange.withOpacity(0.04),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
