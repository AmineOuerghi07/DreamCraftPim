// lib/widgets/internal_server_error.dart
import 'package:flutter/material.dart';

class InternalServerError extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const InternalServerError({
    Key? key,
    this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Server error image
            Image.asset(
              'assets/images/server_error.png',
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 24),
            
            // Error title
            Text(
              'Server Down',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Error message
            Text(
              message ?? 'Something went wrong on our server. Please try again later.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Retry button (only shown if onRetry is provided)
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}