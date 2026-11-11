import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../auth/ui/login_screen.dart';
import '../../logic/delete_profile_cubit.dart';

/// Displays confirmation dialog for permanent profile deletion.
void showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('delete_account'.tr(context)),
      content: Text('delete_account_confirm'.tr(context)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('cancel'.tr(context)),
        ),
        TextButton(
          onPressed: () async {
            context.read<DeleteProfileCubit>().deleteProfile();
            await context.read<AuthCubit>().logout();
            if (context.mounted) {
              Navigator.pop(ctx);
              CustomSnackBar.showSuccess(
                context,
                'Profile deleted successfully'.tr(context),
              );
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          child: Text(
            'delete'.tr(context),
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
}
