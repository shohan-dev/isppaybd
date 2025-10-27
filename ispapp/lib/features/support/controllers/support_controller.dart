import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../../core/config/constants/api.dart';
import '../../../core/helpers/network_helper.dart';
import '../../../core/helpers/local_storage/storage_helper.dart';
import '../models/support_model.dart';

class SupportController extends GetxController {
  final RxList<SupportTicketModel> tickets = <SupportTicketModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  Future<void> loadTickets() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = AppStorageHelper.get('user_id');
      if (userId == null || userId.toString().isEmpty) {
        errorMessage.value = 'User ID not found';
        developer.log('User ID is empty', name: 'SupportController');
        return;
      }

      final endpoint = AppApi.supportTickets + userId.toString();
      // final endpoint = AppApi.supportTickets + "10877";
      developer.log(
        'Fetching tickets from: $endpoint',
        name: 'SupportController',
      );

      final response = await AppNetworkHelper.get(endpoint);

      developer.log(
        'Response received: ${response.toString()}',
        name: 'SupportController',
      );

      if (response.success && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          developer.log(
            'Tickets count: ${data.length}',
            name: 'SupportController',
          );

          tickets.value =
              data
                  .map((json) {
                    try {
                      return SupportTicketModel.fromJson(json);
                    } catch (e) {
                      developer.log(
                        'Error parsing ticket: $e',
                        name: 'SupportController',
                      );
                      return null;
                    }
                  })
                  .whereType<SupportTicketModel>()
                  .toList();

          developer.log(
            'Successfully parsed ${tickets.length} tickets',
            name: 'SupportController',
          );

          // Sort by date, newest first
          tickets.sort((a, b) => b.datetime.compareTo(a.datetime));

          errorMessage.value = '';
        } else {
          errorMessage.value =
              responseData['response']?.toString() ?? 'Failed to load tickets';
          developer.log(
            'API error: ${errorMessage.value}',
            name: 'SupportController',
          );
        }
      } else {
        errorMessage.value = response.message;
        developer.log(
          'Network error: ${errorMessage.value}',
          name: 'SupportController',
        );
      }
    } catch (e) {
      errorMessage.value = 'Error loading tickets: $e';
      developer.log('Exception in loadTickets: $e', name: 'SupportController');
    } finally {
      isLoading.value = false;
    }
  }

  // Filter tickets
  List<SupportTicketModel> get filteredTickets {
    if (selectedFilter.value == 'all') {
      return tickets;
    } else if (selectedFilter.value == 'opened') {
      return tickets.where((t) => t.isOpened).toList();
    } else if (selectedFilter.value == 'closed') {
      return tickets.where((t) => t.isClosed).toList();
    }
    return tickets;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  // Get ticket statistics
  int get totalTickets => tickets.length;
  int get openedTickets => tickets.where((t) => t.isOpened).length;
  int get closedTickets => tickets.where((t) => t.isClosed).length;
  int get highPriorityTickets => tickets.where((t) => t.isHighPriority).length;

  void createNewTicket() {
    Get.dialog(
      AlertDialog(
        title: const Text('Create Support Ticket'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Success', 'Support ticket created successfully');
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
