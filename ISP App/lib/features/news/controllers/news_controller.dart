import 'package:get/get.dart';
import '../models/news_model.dart';

class NewsController extends GetxController {
  final RxList<NewsModel> newsList = <NewsModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNews();
  }

  Future<void> loadNews() async {
    isLoading.value = true;

    try {
      // Simulate API call with dummy data
      await Future.delayed(const Duration(seconds: 1));

      newsList.value = [
        NewsModel(
          id: 'news_1',
          title: 'damaka',
          content:
              'Network upgrade coming soon with improved speed and reliability. We are working hard to enhance your internet experience.',
          excerpt: 'coming.....soon',
          imageUrl:
              'https://via.placeholder.com/400x200/4A90E2/FFFFFF?text=ISP+News',
          category: 'Network Updates',
          publishedAt: DateTime.parse('2025-09-24T14:37:46.527'),
          author: 'ISP Team',
        ),
        NewsModel(
          id: 'news_2',
          title: 'Speed Upgrade Available',
          content:
              'We have upgraded our network infrastructure to provide faster speeds to all our customers.',
          excerpt: 'Enjoy faster internet speeds',
          imageUrl:
              'https://via.placeholder.com/400x200/357ABD/FFFFFF?text=Speed+Upgrade',
          category: 'Service Updates',
          publishedAt: DateTime.now().subtract(const Duration(days: 2)),
          author: 'Technical Team',
        ),
        NewsModel(
          id: 'news_3',
          title: 'New Payment Options',
          content:
              'We now support multiple payment methods including mobile banking and digital wallets.',
          excerpt: 'More payment flexibility',
          imageUrl:
              'https://via.placeholder.com/400x200/81C784/FFFFFF?text=Payment+Update',
          category: 'Payment',
          publishedAt: DateTime.now().subtract(const Duration(days: 5)),
          author: 'Billing Team',
        ),
        NewsModel(
          id: 'news_4',
          title: 'Maintenance Schedule',
          content:
              'Scheduled maintenance will be performed on our servers to improve service quality.',
          excerpt: 'Upcoming maintenance notice',
          imageUrl:
              'https://via.placeholder.com/400x200/FFB74D/FFFFFF?text=Maintenance',
          category: 'Maintenance',
          publishedAt: DateTime.now().subtract(const Duration(days: 7)),
          author: 'Operations Team',
        ),
      ];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load news');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNews() async {
    isRefreshing.value = true;
    await loadNews();
    isRefreshing.value = false;
    Get.snackbar('Success', 'News refreshed successfully');
  }
}
