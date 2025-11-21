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
              width: 240,
              height: 60,
              decoration: BoxDecoration(
                gradient:
                    testInProgress
                        ? LinearGradient(
                          colors: [Colors.grey.shade700, Colors.grey.shade800],
                        )
                        : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppColors.headerGradient,
                        ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(testInProgress ? 0.1 : 0.2),
                  width: 1.5,
                ),
                boxShadow:
                    testInProgress
                        ? null
                        : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 4,
                            offset: const Offset(0, 12),
                          ),
                        ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child:
                      testInProgress
                          ? Row(
                            key: const ValueKey(true),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'TESTING',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withOpacity(0.8),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          )
                          : Row(
                            key: const ValueKey(false),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'START TEST',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
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
