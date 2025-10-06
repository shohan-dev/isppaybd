import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/support_model.dart';

class SupportController extends GetxController {
  final RxList<SupportTicketModel> tickets = <SupportTicketModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  Future<void> loadTickets() async {
    isLoading.value = true;

    try {
      // Simulate API call with dummy data
      await Future.delayed(const Duration(seconds: 1));

      tickets.value = [
        SupportTicketModel(
          id: 'ticket_1',
          userId: 'user_1',
          title: 'Slow Internet Speed',
          description:
              'My internet connection has been very slow for the past few days.',
          status: 'Open',
          priority: 'Medium',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          category: 'Technical',
        ),
        SupportTicketModel(
          id: 'ticket_2',
          userId: 'user_1',
          title: 'Billing Issue',
          description: 'I was charged twice for this month\'s subscription.',
          status: 'In Progress',
          priority: 'High',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          category: 'Billing',
        ),
        SupportTicketModel(
          id: 'ticket_3',
          userId: 'user_1',
          title: 'Connection Problem',
          description: 'Internet keeps disconnecting randomly.',
          status: 'Resolved',
          priority: 'High',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          category: 'Technical',
        ),
      ];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load support tickets');
    } finally {
      isLoading.value = false;
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
