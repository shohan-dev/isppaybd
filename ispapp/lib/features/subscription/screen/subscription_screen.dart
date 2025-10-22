import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ispapp/core/config/constants/color.dart';
import '../controllers/subscription_controller.dart';
import '../models/subscription_model.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SubscriptionController controller = Get.put(SubscriptionController());

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Obx(
          () => Text(
            controller.subscription.value?.title ?? 'My Subscription',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Get.offAllNamed('/home'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.subscription.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.isLoading.value &&
            controller.errorMessage.value.isNotEmpty &&
            controller.subscription.value == null) {
          return _buildErrorState(controller);
        }

        if (controller.subscription.value == null) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshSubscription,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildSubscriptionStatusCard(controller),
                _buildCurrentPackageCard(controller),
                _buildAvailablePackagesSection(controller),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubscriptionStatusCard(SubscriptionController controller) {
    final subscription = controller.subscription.value!;
    final isActive = subscription.isActive;
    final daysRemaining = subscription.daysRemaining;
    final percentage = subscription.percentageRemaining;

    // Determine gradient colors based on status
    final gradientColors =
        isActive
            ? AppColors.headerGradient
            : [AppColors.error, AppColors.errorLight];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isActive ? AppColors.primaryLight : AppColors.error)
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.overlay20,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive ? Icons.check_circle_rounded : Icons.warning_rounded,
                  color: AppColors.textWhite,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isActive
                          ? 'Your subscription is up to date'
                          : 'Subscription Expired',
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${subscription.details.subscriptionStatus.toUpperCase()}',
                      style: const TextStyle(
                        color: AppColors.textWhite70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress bar with enhanced styling
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.overlay18,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: AppColors.borderLight, width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (percentage / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [AppColors.textWhite, AppColors.textWhite70],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.textWhite,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${percentage.toStringAsFixed(1)}% remains',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: AppColors.textWhite,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    daysRemaining > 0 ? '$daysRemaining days left' : 'Expired',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (daysRemaining >= 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.overlay12,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.textWhite,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You have $daysRemaining days left until your subscription expires',
                      style: const TextStyle(
                        color: AppColors.textWhite70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentPackageCard(SubscriptionController controller) {
    final subscription = controller.subscription.value!;
    final currentPackage = subscription.currentPackage;
    final details = subscription.details;

    if (currentPackage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.wifi,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Package',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentPackage.packageName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.speed,
                  'Bandwidth',
                  currentPackage.formattedBandwidth,
                ),
              ),
              Container(width: 1, height: 50, color: AppColors.borderLight),
              Expanded(
                child: _buildInfoItem(
                  Icons.payment,
                  'Price',
                  currentPackage.formattedPrice,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.calendar_today,
                  'Pricing',
                  currentPackage.pricingType.toUpperCase(),
                ),
              ),
              Container(width: 1, height: 50, color: AppColors.borderLight),
              Expanded(
                child: _buildInfoItem(
                  Icons.refresh,
                  'Last Renewed',
                  details.lastRenewed != null
                      ? '${details.lastRenewed!.day}/${details.lastRenewed!.month}/${details.lastRenewed!.year}'
                      : 'N/A',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Expire Date: ${details.willExpire != null ? "${details.willExpire!.day}/${details.willExpire!.month}/${details.willExpire!.year}" : "N/A"}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We\'ll send you notification before subscription expires',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAvailablePackagesSection(SubscriptionController controller) {
    final packages = controller.subscription.value?.packages ?? [];

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Select Package',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Choose from available packages',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: packages.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final package = packages[index];
              return _buildPackageCard(controller, package);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
    SubscriptionController controller,
    PackageModel package,
  ) {
    final isCurrent = controller.isCurrentPackage(package);
    final isUpgrade = controller.isUpgrade(package);

    return Obx(() {
      final isSelected = controller.selectedPackage.value?.id == package.id;

      return GestureDetector(
        onTap: () => controller.selectPackage(package),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isCurrent
                      ? AppColors.primary
                      : isSelected
                      ? AppColors.primary.withOpacity(0.5)
                      : AppColors.borderLight,
              width: isCurrent ? 2 : 1,
            ),
            boxShadow:
                isCurrent || isSelected
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isCurrent
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.wifi,
                  color: isCurrent ? Colors.white : AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          package.packageName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'CURRENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                        if (isUpgrade && !isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'UPGRADE',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.speed,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          package.formattedBandwidth,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.calendar_month,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          package.pricingType,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    package.formattedPrice,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          isCurrent ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '/${package.pricingType}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No Subscription Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please contact support to activate your subscription',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(SubscriptionController controller) {
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
              'Failed to Load Subscription',
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
              onPressed: controller.refreshSubscription,
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
}
