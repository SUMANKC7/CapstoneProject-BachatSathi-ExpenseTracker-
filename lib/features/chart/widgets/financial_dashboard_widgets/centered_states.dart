import 'package:flutter/material.dart';

class CenteredLoader extends StatelessWidget {
  final String title;
  const CenteredLoader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(title),
        ],
      ),
    );
  }
}

class CenteredError extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRetry;
  final IconData icon;
  final String retryLabel;

  const CenteredError({
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.retryLabel = 'Retry',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final errColor = Theme.of(context).colorScheme.error.withOpacity(0.8);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: errColor),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            if (onRetry != null)
              ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
