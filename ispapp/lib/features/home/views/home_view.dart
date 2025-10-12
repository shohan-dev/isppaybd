import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/dashboard_model.dart';

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
                  // Header Section
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
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
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
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
                                            homeController
                                                .currentUser
                                                .value!
                                                .profileImage,
                                            fit: BoxFit.cover,
                                          )
                                          : Container(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
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
                                      'Status : ${homeController.currentPackage.value?.status ?? 'Connected'}',
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
                                onPressed: () {
                                  Get.snackbar(
                                    'Info',
                                    'Notifications feature coming soon!',
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
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
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.router,
                                  title: 'Package',
                                  value:
                                      homeController
                                          .currentPackage
                                          .value
                                          ?.package
                                          .name ??
                                      '20MBPS',
                                  subtitle: '',
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
                  ),

                  const SizedBox(height: 24),

                  // Error Message Display
                  if (homeController.errorMessage.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
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
                              Icons.warning_amber,
                              color: Colors.orange[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Connection Issue',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Running in offline mode. Some data may be outdated.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: homeController.loadDashboardData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (homeController.errorMessage.value.isNotEmpty)
                    const SizedBox(height: 16),

                  // Menu Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _buildMenuCard(
                          color: const Color(0xFFE57373),
                          icon: Icons.router,
                          title: 'Internet\nPackages',
                          onTap: () => Get.toNamed('/packages'),
                        ),
                        _buildMenuCard(
                          color: const Color(0xFF64B5F6),
                          icon: Icons.article,
                          title: 'News\n& Event',
                          onTap: () => Get.toNamed('/news'),
                        ),
                        _buildMenuCard(
                          color: const Color(0xFF81C784),
                          icon: Icons.credit_card,
                          title: 'Payment\nHistory',
                          onTap: () => Get.toNamed('/payment'),
                        ),
                        _buildMenuCard(
                          color: const Color(0xFFFFB74D),
                          icon: Icons.chat_bubble,
                          title: 'Support\n& Ticket',
                          onTap: () => Get.toNamed('/support'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account Overview Cards
                  Padding(
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
                        Row(
                          children: [
                            Expanded(
                              child: _buildOverviewCard(
                                icon: Icons.account_balance_wallet,
                                title: 'Balance',
                                value: '৳${homeController.accountBalance}',
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildOverviewCard(
                                icon: Icons.payment,
                                title: 'Pending',
                                value: '${homeController.paymentPending}',
                                color: const Color(0xFFFF9800),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildOverviewCard(
                                icon: Icons.support_agent,
                                title: 'Tickets',
                                value: '${homeController.supportTickets}',
                                color: const Color(0xFF2196F3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Usage Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        // Upload, Uptime, Download Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildUsageCard(
                                icon: Icons.file_upload,
                                title: 'Upload',
                                value:
                                    '${homeController.currentPackage.value?.uploadUsed ?? 0.7} Gb',
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
                                    '${homeController.currentPackage.value?.downloadUsed ?? 16.7} Gb',
                                color: const Color(0xFF64B5F6),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Real-time Traffic Chart
                        Container(
                          width: double.infinity,
                          height: 280, // Increased height to accommodate header
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
                                // Real-time header
                                Row(
                                  children: [
                                    Text(
                                      'Real-time Traffic',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF424242),
                                      ),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap:
                                          homeController
                                              .toggleRealTimeMonitoring,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              homeController
                                                      .isRealTimeActive
                                                      .value
                                                  ? Colors.green.withOpacity(
                                                    0.1,
                                                  )
                                                  : Colors.grey.withOpacity(
                                                    0.1,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                homeController
                                                        .isRealTimeActive
                                                        .value
                                                    ? Colors.green
                                                    : Colors.grey,
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
                                                color:
                                                    homeController
                                                            .isRealTimeActive
                                                            .value
                                                        ? Colors.green
                                                        : Colors.grey,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              homeController
                                                      .isRealTimeActive
                                                      .value
                                                  ? 'LIVE'
                                                  : 'OFF',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    homeController
                                                            .isRealTimeActive
                                                            .value
                                                        ? Colors.green
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Chart area
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    child: CustomPaint(
                                      painter: RealTimeChartPainter(
                                        homeController.realTimeChartData,
                                        homeController.isRealTimeActive.value,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Legend
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF64B5F6),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Download: ${homeController.currentDownloadSpeed} ${homeController.trafficUnit}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF64B5F6),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF81C784),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Upload: ${homeController.currentUploadSpeed} ${homeController.trafficUnit}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF81C784),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // News Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
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
                              const Text(
                                'News And Events',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF424242),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: const DecorationImage(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'damaka',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF424242),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'coming.....soon',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF757575),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          '2025-09-24T14:37:46.527',
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
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required Color color,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Custom chart painter for usage visualization
class UsageChartPainter extends CustomPainter {
  final List<ChartData> data;

  UsageChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()..strokeWidth = 2;

    // Chart dimensions
    final double chartHeight = size.height - 40;
    final double chartWidth = size.width - 40;
    final double startX = 20;
    final double startY = 20;

    // Find max values for scaling
    double maxDownload = data
        .map((e) => e.download)
        .reduce((a, b) => a > b ? a : b);
    double maxUpload = data
        .map((e) => e.upload)
        .reduce((a, b) => a > b ? a : b);
    double maxValue = maxDownload > maxUpload ? maxDownload : maxUpload;

    if (maxValue == 0) maxValue = 100;

    // Draw grid lines
    paint.color = Colors.grey.withOpacity(0.3);
    paint.strokeWidth = 0.5;

    for (int i = 0; i <= 5; i++) {
      double y = startY + (chartHeight / 5) * i;
      canvas.drawLine(Offset(startX, y), Offset(startX + chartWidth, y), paint);
    }

    // Draw bars
    double barWidth = chartWidth / data.length * 0.8;
    double spacing = chartWidth / data.length * 0.2;

    for (int i = 0; i < data.length; i++) {
      double x = startX + (chartWidth / data.length) * i + spacing / 2;

      // Download bar (blue)
      double downloadHeight = (data[i].download / maxValue) * chartHeight;
      paint.color = const Color(0xFF64B5F6);
      canvas.drawRect(
        Rect.fromLTWH(
          x,
          startY + chartHeight - downloadHeight,
          barWidth * 0.5,
          downloadHeight,
        ),
        paint,
      );

      // Upload bar (green)
      double uploadHeight = (data[i].upload / maxValue) * chartHeight;
      paint.color = const Color(0xFF81C784);
      canvas.drawRect(
        Rect.fromLTWH(
          x + barWidth * 0.5,
          startY + chartHeight - uploadHeight,
          barWidth * 0.5,
          uploadHeight,
        ),
        paint,
      );
    }

    // Draw scale numbers
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 4; i++) {
      double value = maxValue - (maxValue / 4) * i;
      double y = startY + (chartHeight / 4) * i;

      textPainter.text = TextSpan(
        text: value.toInt().toString(),
        style: const TextStyle(color: Color(0xFF757575), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Real-time chart painter for live traffic visualization
class RealTimeChartPainter extends CustomPainter {
  final List<RealTimeChartData> data;
  final bool isLive;

  RealTimeChartPainter(this.data, this.isLive);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Chart dimensions
    final double chartHeight = size.height - 40;
    final double chartWidth = size.width - 40;
    final double startX = 20;
    final double startY = 20;

    if (data.isEmpty) {
      // Draw empty state
      paint.color = Colors.grey.withOpacity(0.3);
      paint.strokeWidth = 1;

      // Draw grid
      for (int i = 0; i <= 5; i++) {
        double y = startY + (chartHeight / 5) * i;
        canvas.drawLine(
          Offset(startX, y),
          Offset(startX + chartWidth, y),
          paint,
        );
      }

      // Draw "No Data" message
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = const TextSpan(
        text: 'Waiting for real-time data...',
        style: TextStyle(color: Color(0xFF757575), fontSize: 14),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
      return;
    }

    // Find max values for scaling
    double maxDownload = data
        .map((e) => e.download)
        .reduce((a, b) => a > b ? a : b);
    double maxUpload = data
        .map((e) => e.upload)
        .reduce((a, b) => a > b ? a : b);
    double maxValue = maxDownload > maxUpload ? maxDownload : maxUpload;

    if (maxValue == 0) maxValue = 10; // Minimum scale

    // Draw grid lines
    paint.color = Colors.grey.withOpacity(0.2);
    paint.strokeWidth = 0.5;
    paint.style = PaintingStyle.stroke;

    for (int i = 0; i <= 5; i++) {
      double y = startY + (chartHeight / 5) * i;
      canvas.drawLine(Offset(startX, y), Offset(startX + chartWidth, y), paint);
    }

    // Draw vertical time grid (every 10 seconds)
    for (int i = 0; i <= 6; i++) {
      double x = startX + (chartWidth / 6) * i;
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, startY + chartHeight),
        paint,
      );
    }

    // Prepare paths for smooth lines
    final downloadPath = Path();
    final uploadPath = Path();

    bool downloadPathStarted = false;
    bool uploadPathStarted = false;

    // Draw the real-time data as smooth lines
    for (int i = 0; i < data.length; i++) {
      double x = startX + (chartWidth / (data.length - 1)) * i;

      // Download line
      double downloadY =
          startY + chartHeight - (data[i].download / maxValue) * chartHeight;
      if (!downloadPathStarted) {
        downloadPath.moveTo(x, downloadY);
        downloadPathStarted = true;
      } else {
        downloadPath.lineTo(x, downloadY);
      }

      // Upload line
      double uploadY =
          startY + chartHeight - (data[i].upload / maxValue) * chartHeight;
      if (!uploadPathStarted) {
        uploadPath.moveTo(x, uploadY);
        uploadPathStarted = true;
      } else {
        uploadPath.lineTo(x, uploadY);
      }
    }

    // Draw download line
    paint.color = const Color(0xFF64B5F6);
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    if (downloadPathStarted) {
      canvas.drawPath(downloadPath, paint);
    }

    // Draw upload line
    paint.color = const Color(0xFF81C784);
    paint.strokeWidth = 3;
    if (uploadPathStarted) {
      canvas.drawPath(uploadPath, paint);
    }

    // Draw data points
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < data.length; i++) {
      double x = startX + (chartWidth / (data.length - 1)) * i;

      // Download point
      double downloadY =
          startY + chartHeight - (data[i].download / maxValue) * chartHeight;
      paint.color = const Color(0xFF64B5F6);
      canvas.drawCircle(Offset(x, downloadY), 3, paint);

      // Upload point
      double uploadY =
          startY + chartHeight - (data[i].upload / maxValue) * chartHeight;
      paint.color = const Color(0xFF81C784);
      canvas.drawCircle(Offset(x, uploadY), 3, paint);
    }

    // Draw current values if live
    if (isLive && data.isNotEmpty) {
      final lastData = data.last;
      double lastX = startX + chartWidth;

      // Pulse effect for live data
      paint.color = Colors.red.withOpacity(0.6);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;

      double downloadY =
          startY + chartHeight - (lastData.download / maxValue) * chartHeight;
      double uploadY =
          startY + chartHeight - (lastData.upload / maxValue) * chartHeight;

      canvas.drawCircle(Offset(lastX - 10, downloadY), 8, paint);
      canvas.drawCircle(Offset(lastX - 10, uploadY), 8, paint);
    }

    // Draw scale numbers
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 4; i++) {
      double value = maxValue - (maxValue / 4) * i;
      double y = startY + (chartHeight / 4) * i;

      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: const TextStyle(color: Color(0xFF757575), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - 6));
    }

    // Draw time labels (last 60 seconds)
    for (int i = 0; i <= 6; i++) {
      double x = startX + (chartWidth / 6) * i;
      int secondsAgo = 60 - (i * 10);

      textPainter.text = TextSpan(
        text: '${secondsAgo}s',
        style: const TextStyle(color: Color(0xFF757575), fontSize: 9),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 10, startY + chartHeight + 5));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
