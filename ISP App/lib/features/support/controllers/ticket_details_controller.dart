import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../../core/config/constants/api.dart';
import '../../../core/helpers/network_helper.dart';
import '../../../core/helpers/local_storage/storage_helper.dart';
import '../models/support_model.dart';

class TicketDetailsController extends GetxController {
  final String ticketId;

  TicketDetailsController({required this.ticketId});

  final Rx<SupportTicketModel?> ticket = Rx<SupportTicketModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool canReply = false.obs;

  final TextEditingController messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadTicketDetails();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  Future<void> loadTicketDetails() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final endpoint = AppApi.supportTicketDetails + ticketId;
      developer.log(
        'Fetching ticket details from: $endpoint',
        name: 'TicketDetailsController',
      );

      final response = await AppNetworkHelper.get(endpoint);

      developer.log(
        'Response received: ${response.toString()}',
        name: 'TicketDetailsController',
      );

      if (response.success && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['details'] != null) {
          final ticketData = responseData['details'] as Map<String, dynamic>;
          developer.log(
            'Ticket data: ${ticketData.toString()}',
            name: 'TicketDetailsController',
          );

          ticket.value = SupportTicketModel.fromJson(ticketData);

          // Set canReply flag
          if (responseData['canReply'] != null) {
            canReply.value = responseData['canReply'] as bool;
          }

          developer.log(
            'Successfully loaded ticket #$ticketId',
            name: 'TicketDetailsController',
          );
          developer.log(
            'Messages count: ${ticket.value?.messages.length}',
            name: 'TicketDetailsController',
          );
          developer.log(
            'Can reply: ${canReply.value}',
            name: 'TicketDetailsController',
          );

          errorMessage.value = '';
        } else {
          errorMessage.value = 'Ticket details not found';
          developer.log(
            'Details field is null',
            name: 'TicketDetailsController',
          );
        }
      } else {
        errorMessage.value = response.message;
        developer.log(
          'Network error: ${errorMessage.value}',
          name: 'TicketDetailsController',
        );
      }
    } catch (e) {
      errorMessage.value = 'Error loading ticket details: $e';
      developer.log(
        'Exception in loadTicketDetails: $e',
        name: 'TicketDetailsController',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final message = messageController.text.trim();

    if (message.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    isSending.value = true;

    try {
      final userId = AppStorageHelper.get('user_id');
      if (userId == null || userId.toString().isEmpty) {
        Get.snackbar(
          'Error',
          'User ID not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Build the endpoint with query parameters
      final endpoint =
          '${AppApi.baseUrl}send_message?message=$message&current_user_id=$userId&ticket_id=$ticketId';

      developer.log(
        'Sending message to: $endpoint',
        name: 'TicketDetailsController',
      );

      final response = await AppNetworkHelper.post(endpoint);

      developer.log(
        'Send message response: ${response.toString()}',
        name: 'TicketDetailsController',
      );

      if (response.success) {
        // Clear the input field
        messageController.clear();

        // Show success message
        Get.snackbar(
          'Success',
          'Message sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Reload ticket details to show the new message
        await loadTicketDetails();
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      developer.log(
        'Exception in sendMessage: $e',
        name: 'TicketDetailsController',
      );
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSending.value = false;
    }
  }

  // Helper to check if message is from current user
  bool isUserMessage(String senderId) {
    final userId = AppStorageHelper.get('user_id');
    return senderId == userId.toString();
  }
}
