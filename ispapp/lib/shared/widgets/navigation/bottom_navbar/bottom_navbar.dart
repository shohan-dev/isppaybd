import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ispapp/shared/widgets/navigation/bottom_navbar/bottom_navbar_controller.dart';

class BottomNavBar extends StatelessWidget {
  BottomNavBar({super.key});
  final BottomNavBarController controller = Get.find();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();

  // Navigation items data
  static const _navItems = [
    _NavigationItem(Icons.home, "Home"),
    _NavigationItem(Icons.network_ping, "Ping"),
    _NavigationItem(Icons.payment, "Payment History"),
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    return Obx(() {
      return Scaffold(
        key: _scaffoldKey,
        appBar: null,
        body: SafeArea(
          bottom: false, // Handle bottom padding manually
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: PageView.builder(
              controller: _pageController,
              itemCount:
                  controller
                      .pages
                      .length, // Set item count to avoid excessive building
              physics:
                  const NeverScrollableScrollPhysics(), // Disable swipe to avoid conflicts
              onPageChanged: (index) {
                controller.currentIndex.value = index;
              },
              itemBuilder: (context, index) {
                return controller.pages[index]; // Efficient page building
              },
            ),
          ),
        ),
        bottomNavigationBar: _buildResponsiveBottomBar(context, bottomPadding),
      );
    });
  }

  Widget _buildResponsiveBottomBar(BuildContext context, double bottomPadding) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: (index) {
          controller.changeTab(index); // Use GetX to update tab index
          if (_pageController.page?.toInt() != index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(
                milliseconds: 250,
              ), // Faster animation duration
              curve: Curves.easeInOut,
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF282a35),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: _navItems.map((item) => _buildNavigationItem(item)).toList(),
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationItem(_NavigationItem item) {
    return BottomNavigationBarItem(
      icon: Icon(item.icon, size: 24),
      activeIcon: Icon(item.icon, size: 28),
      label: item.label,
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;

  const _NavigationItem(this.icon, this.label);
}
