import '../../features/auth/models/user_model.dart';
import '../../features/packages/models/package_model.dart';
import '../../features/payment/models/payment_model.dart';
import '../../features/support/models/support_model.dart';
import '../../features/news/models/news_model.dart';

class DummyDataService {
  // Dummy Users
  static List<UserModel> dummyUsers = [
    UserModel(
      userId: 'user_1',
      userRole: 'user',
      adminId: '369',
      clientCode: 'P0002',
      userName: 'jaman',
      fullName: 'Jaman Ahmed',
      email: 'jaman@ljbroadband.com',
      phone: '+8801712345678',
      address: 'Dhaka, Bangladesh',
      status: 'Connected',
      profileImage: 'assets/images/profile.jpg',
      createdAt: DateTime(2024, 1, 15),
      lastLogin: DateTime.now().subtract(Duration(hours: 2)),
    ),
    UserModel(
      userId: 'user_2',
      userRole: 'user',
      adminId: '369',
      clientCode: 'P0003',
      userName: 'sarah',
      fullName: 'Sarah Rahman',
      email: 'sarah@ljbroadband.com',
      phone: '+8801812345678',
      address: 'Chittagong, Bangladesh',
      status: 'Connected',
      createdAt: DateTime(2024, 2, 20),
      lastLogin: DateTime.now().subtract(Duration(hours: 5)),
    ),
  ];

  // Dummy Packages
  // static List<PackageModel> dummyPackages = [
  //   PackageModel(
  //     id: 'pkg_1',
  //     name: '20MBPS',
  //     speed: '20 Mbps',
  //     price: 1500.0,
  //     duration: '30 Days',
  //     description: 'High-speed internet for home use',
  //     isActive: true,
  //     validUntil: DateTime(2099, 12, 31),
  //     packageType: 'Residential',
  //     features: ['Unlimited Data', '24/7 Support', 'Free Installation'],
  //     dataLimit: 1000.0,
  //     dataUnit: 'GB',
  //   ),
  //   PackageModel(
  //     id: 'pkg_2',
  //     name: '50MBPS',
  //     speed: '50 Mbps',
  //     price: 3000.0,
  //     duration: '30 Days',
  //     description: 'Ultra-fast internet for power users',
  //     isActive: true,
  //     validUntil: DateTime(2099, 12, 31),
  //     packageType: 'Business',
  //     features: ['Unlimited Data', 'Priority Support', 'Static IP'],
  //     dataLimit: 2000.0,
  //     dataUnit: 'GB',
  //   ),
  //   PackageModel(
  //     id: 'pkg_3',
  //     name: '100MBPS',
  //     speed: '100 Mbps',
  //     price: 5000.0,
  //     duration: '30 Days',
  //     description: 'Enterprise-grade internet solution',
  //     isActive: true,
  //     validUntil: DateTime(2099, 12, 31),
  //     packageType: 'Enterprise',
  //     features: ['Unlimited Data', 'Dedicated Support', 'Multiple IPs'],
  //     dataLimit: 5000.0,
  //     dataUnit: 'GB',
  //   ),
  // ];

  // // Dummy User Packages
  // static List<UserPackageModel> dummyUserPackages = [
  //   UserPackageModel(
  //     id: 'up_1',
  //     userId: 'user_1',
  //     package: dummyPackages[0],
  //     startDate: DateTime(2024, 10, 1),
  //     endDate: DateTime(2024, 12, 31),
  //     uploadUsed: 0.7,
  //     downloadUsed: 16.7,
  //     status: 'Connected',
  //     totalUptime: 6.5, // 6 hours 29 minutes
  //   ),
  // ];

  // Dummy Payments
  static List<PaymentModel> dummyPayments = [
    PaymentModel(
      id: 'pay_1',
      userId: 'user_1',
      packageId: 'pkg_1',
      amount: 1500.0,
      paymentMethod: 'bKash',
      transactionId: 'BKA123456789',
      status: 'Completed',
      paymentDate: DateTime(2024, 10, 1),
      dueDate: DateTime(2024, 10, 31),
      description: '20MBPS Package - October 2024',
      invoiceNumber: 'INV-2024-001',
    ),
    PaymentModel(
      id: 'pay_2',
      userId: 'user_1',
      packageId: 'pkg_1',
      amount: 1500.0,
      paymentMethod: 'Nagad',
      transactionId: 'NAG987654321',
      status: 'Completed',
      paymentDate: DateTime(2024, 9, 1),
      dueDate: DateTime(2024, 9, 30),
      description: '20MBPS Package - September 2024',
      invoiceNumber: 'INV-2024-002',
    ),
  ];

  // Dummy Bills
  static List<BillModel> dummyBills = [
    BillModel(
      id: 'bill_1',
      userId: 'user_1',
      packageId: 'pkg_1',
      amount: 1500.0,
      billingPeriodStart: DateTime(2024, 11, 1),
      billingPeriodEnd: DateTime(2024, 11, 30),
      dueDate: DateTime(2024, 11, 15),
      status: 'Pending',
      isPaid: false,
    ),
  ];

  // Dummy Support Tickets
  static List<SupportTicketModel> dummySupportTickets = [
    SupportTicketModel(
      id: 'ticket_1',
      userId: 'user_1',
      title: 'Internet Connection Issue',
      description: 'My internet connection is very slow since yesterday.',
      status: 'Open',
      priority: 'Medium',
      category: 'Technical',
      createdAt: DateTime(2024, 10, 5),
      messages: [
        SupportMessageModel(
          id: 'msg_1',
          ticketId: 'ticket_1',
          message: 'My internet connection is very slow since yesterday.',
          senderType: 'user',
          createdAt: DateTime(2024, 10, 5),
        ),
        SupportMessageModel(
          id: 'msg_2',
          ticketId: 'ticket_1',
          message:
              'We are checking your connection. Please restart your router.',
          senderType: 'admin',
          createdAt: DateTime(2024, 10, 5, 10, 30),
        ),
      ],
    ),
    SupportTicketModel(
      id: 'ticket_2',
      userId: 'user_1',
      title: 'Package Upgrade Request',
      description: 'I want to upgrade to 50MBPS package.',
      status: 'Resolved',
      priority: 'Low',
      category: 'Billing',
      createdAt: DateTime(2024, 9, 20),
      resolvedAt: DateTime(2024, 9, 22),
      messages: [],
    ),
  ];

  // Dummy News
  static List<NewsModel> dummyNews = [
    NewsModel(
      id: 'news_1',
      title: 'New Package Launched: 100MBPS',
      content:
          'We are excited to announce our new 100MBPS package with unlimited data and dedicated support.',
      excerpt: 'New high-speed internet package now available',
      category: 'Product Update',
      publishedAt: DateTime(2024, 10, 1),
      author: 'ISP Broadband Team',
    ),
    NewsModel(
      id: 'news_2',
      title: 'Maintenance Schedule',
      content:
          'Scheduled maintenance will be performed on October 15, 2024 from 2:00 AM to 4:00 AM.',
      excerpt: 'Maintenance notification for all users',
      category: 'Maintenance',
      publishedAt: DateTime(2024, 10, 10),
      author: 'Technical Team',
    ),
  ];

  // Dummy Announcements
  static List<AnnouncementModel> dummyAnnouncements = [
    AnnouncementModel(
      id: 'ann_1',
      title: 'damaka',
      message: 'coming.....soon',
      type: 'info',
      createdAt: DateTime(2025, 9, 24, 14, 37, 46),
    ),
  ];

  // Authentication method
  static UserModel? authenticateUser(String clientCode, String password) {
    // Simple dummy authentication
    if (clientCode == 'P0002' && password == 'password123') {
      return dummyUsers.first;
    }
    return null;
  }

  // Get user by ID
  static UserModel? getUserById(String userId) {
    try {
      return dummyUsers.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Get user package
  // static UserPackageModel? getUserPackage(String userId) {
  //   try {
  //     return dummyUserPackages.firstWhere((up) => up.userId == userId);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // Get user payments
  static List<PaymentModel> getUserPayments(String userId) {
    return dummyPayments.where((payment) => payment.userId == userId).toList();
  }

  // Get user bills
  static List<BillModel> getUserBills(String userId) {
    return dummyBills.where((bill) => bill.userId == userId).toList();
  }

  // Get user support tickets
  static List<SupportTicketModel> getUserSupportTickets(String userId) {
    return dummySupportTickets
        .where((ticket) => ticket.userId == userId)
        .toList();
  }

  // Get all packages
  // static List<PackageModel> getAllPackages() {
  //   return dummyPackages;
  // }

  // Get all news
  static List<NewsModel> getAllNews() {
    return dummyNews;
  }

  // Get all announcements
  static List<AnnouncementModel> getAllAnnouncements() {
    return dummyAnnouncements;
  }
}
