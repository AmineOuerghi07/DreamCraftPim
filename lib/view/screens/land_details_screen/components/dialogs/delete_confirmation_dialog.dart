import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void showDeleteConfirmationDialog(
  BuildContext context, {
  required Function onConfirm,
  Function? onComplete,
}) {
  // Get screen width for responsive dialog
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;
  final l10n = AppLocalizations.of(context)!;
  
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(
        l10n.confirmDelete,
        style: TextStyle(fontSize: isTablet ? 22 : 18),
      ),
      content: Text(
        l10n.confirmDeleteMessage,
        style: TextStyle(fontSize: isTablet ? 18 : 16),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () async {
            // Close dialog
            context.pop();
            // Execute the provided callback function
            await onConfirm();
            // Call the onComplete callback if provided
            if (onComplete != null) {
              onComplete();
            }
          },
          child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}