import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/news_model.dart';

class NewsController extends GetxController {
  final RxList<NewsModel> newsList = <NewsModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  // Configure your base URL / image base here. Adjust if your backend uses another path.
  final String baseUrl = 'https://isppaybd.com/api';
  final String imageBase = 'https://isppaybd.com/assets/news/';

  final Dio _dio = Dio();

  @override
  void onInit() {
    super.onInit();
    loadNews();
  }

  /// Load news from API. Provide `userId` if you want a different user.
  Future<void> loadNews({String userId = '10854'}) async {
    isLoading.value = true;

    try {
      final url = '$baseUrl/news?user_id=$userId';
      print('Loading news from $url');
      final resp = await _dio.get(url);

      if (resp.statusCode == 200 && resp.data != null) {
        final data = resp.data;
        print(data);

        if (data is Map &&
            data['status'] == 'success' &&
            data['data'] is List) {
          final List items = data['data'];
          final List<NewsModel> parsed =
              items.map((item) {
                final Map<String, dynamic> j = Map<String, dynamic>.from(
                  item as Map,
                );

                final rawImage = (j['image'] ?? '').toString();
                final imageUrl =
                    rawImage.isEmpty
                        ? ''
                        : (rawImage.startsWith('http')
                            ? rawImage
                            : '$imageBase$rawImage');

                print('Parsed image URL: $imageUrl');

                final created = (j['created_at'] ?? '').toString();
                DateTime publishedAt;
                try {
                  // Some backends return `YYYY-MM-DD HH:MM:SS` — try to normalize
                  publishedAt = DateTime.parse(created.replaceFirst(' ', 'T'));
                } catch (_) {
                  publishedAt = DateTime.now();
                }

                final details = j['details']?.toString() ?? '';
                final excerpt =
                    details.length > 120
                        ? '${details.substring(0, 120)}...'
                        : details;

                return NewsModel(
                  id: j['id']?.toString() ?? '',
                  title: j['name']?.toString() ?? '',
                  content: details,
                  excerpt: excerpt,
                  imageUrl: imageUrl,
                  url: j['url']?.toString() ?? '',
                  category: j['category']?.toString() ?? 'General',
                  publishedAt: publishedAt,
                  author: j['admin_id']?.toString() ?? '',
                );
              }).toList();

          newsList.value = parsed;
        } else {
          // Unexpected response shape
          newsList.clear();
        }
      } else {
        newsList.clear();
      }
    } catch (e) {
      if (kDebugMode) print('News load error: $e');
      Get.snackbar('Error', 'Failed to load news');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNews({String userId = '10854'}) async {
    isRefreshing.value = true;
    await loadNews(userId: userId);
    isRefreshing.value = false;
  }

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }
}
