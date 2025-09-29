import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clientapp/core/config/constants/color.dart';
import 'package:clientapp/core/routes/app_routes.dart';
import 'package:clientapp/features/auth/controllers/auth_controller.dart';
import 'package:clientapp/features/dashboard/controllers/dashboard_controller.dart';
import 'package:clientapp/shared/widgets/stats_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController =
        Get.find<DashboardController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(context, authController),
      appBar: AppBar(
        title: const Text('User\'s Dashboard'),
        // actions: [
        //   TextButton.icon(
        //     onPressed: () {},
        //     icon: const Icon(Icons.home, size: 16),
        //     label: const Text('Home'),
        //     style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
        //   ),
        //   TextButton.icon(
        //     onPressed: () {},
        //     icon: const Icon(Icons.dashboard, size: 16),
        //     label: const Text('Dashboard'),
        //     style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
        //   ),
        // ],
      ),
      body: Obx(() {
        if (dashboardController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: dashboardController.refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.blueGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.dashboard,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome Back!',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Obx(
                                  () => Text(
                                    authController.currentUser.value?.name ??
                                        'User',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white70),
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

                // Stats Cards Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    StatsCard(
                      title: 'Total Payment (৳)',
                      value:
                          dashboardController.dashboardStats.value?.totalPayment
                              .toString() ??
                          '0',
                      icon: Icons.account_balance_wallet,
                      gradient: AppColors.blueGradient,
                      onTap: () => Get.toNamed(AppRoutes.payments),
                    ),
                    StatsCard(
                      title: 'Payment Successful (৳)',
                      value:
                          dashboardController
                              .dashboardStats
                              .value
                              ?.paymentSuccessful
                              .toString() ??
                          '0',
                      icon: Icons.check_circle,
                      gradient: AppColors.greenGradient,
                      onTap: () => Get.toNamed(AppRoutes.payments),
                    ),
                    StatsCard(
                      title: 'Payment Pending (৳)',
                      value:
                          dashboardController
                              .dashboardStats
                              .value
                              ?.paymentPending
                              .toString() ??
                          '0',
                      icon: Icons.pending,
                      gradient: AppColors.orangeGradient,
                      onTap: () => Get.toNamed(AppRoutes.payments),
                    ),
                    StatsCard(
                      title: 'Total Support Ticket',
                      value:
                          dashboardController
                              .dashboardStats
                              .value
                              ?.totalSupportTicket
                              .toString() ??
                          '0',
                      icon: Icons.support_agent,
                      gradient: AppColors.purpleGradient,
                      onTap: () => Get.toNamed(AppRoutes.support),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Network Usage Chart
                NetworkUsageChart(
                  usageData:
                      dashboardController.networkUsage
                          .map(
                            (usage) => {
                              'time': usage.time,
                              'rxBytes': usage.rxBytes,
                              'txBytes': usage.txBytes,
                            },
                          )
                          .toList(),
                ),

                const SizedBox(height: 24),

                // Current Package Info
                _buildCurrentPackageSection(dashboardController),

                const SizedBox(height: 100), // Bottom padding for navigation
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthController authController) {
    return Drawer(
      backgroundColor: AppColors.primary,
      child: Column(
        children: [
          // Drawer header
          Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.primaryVariant),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Text(
                    authController.currentUser.value?.name
                            .substring(0, 1)
                            .toUpperCase() ??
                        'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  authController.currentUser.value?.name ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () {
                    Get.back();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.inventory_2,
                  title: 'User\'s Packages',
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.packages);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.subscriptions,
                  title: 'My Subscription',
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.subscription);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.support_agent,
                  title: 'Support Tickets',
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.support);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.payment,
                  title: 'My Payment',
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.payments);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'My Profile',
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.profile);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.lock,
                  title: 'Change Password',
                  onTap: () {
                    Get.back();
                    // TODO: Navigate to change password screen
                  },
                ),
                const Divider(color: Colors.white24),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    Get.back();
                    authController.logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _buildCurrentPackageSection(DashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Package Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final user = controller.currentUser.value;
            if (user == null) return const SizedBox();

            return Column(
              children: [
                _buildInfoRow('Package', user.currentPackage),
                _buildInfoRow('Price', user.packagePrice),
                _buildInfoRow('Status', user.accStatus),
                _buildInfoRow('Expires', user.expireDate),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              Get.toNamed(AppRoutes.payments);
              break;
            case 2:
              Get.toNamed(AppRoutes.profile);
              break;
            case 3:
              Get.toNamed(AppRoutes.settings);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
