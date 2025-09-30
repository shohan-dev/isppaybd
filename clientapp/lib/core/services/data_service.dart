import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DataService extends GetxService {
  Map<String, dynamic>? _dummyData;

  DataService() {
    // Initialize with default data immediately
    _dummyData = _getDefaultData();
    // Load from JSON asynchronously in the background
    loadDummyData();
  }

  Future<DataService> init() async {
    await loadDummyData();
    return this;
  }

  Future<void> loadDummyData() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/dummy_data.json',
      );
      _dummyData = json.decode(jsonString);
    } catch (e) {
      print('Error loading dummy data: $e');
      // Keep default data if loading fails
    }
  }

  Map<String, dynamic> get user => _dummyData?['user'] ?? {};
  List<dynamic> get packages => _dummyData?['packages'] ?? [];
  Map<String, dynamic> get dashboardStats =>
      _dummyData?['dashboardStats'] ?? {};
  List<dynamic> get networkUsage => _dummyData?['networkUsage'] ?? [];
  List<dynamic> get payments => _dummyData?['payments'] ?? [];
  List<dynamic> get supportTickets => _dummyData?['supportTickets'] ?? [];

  Map<String, dynamic> _getDefaultData() {
    return {
      "user": {
        "id": "1",
        "name": "Home",
        "email": "34003395@gmail.com",
        "mobile": "01709377556",
        "address": "BADDA BAZER ROAD",
        "serviceArea": "BADDA BAZER ROAD (1212)",
        "role": "CUSTOMER",
        "regAt": "18 Jul 2025, 09:35 pm",
        "updatedAt": "27 Sep 2025, 04:02 pm",
        "currentPackage": "10MB",
        "packagePrice": "500৳ - Monthly",
        "lastRenewed": "21.09.2025, 02:34 am",
        "expireDate": "10.10.2025, 02:57 am",
        "accStatus": "Active",
      },
      "dashboardStats": {
        "totalPayment": 500,
        "paymentSuccessful": 0,
        "paymentPending": 500,
        "totalSupportTicket": 0,
      },
      "packages": [],
      "networkUsage": [],
      "payments": [],
      "supportTickets": [],
    };
  }

  // Dummy authentication
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return email == "34003395@gmail.com" && password == "123456";
  }
}
