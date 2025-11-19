import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ispapp/core/config/constants/color.dart';
import '../controllers/ping_controller.dart';

class PingScreen extends StatelessWidget {
  const PingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PingController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.headerGradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.network_ping, size: 60, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'Network Ping Test',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Test your network connectivity',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Ping Results
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading user information...'),
                        ],
                      ),
                    );
                  }

                  if (controller.isPinging.value) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Running ping test...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This may take up to a minute',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.pingResponse.value != null) {
                    return _buildPingResults(controller);
                  }

                  return _buildInitialState();
                }),
              ),

              // Ping Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        controller.isPinging.value
                            ? null
                            : () => controller.runPingTest(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        controller.isPinging.value
                            ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Testing...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                            : const Text(
                              'Run Ping Test',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.network_check, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No ping test run yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to start',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPingResults(PingController controller) {
    final response = controller.pingResponse.value!;
    final packets = response.packets;
    final statusColor = Color(controller.getStatusColor());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.getPingStatus(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildStatRow(
                  'Host',
                  response.data.isNotEmpty ? response.data.first.host : 'N/A',
                ),
                const SizedBox(height: 12),
                _buildStatRow('Packets Sent', packets.sent.toString()),
                const SizedBox(height: 12),
                _buildStatRow('Packets Received', packets.received.toString()),
                const SizedBox(height: 12),
                _buildStatRow('Packet Loss', packets.loss),
                const SizedBox(height: 12),
                _buildStatRow('Average Latency', response.averageLatency),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Detailed Results
          const Text(
            'Detailed Results',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 12),

          // Ping Data List
          if (response.data.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    response.data.length > 10 ? 10 : response.data.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final ping = response.data[index];
                  final isTimeout = ping.isTimeout;

                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          isTimeout
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                      child: Icon(
                        isTimeout ? Icons.close : Icons.check,
                        size: 16,
                        color: isTimeout ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(
                      'Seq ${ping.seq}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Sent: ${ping.sent} | Received: ${ping.received}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isTimeout
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isTimeout ? 'Timeout' : ping.time ?? 'OK',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isTimeout ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          if (response.data.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Text(
                  'Showing 10 of ${response.data.length} results',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242),
          ),
        ),
      ],
    );
  }
}
