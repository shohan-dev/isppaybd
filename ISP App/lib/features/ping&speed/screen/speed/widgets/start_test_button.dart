import 'package:flutter/material.dart';
import 'package:ispapp/core/config/constants/color.dart';

class StartTestButton extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final AnimationController scaleController;
  final bool testInProgress;
  final VoidCallback onStart;

  const StartTestButton({
    Key? key,
    required this.scaleAnimation,
    required this.scaleController,
    required this.testInProgress,
    required this.onStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => testInProgress ? null : scaleController.forward(),
      onTapUp: (_) => testInProgress ? null : scaleController.reverse(),
      onTapCancel: () => testInProgress ? null : scaleController.reverse(),
      onTap: testInProgress ? null : onStart,
      child: AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 220,
              height: 64,
              decoration: BoxDecoration(
                gradient:
                    testInProgress
                        ? LinearGradient(
                          colors: [Colors.grey.shade600, Colors.grey.shade700],
                        )
                        : LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withBlue(220),
                          ],
                        ),
                borderRadius: BorderRadius.circular(32),
                boxShadow:
                    testInProgress
                        ? null
                        : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    testInProgress ? 'TESTING...' : 'START TEST',
                    key: ValueKey(testInProgress),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
