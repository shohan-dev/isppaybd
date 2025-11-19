import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const MetricCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            tween: Tween<double>(begin: 0, end: double.tryParse(value) ?? 0),
            builder: (context, animatedValue, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    animatedValue.toStringAsFixed(unit == 'ms' ? 0 : 2),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
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
}
