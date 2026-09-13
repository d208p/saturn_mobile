import 'package:flutter/material.dart';
import 'package:saturn_app/theme/colors.dart';

/// Wraps a [future] with a consistent loading spinner and error state
/// (with an optional retry button), so every screen doesn't reimplement
/// the same FutureBuilder boilerplate.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.future, required this.builder, this.onRetry});

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.red, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.slate),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
                  ],
                ],
              ),
            ),
          );
        }

        return builder(context, snapshot.data as T);
      },
    );
  }
}