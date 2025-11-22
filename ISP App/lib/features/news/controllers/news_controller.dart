import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/helpers/local_storage/storage_helper.dart';
import '../models/news_model.dart';

class NewsController extends GetxController {
  final RxList<NewsModel> newsList = <NewsModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxInt unseenCount = 0.obs;

  // Storage keys
  static const String _newsCacheKey = 'news_cache';
  static const String _seenNewsKey = 'seen_news_ids';
  final RxList<String> _seenIds = <String>[].obs;

  // Configure your base URL / image base here. Adjust if your backend uses another path.
  final String baseUrl = 'https://isppaybd.com/api';
  final String imageBase = 'https://isppaybd.com/assets/news/';

  final Dio _dio = Dio();

  @override
  void onInit() {
    super.onInit();
    _loadSeenStatus();
    _loadCachedNews();
    loadNews();
  }

  /// Load seen news IDs from local storage
  void _loadSeenStatus() {
    try {
      final List<dynamic>? storedIds = AppStorageHelper.get(_seenNewsKey);
      if (storedIds != null) {
        _seenIds.assignAll(storedIds.cast<String>());
      }
    } catch (e) {
      if (kDebugMode) print('Error loading seen status: $e');
    }
  }

  /// Load cached news from local storage
  void _loadCachedNews() {
    try {
      final String? cachedData = AppStorageHelper.get(_newsCacheKey);
      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        final List<NewsModel> cachedNews =
            decoded.map((e) => NewsModel.fromJson(e)).toList();
        newsList.value = cachedNews;
        _updateUnseenCount();
      }
    } catch (e) {
      if (kDebugMode) print('Error loading cached news: $e');
    }
  }

  /// Check if news is seen
  bool isNewsSeen(String id) => _seenIds.contains(id);

  /// Mark a news item as seen
  void markAsSeen(String newsId) {
    if (!_seenIds.contains(newsId)) {
      _seenIds.add(newsId);
      AppStorageHelper.put(_seenNewsKey, _seenIds.toList());
      _updateUnseenCount();
    }
  }

  /// Mark all news as seen
  void markAllAsSeen() {
    final allIds = newsList.map((n) => n.id).toList();
    _seenIds.assignAll(allIds);
    AppStorageHelper.put(_seenNewsKey, _seenIds.toList());
    _updateUnseenCount();
  }

  /// Calculate unseen news count
  void _updateUnseenCount() {
    int count = 0;
    for (var news in newsList) {
      if (!_seenIds.contains(news.id)) {
        count++;
      }
    }
    unseenCount.value = count;
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
          _updateUnseenCount();

          // Cache the news
          try {
            final String jsonString = jsonEncode(
              parsed.map((e) => e.toJson()).toList(),
            );
            AppStorageHelper.put(_newsCacheKey, jsonString);
          } catch (e) {
            print('Error caching news: $e');
          }
        } else {
          // Unexpected response shape
          // Don't clear list if we have cached data, just show error or keep old data?
          // For now, let's keep old data if fetch fails or returns bad format
          if (newsList.isEmpty) newsList.clear();
        }
      } else {
        if (newsList.isEmpty) newsList.clear();
      }
    } catch (e) {
      if (kDebugMode) print('News load error: $e');
      // Don't show snackbar on every load failure if we have cached data
      if (newsList.isEmpty) {
        Get.snackbar('Error', 'Failed to load news');
      }
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
