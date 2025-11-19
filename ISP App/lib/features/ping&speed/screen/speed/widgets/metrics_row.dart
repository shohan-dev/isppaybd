import 'package:flutter/material.dart';
import 'metric_card.dart';

class MetricsRow extends StatelessWidget {
  final double downloadRate;
  final double uploadRate;
  final double ping;
  final String unitText;

  const MetricsRow({
    Key? key,
    required this.downloadRate,
    required this.uploadRate,
    required this.ping,
    required this.unitText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: MetricCard(
              icon: Icons.download,
              label: 'Download',
              value: downloadRate.toStringAsFixed(2),
              unit: unitText,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MetricCard(
              icon: Icons.upload,
              label: 'Upload',
              value: uploadRate.toStringAsFixed(2),
              unit: unitText,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MetricCard(
              icon: Icons.network_ping,
              label: 'Ping',
              value: ping.toStringAsFixed(0),
              unit: 'ms',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
