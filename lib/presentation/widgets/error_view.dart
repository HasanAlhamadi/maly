// 📁 lib/presentation/widgets/error_view.dart
// PURPOSE: Shared error display, so no screen has to print a raw exception.

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../generated/app_localizations.dart';

class ErrorView extends StatelessWidget {
  /// Called when the user taps Retry. Hidden when null.
  final VoidCallback? onRetry;

  const ErrorView({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(l10n.somethingWentWrong, style: theme.textTheme.titleMedium),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
