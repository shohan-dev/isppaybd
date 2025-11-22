import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/constants/api.dart';
import '../../../core/helpers/network_helper.dart';
import '../../../core/helpers/local_storage/storage_helper.dart';
import 'movie_server_model.dart';
import 'dart:developer' as developer;

class MovieServerController extends GetxController {
  final RxList<MovieServer> servers = <MovieServer>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServers();
  }

  Future<void> fetchServers() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = AppStorageHelper.get('user_id');
      final url = '${AppApi.baseUrl}movieservers?user_id=$userId';

      developer.log(
        'Fetching movie servers from: $url',
        name: 'MovieServerController',
      );

      final response = await AppNetworkHelper.get(url);

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map &&
            data['status'] == 'success' &&
            data['data'] is List) {
          final list =
              (data['data'] as List)
                  .map((e) => MovieServer.fromJson(e as Map<String, dynamic>))
                  .toList();
          servers.value = list;
        } else {
          errorMessage.value = 'Unexpected response format';
        }
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      developer.log(
        'Error fetching servers: $e',
        name: 'MovieServerController',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      Get.snackbar('Error', 'Invalid URL', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar(
          'Error',
          'Could not launch URL',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error launching URL: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
