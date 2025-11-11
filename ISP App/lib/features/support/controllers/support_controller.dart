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

  // Create ticket method - POST request
  Future<bool> createTicket({
    required String subject,
    required String category,
    required String priority,
    required String message,
  }) async {
    try {
      final userId = AppStorageHelper.get('user_id');
      if (userId == null || userId.toString().isEmpty) {
        developer.log('User ID not found', name: 'SupportController');
        Get.snackbar(
          'Error',
          'User ID not found. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Create request model
      final request = CreateTicketRequest(
        userId: userId.toString(),
        subject: subject,
        category: category,
        priority: priority,
        message: message,
      );

      developer.log(
        'Creating ticket with data: ${request.toJson()}',
        name: 'SupportController',
      );

      // Make POST request
      final response = await AppNetworkHelper.post<Map<String, dynamic>>(
        AppApi.createTicket,
        data: request.toJson(),
      );

      developer.log(
        'Create ticket response: ${response.data}',
        name: 'SupportController',
      );

      if (response.success && response.data != null) {
        final ticketResponse = CreateTicketResponse.fromJson(response.data!);

        if (ticketResponse.success) {
          developer.log(
            'Ticket created successfully. ID: ${ticketResponse.ticketId}',
            name: 'SupportController',
          );

          Get.snackbar(
            'Success',
            ticketResponse.message.isNotEmpty
                ? ticketResponse.message
                : 'Support ticket created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          // Reload tickets to show the new one
          await loadTickets();
          return true;
        } else {
          Get.snackbar(
            'Failed',
            ticketResponse.message.isNotEmpty
                ? ticketResponse.message
                : 'Failed to create ticket',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return false;
        }
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      developer.log('Exception in createTicket: $e', name: 'SupportController');
      Get.snackbar(
        'Error',
        'Error creating ticket: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

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
