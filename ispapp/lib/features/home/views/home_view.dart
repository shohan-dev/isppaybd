import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ispapp/core/config/constants/color.dart';
import 'package:ispapp/core/routes/app_routes.dart';
import 'package:ispapp/features/home/views/widgets/paymentChartPainter.dart';
import 'package:ispapp/features/home/views/widgets/realTimeChartPainter.dart';
import '../controllers/home_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: homeController.refreshDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Obx(
              () => Column(
                children: [
                  _buildHeaderSection(homeController, authController),
                  const SizedBox(height: 24),
                  _buildErrorMessage(homeController),
                  _buildMenuGrid(homeController),
                  const SizedBox(height: 24),
                  _buildAccountOverview(homeController),
                  const SizedBox(height: 24),
                  _buildUsageStats(homeController),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Header section with user info and navigation
  Widget _buildHeaderSection(
    HomeController homeController,
    AuthController authController,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.headerGradient,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Top Bar
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.borderWhite, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child:
                        homeController
                                    .currentUser
                                    .value
                                    ?.profileImage
                                    .isNotEmpty ==
                                true
                            ? Image.asset(
                              homeController.currentUser.value!.profileImage,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              color: AppColors.overlay20,
                              child: const Icon(
                                Icons.person,
                                size: 30,
                                color: AppColors.textWhite,
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homeController.userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      Text(
                        'Client User ID : ${homeController.userId}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textWhite70,
                        ),
                      ),
                      Text(
                        'Status : ${homeController.connectionStatus}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textWhite70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: AppColors.textWhite,
                    size: 28,
                  ),
                  onPressed:
                      () => Get.snackbar(
                        'Info',
                        'Notifications feature coming soon!',
                      ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: AppColors.textWhite,
                    size: 28,
                  ),
                  onPressed: () => authController.logout(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Package Info Cards
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.packages);
                  },
                  child: Expanded(
                    child: _buildInfoCard(
                      icon: Icons.router,
                      title: 'Packages',
                      value: homeController.packageName,
                      subtitle: '',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.schedule,
                    title: 'Expire Date',
                    value: homeController.getPackageExpireDate(),
                    subtitle: '',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Info card widget (header section)
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.overlay20,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.overlay20,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.textWhite, size: 20),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textWhite70,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Error message display widget
  Widget _buildErrorMessage(HomeController homeController) {
    if (homeController.errorMessage.value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.errorBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.errorBorder, width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.errorIcon,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    homeController.errorMessage.value,
                    style: const TextStyle(
                      color: AppColors.errorText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.errorIcon,
                    size: 18,
                  ),
                  onPressed: () => homeController.errorMessage.value = '',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Menu grid with payment and support cards
  Widget _buildMenuGrid(HomeController homeController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double spacing = 12;
          final double itemWidth = (constraints.maxWidth - spacing) / 2;
          final double itemHeight = 140;

          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: itemWidth / itemHeight,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              _buildMenuCard(
                title: 'Total Payment (৳)',
                value:
                    '৳${((double.tryParse(homeController.dynamicPaymentReceived.toString()) ?? 0) + (double.tryParse(homeController.dynamicPaymentPending.toString()) ?? 0)).toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                gradient: AppColors.totalPaymentGradient,
                onTap: () => Get.toNamed('/payment'),
              ),
              _buildMenuCard(
                title: 'Payment Successful (৳)',
                value: '৳${homeController.dynamicPaymentReceived}',
                icon: Icons.check_circle,
                gradient: AppColors.successGradient,
                onTap: () => Get.toNamed('/payment'),
              ),
              _buildMenuCard(
                title: 'Payment Pending (৳)',
                value: '৳${homeController.dynamicPaymentPending}',
                icon: Icons.pending_actions,
                gradient: AppColors.pendingGradient,
                onTap: () => Get.toNamed('/payment'),
              ),
              _buildMenuCard(
                title: 'Total Support Ticket',
                value: homeController.dynamicSupportTickets,
                icon: Icons.support_agent,
                gradient: AppColors.supportGradient,
                onTap: () => Get.toNamed('/support'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Individual menu card widget
  Widget _buildMenuCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
                Icon(icon, color: AppColors.textWhite70, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textWhite70,
              ),
            ),
            const Spacer(),
            Container(
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.overlay12,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.overlay18),
              ),
              child: const Center(
                child: Text(
                  'View Details',
                  style: TextStyle(
                    color: AppColors.textWhite70,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Account overview cards section
  Widget _buildAccountOverview(HomeController homeController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      icon: Icons.account_balance_wallet,
                      title: 'Received',
                      value: '৳${homeController.dynamicPaymentReceived}',
                      color: AppColors.receivedColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard(
                      icon: Icons.payment,
                      title: 'Pending',
                      value: '৳${homeController.dynamicPaymentPending}',
                      color: AppColors.pendingColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard(
                      icon: Icons.support_agent,
                      title: 'Tickets',
                      value: homeController.dynamicSupportTickets,
                      color: AppColors.ticketColor,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Overview card widget
  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Usage statistics section
  Widget _buildUsageStats(HomeController homeController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          // Usage cards row
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Expanded(
                    child: _buildUsageCard(
                      icon: Icons.file_upload,
                      title: 'Upload',
                      value:
                          '${homeController.uploadUsed.toStringAsFixed(1)} Gb',
                      color: AppColors.uploadColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUsageCard(
                      icon: Icons.access_time,
                      title: 'Uptime',
                      value: homeController.getUptimeValue(),
                      color: AppColors.uptimeColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUsageCard(
                      icon: Icons.file_download,
                      title: 'Download',
                      value:
                          '${homeController.downloadUsed.toStringAsFixed(1)} Gb',
                      color: AppColors.downloadColor,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          _buildRealTimeTrafficChart(homeController),
          const SizedBox(height: 20),
          _buildPaymentChart(homeController),
          const SizedBox(height: 20),
          _buildNewsSection(homeController),
        ],
      ),
    );
  }

  // Usage card widget
  Widget _buildUsageCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Real-time traffic chart widget
  Widget _buildRealTimeTrafficChart(HomeController homeController) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Real-time Traffic',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: homeController.toggleRealTimeMonitoring,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: homeController.trafficStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: homeController.trafficStatusColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: homeController.trafficStatusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          homeController.trafficStatusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: homeController.trafficStatusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Chart
            Expanded(
              child: CustomPaint(
                painter: RealTimeChartPainter(
                  homeController.realTimeChartData,
                  homeController.isTrafficHealthy,
                ),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 12),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTrafficLegend(
                  color: AppColors.trafficDownload,
                  label:
                      'Download: ${homeController.currentDownloadSpeed} ${homeController.trafficUnit}',
                ),
                _buildTrafficLegend(
                  color: AppColors.trafficUpload,
                  label:
                      'Upload: ${homeController.currentUploadSpeed} ${homeController.trafficUnit}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Traffic legend widget
  Widget _buildTrafficLegend({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Payment statistics chart widget
  Widget _buildPaymentChart(HomeController homeController) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Payment Report (Jan - Oct)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Chart
            Expanded(
              child: CustomPaint(
                painter: PaymentChartPainter(
                  homeController.getPaymentChartData(),
                ),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 12),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(
                  color: AppColors.paymentSuccessful,
                  label: 'Successful',
                ),
                _buildLegendItem(
                  color: AppColors.paymentPending,
                  label: 'Pending',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Legend item widget
  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // News section widget
  Widget _buildNewsSection(HomeController homeController) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Latest News & Updates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://via.placeholder.com/50x50/4A90E2/FFFFFF?text=ISP',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ISP News Update',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Latest updates coming soon...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '2025-10-12T17:20:35+0000',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
