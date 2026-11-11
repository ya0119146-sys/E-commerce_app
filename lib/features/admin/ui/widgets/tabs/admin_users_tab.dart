import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/localization/app_translations.dart';
import '../../../logic/admin_cubit.dart';
import '../../../logic/users_cubit.dart';
import '../../../logic/users_state.dart';
import '../shared/admin_item_actions.dart';
import '../user_form.dart';

/// Admin users management tab.
class AdminUsersTab extends StatelessWidget {
  final void Function(Widget form) onShowForm;

  const AdminUsersTab({super.key, required this.onShowForm});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        if (state.status == UsersStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.users.isEmpty) {
          return Center(child: Text('No users found'.tr(context)));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.screenPadding,
            AppDimensions.screenPadding,
            100,
          ),
          itemCount: state.users.length,
          itemBuilder: (context, index) {
            final user = state.users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 12, right: 8),
                leading: CircleAvatar(
                  backgroundImage: user.image != null
                      ? NetworkImage(user.image!)
                      : null,
                  child: user.image == null ? const Icon(Icons.person) : null,
                ),
                title: Text(user.name),
                subtitle: Text('${user.email} • ${user.role.tr(context)}'),
                trailing: AdminItemActions(
                  onEdit: () => onShowForm(
                    UserForm(
                      user: user,
                      onSubmit: (data) =>
                          context.read<AdminCubit>().updateUser(user.id!, data),
                    ),
                  ),
                  onDelete: () => showAdminDeleteConfirmDialog(
                    context,
                    onConfirm: () =>
                        context.read<AdminCubit>().deleteUser(user.id!),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
