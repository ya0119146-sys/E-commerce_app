import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../store/logic/products_cubit.dart';
import '../../store/logic/categories_cubit.dart';
import '../../store/data/models/sub_category_model.dart';
import '../logic/admin_cubit.dart';
import '../logic/admin_state.dart';
import 'widgets/category_form.dart';
import 'widgets/subcategory_form.dart';
import 'widgets/product_form.dart';
import '../data/repos/admin_repository.dart';
import '../../checkout/logic/checkout_cubit.dart';
import '../../checkout/ui/order_detail_screen.dart';
import '../logic/users_cubit.dart';
import '../logic/users_state.dart';
import 'widgets/user_form.dart';
import '../../../core/di/service_locator.dart';

/// Admin Dashboard for managing products, categories, and subcategories.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SubCategoryModel> _allSubcategories = [];
  bool _isLoadingSubcats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _refreshData();
  }

  Future<void> _refreshData() async {
    context.read<ProductsCubit>().fetchProducts(refresh: true);
    context.read<CategoriesCubit>().fetchCategories();
    context.read<CheckoutCubit>().fetchOrderHistory();
    context.read<UsersCubit>().fetchUsers();
    _fetchSubcategories();
  }

  Future<void> _fetchSubcategories() async {
    setState(() => _isLoadingSubcats = true);
    try {
      final subcats = await getIt<AdminRepository>().getAllSubcategories();
      setState(() => _allSubcategories = subcats);
    } catch (_) {}
    setState(() => _isLoadingSubcats = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showForm(Widget form) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => form,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isScrollable = screenWidth < 600;
    final brightness = Theme.of(context).brightness;

    return BlocListener<AdminCubit, AdminState>(
      listener: (context, state) {
        if (state.status == AdminStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? 'Operation successful')),
          );
          _refreshData();
        } else if (state.status == AdminStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Error occurred'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          actions: [
            IconButton(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: TabBar(
            isScrollable: isScrollable,
            tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
            controller: _tabController,
            tabs: const [
              Tab(text: 'Products', icon: Icon(Icons.inventory_2_outlined)),
              Tab(text: 'Orders', icon: Icon(Icons.receipt_long_outlined)),
              Tab(text: 'Users', icon: Icon(Icons.people_outline)),
              Tab(text: 'Categories', icon: Icon(Icons.category_outlined)),
              Tab(text: 'Subcategories', icon: Icon(Icons.subtitles_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductsTab(brightness),
            _buildOrdersTab(brightness),
            _buildUsersTab(brightness),
            _buildCategoriesTab(brightness),
            _buildSubcategoriesTab(brightness),
          ],
        ),

        floatingActionButton: _tabController.index == 1
            ? null
            : FloatingActionButton(
                onPressed: () {
                  final index = _tabController.index;
                  if (index == 0) {
                    _showForm(
                      ProductForm(
                        categories: context
                            .read<CategoriesCubit>()
                            .state
                            .categories,
                        subcategories: _allSubcategories,
                        onSubmit: (data) =>
                            context.read<AdminCubit>().createProduct(data),
                      ),
                    );
                  } else if (index == 2) {
                    _showForm(
                      UserForm(
                        onSubmit: (data) =>
                            context.read<AdminCubit>().createUser(data),
                      ),
                    );
                  } else if (index == 3) {
                    _showForm(
                      CategoryForm(
                        onSubmit: (data) =>
                            context.read<AdminCubit>().createCategory(data),
                      ),
                    );
                  } else if (index == 4) {
                    _showForm(
                      SubcategoryForm(
                        categories: context
                            .read<CategoriesCubit>()
                            .state
                            .categories,
                        onSubmit: (data) =>
                            context.read<AdminCubit>().createSubcategory(data),
                      ),
                    );
                  }
                },
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  Widget _buildProductsTab(Brightness brightness) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state.status == ProductsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          itemCount: state.products.length,
          itemBuilder: (context, index) {
            final product = state.products[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 12, right: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.cover != null
                      ? Image.network(
                          product.cover!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported),
                ),
                title: Text(product.name),
                subtitle: Text('\$${product.price} • Qty: ${product.quantity}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showForm(
                        ProductForm(
                          product: product,
                          categories: context
                              .read<CategoriesCubit>()
                              .state
                              .categories,
                          subcategories: _allSubcategories,
                          onSubmit: (data) => context
                              .read<AdminCubit>()
                              .updateProduct(product.id, data),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () => _confirmDelete(
                        () => context.read<AdminCubit>().deleteProduct(
                          product.id,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoriesTab(Brightness brightness) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state.status == CategoriesStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          itemCount: state.categories.length,
          itemBuilder: (context, index) {
            final category = state.categories[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 12, right: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: category.image != null
                      ? Image.network(
                          category.image!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.category),
                ),
                title: Text(category.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showForm(
                        CategoryForm(
                          category: category,
                          onSubmit: (data) => context
                              .read<AdminCubit>()
                              .updateCategory(category.id, data),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () => _confirmDelete(
                        () => context.read<AdminCubit>().deleteCategory(
                          category.id,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubcategoriesTab(Brightness brightness) {
    if (_isLoadingSubcats) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      itemCount: _allSubcategories.length,
      itemBuilder: (context, index) {
        final subcat = _allSubcategories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 12, right: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: subcat.image != null
                  ? Image.network(
                      subcat.image!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.subtitles_outlined),
            ),
            title: Text(subcat.name),
            subtitle: Text('Category: ${subcat.categoryName}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showForm(
                    SubcategoryForm(
                      subcategory: subcat,
                      categories: context
                          .read<CategoriesCubit>()
                          .state
                          .categories,
                      onSubmit: (data) => context
                          .read<AdminCubit>()
                          .updateSubcategory(subcat.id, data),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: () => _confirmDelete(
                    () =>
                        context.read<AdminCubit>().deleteSubcategory(subcat.id),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab(Brightness brightness) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        if (state.ordersStatus == OrdersStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.orders.isEmpty) {
          return const Center(child: Text('No orders found'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          itemCount: state.orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = state.orders[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 12, right: 8),
                leading: CircleAvatar(
                  backgroundColor: AppColors.muted(brightness),
                  backgroundImage: order.userImage != null
                      ? NetworkImage(order.userImage!)
                      : null,
                  child: order.userImage == null
                      ? const Icon(Icons.person_outline)
                      : null,
                ),
                title: Text(
                  'Order #${order.id.substring(order.id.length > 8 ? order.id.length - 8 : 0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.userName != null)
                      Text(
                        'By: ${order.userName}',
                        style: TextStyle(
                          color: AppColors.primary(brightness),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    if (order.createdAt != null)
                      Text(
                        DateFormat(
                          "MMMM dd, yyyy 'at' h:mm a",
                        ).format(order.createdAt!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    Text(
                      'Total: \$${order.totalPrice.toStringAsFixed(2)} • ${order.items.length} items',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Status: ${order.isDelivered ? 'Delivered' : 'Pending'} • ${order.isPaid ? 'Paid' : 'Unpaid'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: order.isDelivered ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(
                        order: order,
                        isAdmin: true,
                        onStatusUpdate: _refreshData,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUsersTab(Brightness brightness) {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        if (state.status == UsersStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.users.isEmpty) {
          return const Center(child: Text('No users found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
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
                subtitle: Text('${user.email} • ${user.role}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showForm(
                        UserForm(
                          user: user,
                          onSubmit: (data) => context
                              .read<AdminCubit>()
                              .updateUser(user.id!, data),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () => _confirmDelete(
                        () => context.read<AdminCubit>().deleteUser(user.id!),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
