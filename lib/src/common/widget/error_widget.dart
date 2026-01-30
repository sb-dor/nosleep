import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ErrorWidget extends StatelessWidget {
  const ErrorWidget({
    super.key,
    required this.onRetry,
    this.icon,
    this.title,
  });

  final VoidCallback onRetry;
  final IconData? icon;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Error Icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFd41132).withValues(alpha: 0.15),
                  border: Border.all(
                    color: const Color(0xFFd41132).withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFd41132).withValues(alpha: 0.25),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  icon ?? FontAwesomeIcons.skullCrossbones,
                  size: 50,
                  color: const Color(0xFFd41132),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Error Title
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: Text(
                title ?? 'Something Went Wrong',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            TryAgainButton(onPressed: onRetry)
          ],
        ),
      ),
    );
  }
}

class TryAgainButton extends StatefulWidget {
  const TryAgainButton({super.key, required this.onPressed, this.text});

  final VoidCallback onPressed;
  final String? text;

  @override
  State<TryAgainButton> createState() => _TryAgainButtonState();
}

class _TryAgainButtonState extends State<TryAgainButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFd41132),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: _isHovered ? 12 : 8,
          shadowColor: const Color(0xFFd41132).withValues(alpha: 0.6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FontAwesomeIcons.arrowRotateRight, size: 18),
            const SizedBox(width: 12),
            Text(
              widget.text ?? 'Try again',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Специализированные виджеты ошибок
class NetworkErrorWidget extends StatelessWidget {
  const NetworkErrorWidget({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      icon: FontAwesomeIcons.wifi,
      title: 'Connection Lost',
      onRetry: onRetry,
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  const ServerErrorWidget({super.key, required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      icon: FontAwesomeIcons.server,
      title: 'Server Error',
      onRetry: onRetry,
    );
  }
}

class NotFoundErrorWidget extends StatelessWidget {
  const NotFoundErrorWidget({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      icon: FontAwesomeIcons.solidQuestionCircle,
      title: 'Not Found',
      onRetry: onRetry,
    );
  }
}

class GenericErrorWidget extends StatelessWidget {
  const GenericErrorWidget({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorWidget( onRetry: onRetry);
  }
}

// Sliver версии для использования в CustomScrollView
class SliverErrorWidget extends StatelessWidget {
  const SliverErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon,
    this.title,
  });

  final String message;
  final VoidCallback onRetry;
  final IconData? icon;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: ErrorWidget(onRetry: onRetry, icon: icon, title: title),
    );
  }
}

class SliverGenericErrorWidget extends StatelessWidget {
  const SliverGenericErrorWidget({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverErrorWidget(message: message, onRetry: onRetry);
  }
}
