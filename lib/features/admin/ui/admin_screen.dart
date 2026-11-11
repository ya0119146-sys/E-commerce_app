import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../checkout/logic/checkout_cubit.dart';
import '../../store/data/models/sub_category_model.dart';
import '../../store/logic/categories_cubit.dart';
import '../../store/logic/products_cubit.dart';
import '../data/repos/admin_repository.dart';
import '../logic/admin_cubit.dart';
import '../logic/admin_state.dart';
import '../logic/users_cubit.dart';
import 'widgets/category_form.dart';
import 'widgets/product_form.dart';
import 'widgets/subcategory_form.dart';
import 'widgets/tabs/admin_categories_tab.dart';
import 'widgets/tabs/admin_orders_tab.dart';
import 'widgets/tabs/admin_products_tab.dart';
import 'widgets/tabs/admin_subcategories_tab.dart';
import 'widgets/tabs/admin_users_tab.dart';
import 'widgets/user_form.dart';

/// Admin Dashboard for managing products, orders, users, categories, and subcategories.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _productsScrollController = ScrollController();
  List<SubCategoryModel> _allSubcategories = [];
  bool _isLoadingSubcats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _productsScrollController.addListener(_onProductsScroll);
    _refreshData();
  }

  void _onProductsScroll() {
    if (_productsScrollController.hasClients &&
        _productsScrollController.position.pixels >=
            _productsScrollController.position.maxScrollExtent - 200) {
      context.read<ProductsCubit>().loadMore();
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging && mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    context.read<ProductsCubit>().fetchProducts(
      refresh: true,
      clearCategory: true,
      clearKeyword: true,
      clearSort: true,
    );
    context.read<CategoriesCubit>().fetchCategories();
    context.read<CheckoutCubit>().fetchOrderHistory();
    context.read<UsersCubit>().fetchUsers();
    _fetchSubcategories();
  }

  Future<void> _fetchSubcategories() async {
    if (!mounted) return;
    setState(() => _isLoadingSubcats = true);
    try {
      final subcats = await getIt<AdminRepository>().getAllSubcategories();
      if (!mounted) return;
      setState(() => _allSubcategories = subcats);
    } catch (_) {}
    if (!mounted) return;
    setState(() => _isLoadingSubcats = false);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _productsScrollController.removeListener(_onProductsScroll);
    _productsScrollController.dispose();
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

  void _onFabPressed() {
    final index = _tabController.index;
    if (index == 0) {
      _showForm(
        ProductForm(
          categories: context.read<CategoriesCubit>().state.categories,
          subcategories: _allSubcategories,
          onSubmit: (data) => context.read<AdminCubit>().createProduct(data),
        ),
      );
    } else if (index == 2) {
      _showForm(
        UserForm(
          onSubmit: (data) => context.read<AdminCubit>().createUser(data),
        ),
      );
    } else if (index == 3) {
      _showForm(
        CategoryForm(
          onSubmit: (data) => context.read<AdminCubit>().createCategory(data),
        ),
      );
    } else if (index == 4) {
      _showForm(
        SubcategoryForm(
          categories: context.read<CategoriesCubit>().state.categories,
          onSubmit: (data) =>
              context.read<AdminCubit>().createSubcategory(data),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isScrollable = screenWidth < 600;

    return BlocListener<AdminCubit, AdminState>(
      listener: (context, state) {
        if (state.status == AdminStatus.success) {
          CustomSnackBar.showSuccess(
            context,
            (state.message ?? 'Operation successful').tr(context),
          );
          _refreshData();
        } else if (state.status == AdminStatus.error) {
          CustomSnackBar.showError(
            context,
            (state.error ?? 'Error occurred').tr(context),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Panel'.tr(context)),
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
            tabs: [
              Tab(
                text: 'Products'.tr(context),
                icon: const Icon(Icons.inventory_2_outlined),
              ),
              Tab(
                text: 'Orders'.tr(context),
                icon: const Icon(Icons.receipt_long_outlined),
              ),
              Tab(
                text: 'Users'.tr(context),
                icon: const Icon(Icons.people_outline),
              ),
              Tab(
                text: 'Categories'.tr(context),
                icon: const Icon(Icons.category_outlined),
              ),
              Tab(
                text: 'Subcategories'.tr(context),
                icon: const Icon(Icons.subtitles_outlined),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            AdminProductsTab(
              scrollController: _productsScrollController,
              allSubcategories: _allSubcategories,
              onShowForm: _showForm,
            ),
            AdminOrdersTab(onStatusUpdate: _refreshData),
            AdminUsersTab(onShowForm: _showForm),
            AdminCategoriesTab(onShowForm: _showForm),
            AdminSubcategoriesTab(
              isLoading: _isLoadingSubcats,
              subcategories: _allSubcategories,
              onShowForm: _showForm,
            ),
          ],
        ),
        floatingActionButton: _tabController.index == 1
            ? null
            : Padding(
                padding: const EdgeInsets.only(bottom: 84),
                child: FloatingActionButton(
                  onPressed: _onFabPressed,
                  child: const Icon(Icons.add),
                ),
              ),
      ),
    );
  }
}
