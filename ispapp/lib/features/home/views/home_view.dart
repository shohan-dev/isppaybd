import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      backgroundColor: Colors.grey[50],
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
          colors: [Color(0xFF282a35), Color(0xFF357ABD)],
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
                    border: Border.all(color: Colors.white, width: 2),
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
                              color: Colors.white.withOpacity(0.2),
                              child: const Icon(
                                Icons.person,
                                size: 35,
                                color: Colors.white,
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Client User ID : ${homeController.userId}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'Status : ${homeController.connectionStatus}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed:
                      () => Get.snackbar(
                        'Info',
                        'Notifications feature coming soon!',
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white, size: 28),
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
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
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
                    color: Colors.white70,
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
                    color: Colors.white,
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
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    homeController.errorMessage.value,
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.orange[600], size: 18),
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
                gradient: const [
                  Color.fromARGB(255, 45, 77, 219),
                  Color(0xFF6CB8F6),
                ],
                onTap: () => Get.toNamed('/payment'),
              ),
              _buildMenuCard(
                title: 'Payment Successful (৳)',
                value: '৳${homeController.dynamicPaymentReceived}',
                icon: Icons.check_circle,
                gradient: const [Color(0xFF16A34A), Color(0xFF34D399)],
                onTap: () => Get.toNamed('/payment'),
              ),
              _buildMenuCard(
                title: 'Payment Pending (৳)',
                value: '৳${homeController.dynamicPaymentPending}',
                icon: Icons.pending_actions,
                gradient: const [Color(0xFFF59E0B), Color(0xFFFCD34D)],
                onTap: () => Get.toNamed('/payment'),
              ),
              _buildMenuCard(
                title: 'Total Support Ticket',
                value: '${homeController.dynamicSupportTickets}',
                icon: Icons.support_agent,
                gradient: const [Color(0xFF7C3AED), Color(0xFF9F7AEA)],
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
              color: Colors.black.withOpacity(0.08),
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
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(icon, color: Colors.white70, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const Spacer(),
            Container(
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: const Center(
                child: Text(
                  'View Details',
                  style: TextStyle(
                    color: Colors.white70,
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
              color: Color(0xFF424242),
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
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard(
                      icon: Icons.payment,
                      title: 'Pending',
                      value: '৳${homeController.dynamicPaymentPending}',
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOverviewCard(
                      icon: Icons.support_agent,
                      title: 'Tickets',
                      value: homeController.dynamicSupportTickets,
                      color: const Color(0xFF2196F3),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
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
              color: Color(0xFF424242),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF757575),
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
                      color: const Color(0xFF64B5F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUsageCard(
                      icon: Icons.access_time,
                      title: 'Uptime',
                      value: homeController.getUptimeValue(),
                      color: const Color(0xFF4DB6AC),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUsageCard(
                      icon: Icons.file_download,
                      title: 'Download',
                      value:
                          '${homeController.downloadUsed.toStringAsFixed(1)} Gb',
                      color: const Color(0xFF64B5F6),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
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
              color: Color(0xFF424242),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF757575),
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
                    color: Color(0xFF424242),
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
                  color: const Color(0xFF64B5F6),
                  label:
                      'Download: ${homeController.currentDownloadSpeed} ${homeController.trafficUnit}',
                ),
                _buildTrafficLegend(
                  color: const Color(0xFF81C784),
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
                    color: Color(0xFF424242),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Last Updated',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
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
                  color: const Color(0xFF64B5F6),
                  label: 'Successful',
                ),
                _buildLegendItem(
                  color: const Color(0xFF81C784),
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
            color: Color(0xFF757575),
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
                color: Color(0xFF424242),
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
                          color: Color(0xFF424242),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Latest updates coming soon...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '2025-10-12T17:20:35+0000',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFFF9800),
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
