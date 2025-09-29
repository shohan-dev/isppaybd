import 'package:get/get.dart';
import 'package:clientapp/core/services/data_service.dart';
import 'package:clientapp/shared/models/user_model.dart';

class ProfileController extends GetxController {
  final DataService _dataService = Get.find<DataService>();

  final isLoading = false.obs;
  final currentUser = Rxn<User>();
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    isLoading.value = true;

    try {
      final userData = _dataService.user;
      if (userData.isNotEmpty) {
        currentUser.value = User.fromJson(userData);
      }
    } catch (e) {
      print('Error loading user profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
