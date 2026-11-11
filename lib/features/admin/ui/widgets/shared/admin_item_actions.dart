import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_translations.dart';

/// Shared edit and delete icon action buttons for admin list cards.
class AdminItemActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminItemActions({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.edit_outlined),
          onPressed: onEdit,
        ),
        const SizedBox(width: 8),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: onDelete,
        ),
      ],
    );
  }
}

/// Shared confirmation dialog for destructive admin deletions.
void showAdminDeleteConfirmDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Confirm Delete'.tr(context)),
      content: Text('Are you sure you want to delete this item?'.tr(context)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Cancel'.tr(context)),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(dialogContext);
          },
          child: Text(
            'Delete'.tr(context),
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
}
