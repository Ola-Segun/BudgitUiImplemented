import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../theme/goals_theme_extended.dart';

/// Celebration widget for goal achievements and milestones
class GoalCelebrationWidget extends StatefulWidget {
  const GoalCelebrationWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.duration = const Duration(seconds: 3),
    this.onComplete,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Duration duration;
  final VoidCallback? onComplete;

  @override
  State<GoalCelebrationWidget> createState() => _GoalCelebrationWidgetState();
}

class _GoalCelebrationWidgetState extends State<GoalCelebrationWidget> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: widget.duration);

    // Start celebration
    _confettiController.play();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [
              GoalsThemeExtended.goalPrimary,
              GoalsThemeExtended.goalSecondary,
              GoalsThemeExtended.goalSuccess,
              Colors.yellow,
              Colors.pink,
              Colors.purple,
            ],
          ),
        ),

        // Celebration Dialog
        Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Achievement Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GoalsThemeExtended.goalPrimary,
                        GoalsThemeExtended.goalSecondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: GoalsThemeExtended.goalPrimary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    size: 48,
                    color: Colors.white,
                  ),
                ).animate()
                  .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut)
                  .then()
                  .shake(duration: 500.ms),

                const SizedBox(height: 24),

                // Title
                Text(
                  widget.title,
                  style: AppTypography.h2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: GoalsThemeExtended.goalPrimary,
                  ),
                  textAlign: TextAlign.center,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.2, duration: 400.ms, delay: 200.ms),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  widget.subtitle,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms, delay: 400.ms),

                const SizedBox(height: 32),

                // Continue Button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GoalsThemeExtended.goalPrimary,
                        GoalsThemeExtended.goalSecondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _confettiController.stop();
                        widget.onComplete?.call();
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: Center(
                        child: Text(
                          'Continue',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate()
                  .fadeIn(duration: 400.ms, delay: 600.ms)
                  .slideY(begin: 0.2, duration: 400.ms, delay: 600.ms),
              ],
            ),
          ).animate()
            .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 300.ms),
        ),
      ],
    );
  }
}

/// Achievement Badge Widget
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.size = 80,
    this.showGlow = true,
  });

  final String title;
  final IconData icon;
  final Color color;
  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: showGlow ? [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ] : null,
          ),
          child: Icon(
            icon,
            size: size * 0.5,
            color: Colors.white,
          ),
        ).animate()
          .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),

        const SizedBox(height: 8),

        Text(
          title,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
        ).animate()
          .fadeIn(duration: 400.ms, delay: 300.ms),
      ],
    );
  }
}

/// Progress Celebration Overlay
class ProgressCelebrationOverlay extends StatefulWidget {
  const ProgressCelebrationOverlay({
    super.key,
    required this.child,
    required this.show,
    this.onComplete,
  });

  final Widget child;
  final bool show;
  final VoidCallback? onComplete;

  @override
  State<ProgressCelebrationOverlay> createState() => _ProgressCelebrationOverlayState();
}

class _ProgressCelebrationOverlayState extends State<ProgressCelebrationOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void didUpdateWidget(ProgressCelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _confettiController.play();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          widget.onComplete?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        if (widget.show) ...[
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                GoalsThemeExtended.goalPrimary,
                GoalsThemeExtended.goalSecondary,
                GoalsThemeExtended.goalSuccess,
                Colors.yellow,
                Colors.pink,
              ],
            ),
          ),

          // Sparkle effect
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.transparent,
                child: const Center(
                  child: Icon(
                    Icons.star,
                    size: 100,
                    color: Colors.yellow,
                  ),
                ).animate()
                  .scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut)
                  .then()
                  .fadeOut(duration: 1000.ms),
              ),
            ),
          ),
        ],
      ],
    );
  }
}