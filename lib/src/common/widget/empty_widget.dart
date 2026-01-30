import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    this.icon,
    this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
  });

  final IconData? icon;
  final String? title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon Container
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFd41132).withValues(alpha: 0.1),
                  border: Border.all(
                    color: const Color(0xFFd41132).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFd41132).withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  icon ?? FontAwesomeIcons.ghost,
                  size: 60,
                  color: const Color(0xFFd41132),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title with fade animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn,
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: Text(
                title ?? 'No Stories Found',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle with fade animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeIn,
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: Text(
                subtitle ??
                    'The darkness is quiet... for now.\nTry searching for different stories.',
                style: TextStyle(fontSize: 16, color: Colors.grey[400], height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),

            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              // Action button with slide animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd41132),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 8,
                    shadowColor: const Color(0xFFd41132).withValues(alpha: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionText!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.refresh, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Предустановленные варианты для разных ситуаций
class EmptyArticlesWidget extends StatelessWidget {
  const EmptyArticlesWidget({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: FontAwesomeIcons.ghost,
      title: 'No Articles Found',
      subtitle: 'The darkness is empty...\nTry searching for different subreddits or stories.',
      actionText: onRetry != null ? 'Retry' : null,
      onActionPressed: onRetry,
    );
  }
}

class EmptySearchWidget extends StatelessWidget {
  const EmptySearchWidget({super.key, this.onClear});

  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: FontAwesomeIcons.magnifyingGlass,
      title: 'No Results',
      subtitle: 'We couldn\'t find any stories matching your search.\nTry different keywords.',
      actionText: onClear != null ? 'Clear Search' : null,
      onActionPressed: onClear,
    );
  }
}

class EmptyBookmarksWidget extends StatelessWidget {
  const EmptyBookmarksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyWidget(
      icon: FontAwesomeIcons.bookmark,
      title: 'No Bookmarks',
      subtitle: 'You haven\'t saved any stories yet.\nStart exploring and bookmark your favorites!',
    );
  }
}

class NoConnectionWidget extends StatelessWidget {
  const NoConnectionWidget({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: FontAwesomeIcons.wifi,
      title: 'No Connection',
      subtitle: 'Unable to connect to the darkness.\nCheck your internet connection and try again.',
      actionText: 'Retry',
      onActionPressed: onRetry,
    );
  }
}
