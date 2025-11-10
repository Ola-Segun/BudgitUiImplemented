import 'package:flutter/material.dart';

/// Widget for displaying error states with enhanced retry mechanisms
class ErrorView extends StatefulWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText = 'Try Again',
    this.showRetryCount = false,
    this.maxRetries = 3,
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryText;
  final bool showRetryCount;
  final int maxRetries;

  @override
  State<ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView> {
  int _retryCount = 0;
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (widget.onRetry == null || _retryCount >= widget.maxRetries) return;

    setState(() {
      _isRetrying = true;
      _retryCount++;
    });

    try {
      widget.onRetry!();
      // Add a small delay to show retry feedback
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canRetry = widget.onRetry != null && _retryCount < widget.maxRetries;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (widget.showRetryCount && _retryCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Retry attempts: $_retryCount/${widget.maxRetries}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (canRetry) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isRetrying ? null : _handleRetry,
                icon: _isRetrying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: Text(_isRetrying ? 'Retrying...' : widget.retryText),
              ),
            ] else if (_retryCount >= widget.maxRetries) ...[
              const SizedBox(height: 16),
              Text(
                'Maximum retry attempts reached',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}