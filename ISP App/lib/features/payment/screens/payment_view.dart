import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ispapp/core/config/constants/color.dart';
import 'package:ispapp/core/helpers/local_storage/storage_helper.dart';
import '../../../core/config/constants/api.dart';
import 'payment_webview_screen.dart';
import '../controllers/payment_controller.dart';

class PaymentView extends StatelessWidget {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final PaymentController controller = Get.put(PaymentController());

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Payment History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.refreshPayments,
          ),
        ],
      ),
      body: Obx(() {
        // Show loading only when loading and no data
        if (controller.isLoading.value && controller.payments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error only when there's an error, no data, and not loading
        if (!controller.isLoading.value &&
            controller.errorMessage.value.isNotEmpty &&
            controller.payments.isEmpty) {
          return _buildErrorState(controller);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshPayments,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildStatisticsSection(controller),
                _buildFilterSection(controller),
                _buildPaymentList(controller),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatisticsSection(PaymentController controller) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.headerGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Transactions',
                      style: TextStyle(
                        color: AppColors.textWhite70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${controller.payments.length} Payments',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Paid',
                    '৳${controller.totalPaid.toStringAsFixed(0)}',
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pending',
                    '৳${controller.totalPending.toStringAsFixed(0)}',
                    Colors.orange,
                    Icons.pending,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    '${controller.payments.length}',
                    Colors.white,
                    Icons.receipt_long,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textWhite70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildFilterSection(PaymentController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            children:
                controller.filterOptions.map((filter) {
                  final isSelected = controller.selectedFilter.value == filter;
                  return GestureDetector(
                    onTap: () => controller.setFilter(filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : [
                                  BoxShadow(
                                    color: AppColors.shadowLight,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            filter.toUpperCase(),
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (filter != 'all') ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.white.withOpacity(0.3)
                                        : AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _getFilterCount(controller, filter).toString(),
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  int _getFilterCount(PaymentController controller, String filter) {
    switch (filter) {
      case 'successful':
        return controller.successfulCount;
      case 'pending':
        return controller.pendingCount;
      case 'failed':
        return controller.failedCount;
      default:
        return controller.payments.length;
    }
  }

  Widget _buildPaymentList(PaymentController controller) {
    return Obx(() {
      print('🎨 Building payment list...');
      print('🎨 Total payments: ${controller.payments.length}');
      print('🎨 Selected filter: ${controller.selectedFilter.value}');

      final filteredPayments = controller.filteredPayments;
      print('🎨 Filtered payments: ${filteredPayments.length}');

      if (filteredPayments.isEmpty) {
        print('⚠️ No filtered payments to display');
        return _buildEmptyState(controller.selectedFilter.value);
      }

      print('✅ Displaying ${filteredPayments.length} payment cards');
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: filteredPayments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final payment = filteredPayments[index];
          return _buildPaymentCard(payment);
        },
      );
    });
  }

  Widget _buildPaymentCard(payment) {
    // Build the tappable payment card. Tapping a pending payment opens the payment web page.
    final token = AppStorageHelper.get("token");
    return GestureDetector(
      onTap: () {
        try {
          if (payment.isPending) {
            // Prefer numeric invoice if present, otherwise use payment id
            final invoiceCandidate = payment.invoice?.toString() ?? '';
            final targetId =
                (invoiceCandidate.isNotEmpty &&
                        int.tryParse(invoiceCandidate) != null)
                    ? invoiceCandidate
                    : payment.id.toString();

            final url = '${AppApi.baseUrl}make-payment/$targetId';
            // final url = 'https://isppaybd.com/dashboard';
            Get.to(
              () => PaymentWebViewScreen(
                url: url,
                title: 'Make Payment',
                token: token ?? '',
              ),
            );
            return;
          }
          // If payment is successful, open the invoice in full webview
          if (payment.isSuccessful) {
            invoiceSection(payment, token);
          }
        } catch (e) {
          // ignore errors and allow normal tap behavior
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: payment.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    payment.paymentIcon,
                    color: payment.statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.invoice,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${payment.month} • ${payment.paidVia}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      payment.formattedAmount,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: payment.statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: payment.statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        payment.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: payment.statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.calendar_today,
                      'Paid Date',
                      payment.formattedDate,
                    ),
                  ),
                  Container(width: 1, height: 30, color: AppColors.borderLight),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.receipt,
                      'Amount',
                      '৳${payment.amount.toStringAsFixed(0)}',
                    ),
                  ),
                ],
              ),
            ),
            if (payment.methodTrx.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.tag,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Trx: ${payment.methodTrx}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(String filter) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Color(0xFFE0E0E0),
          ),
          const SizedBox(height: 16),
          Text(
            filter == 'all'
                ? 'No Payment History'
                : 'No ${filter.toUpperCase()} Payments',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            filter == 'all'
                ? 'Your payment history will appear here'
                : 'No ${filter} payments found',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(PaymentController controller) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load Payments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: controller.refreshPayments,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Open invoice in webview (no PDF conversion needed)
  void invoiceSection(payment, token) async {
    try {
      final invoiceCandidate = payment.invoice?.toString() ?? '';
      final invoiceId =
          (invoiceCandidate.isNotEmpty &&
                  int.tryParse(invoiceCandidate) != null)
              ? invoiceCandidate
              : payment.id.toString();

      final invoiceUrl = '${AppApi.baseUrl}invoice_print?invoice_id=$invoiceId';

      // Open invoice in full-screen webview
      Get.to(
        () => PaymentWebViewScreen(
          url: invoiceUrl,
          title: 'Invoice',
          token: token ?? '',
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to open invoice: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
