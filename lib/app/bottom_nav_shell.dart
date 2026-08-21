import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_colors.dart';
import '../features/store/ui/home_screen.dart';
import '../features/store/ui/search_screen.dart';
import '../features/cart/ui/cart_screen.dart';
import '../features/wishlist/ui/wishlist_screen.dart';
import '../features/profile/ui/profile_screen.dart';
import '../features/admin/ui/admin_screen.dart';
import '../features/cart/logic/cart_cubit.dart';

/// Main shell with bottom navigation (5 tabs).
class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key, required this.role});

  final String role;
  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _currentIndex = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   if (widget.role != "admin") {
  //     _screens.remove(const CartScreen());
  //   }
  // }

  List<Widget> get _screens => [
    HomeScreen(role: widget.role),
    SearchScreen(role: widget.role),
    WishlistScreen(role: widget.role),
    if (widget.role != 'admin') CartScreen(role: widget.role),

    const ProfileScreen(),
    if (widget.role == 'admin') const AdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.border(brightness).withValues(alpha: 0.3),
            ),
          ),
        ),
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            return BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  activeIcon: Icon(Icons.search),
                  label: 'Shop',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Wishlist',
                ),
                if (widget.role != 'admin')
                  BottomNavigationBarItem(
                    icon: Badge(
                      isLabelVisible: cartState.cartItemCount > 0,
                      label: Text(
                        '${cartState.cartItemCount}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: AppColors.primary(brightness),
                      child: const Icon(Icons.shopping_bag_outlined),
                    ),
                    activeIcon: Badge(
                      isLabelVisible: cartState.cartItemCount > 0,
                      label: Text(
                        '${cartState.cartItemCount}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: AppColors.primary(brightness),
                      child: const Icon(Icons.shopping_bag),
                    ),
                    label: 'Cart',
                  ),

                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
                if (widget.role == 'admin')
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.admin_panel_settings_outlined),
                    activeIcon: Icon(Icons.admin_panel_settings),
                    label: 'Admin',
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
