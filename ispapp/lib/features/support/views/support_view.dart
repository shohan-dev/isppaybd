import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/support_controller.dart';
import '../models/support_model.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final SupportController controller = Get.put(SupportController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Support & Tickets'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => controller.createNewTicket(),
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

        if (controller.tickets.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.tickets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final ticket = controller.tickets[index];
            return _buildTicketCard(ticket, context);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.createNewTicket(),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No Support Tickets',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Create a ticket if you need help',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(SupportTicketModel ticket, BuildContext context) {
    Color statusColor = _getStatusColor(ticket.status);
    Color priorityColor = _getPriorityColor(ticket.priority);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                // Priority Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.priority,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              ticket.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              ticket.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getCategoryIcon(ticket.category),
                        size: 16,
                        color: const Color(0xFF4A90E2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ticket.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatDate(ticket.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF9800),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const Color(0xFFFF9800);
      case 'in progress':
        return const Color(0xFF4A90E2);
      case 'resolved':
        return const Color(0xFF81C784);
      case 'closed':
        return const Color(0xFF757575);
      default:
        return const Color(0xFF757575);
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFE57373);
      case 'medium':
        return const Color(0xFFFFB74D);
      case 'low':
        return const Color(0xFF81C784);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technical':
        return Icons.build;
      case 'billing':
        return Icons.payment;
      case 'general':
        return Icons.help;
      default:
        return Icons.support;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    }
  }
}
