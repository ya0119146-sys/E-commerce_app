import 'package:e_commerce/core/network/dio_client.dart';
import 'package:e_commerce/features/profile/data/repos/profile_repo.dart';
import 'package:e_commerce/features/profile/logic/cubit/cubit/get_profile_cubit.dart';
import 'package:e_commerce/features/profile/logic/cubit/delete_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/service_locator.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../features/auth/data/repos/auth_repository.dart';
import '../features/auth/logic/auth_cubit.dart';
import '../features/store/data/repos/product_repository.dart';
import '../features/store/data/repos/category_repository.dart';
import '../features/store/logic/products_cubit.dart';
import '../features/store/logic/categories_cubit.dart';
import '../features/cart/data/repos/cart_repository.dart';
import '../features/cart/logic/cart_cubit.dart';
import '../features/wishlist/data/repos/wishlist_repository.dart';
import '../features/wishlist/logic/wishlist_cubit.dart';
import '../features/checkout/data/repos/checkout_repository.dart';
import '../features/checkout/logic/checkout_cubit.dart';
import '../features/reviews/data/repos/review_repository.dart';
import '../features/reviews/logic/review_cubit.dart';
import '../features/profile/logic/profile_cubit.dart';
import '../features/admin/logic/admin_cubit.dart';
import '../features/admin/logic/users_cubit.dart';
import '../features/admin/data/repos/admin_repository.dart';
import '../features/auth/ui/login_screen.dart';

import 'bottom_nav_shell.dart';

/// Root app widget with all BlocProviders and theme management.
class ECommerceApp extends StatelessWidget {
  const ECommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => AuthCubit(getIt<AuthRepository>())..checkAuthStatus(),
        ),
        BlocProvider(create: (_) => ProductsCubit(getIt<ProductRepository>())),
        BlocProvider(
          create: (_) => CategoriesCubit(getIt<CategoryRepository>()),
        ),
        BlocProvider(create: (_) => CartCubit(getIt<CartRepository>())),
        BlocProvider(create: (_) => WishlistCubit(getIt<WishlistRepository>())),
        BlocProvider(create: (_) => CheckoutCubit(getIt<CheckoutRepository>())),
        BlocProvider(create: (_) => ReviewCubit(getIt<ReviewRepository>())),
        BlocProvider(create: (_) => ProfileCubit(getIt<ProfileRepository>())),
        BlocProvider(
          create: (_) => GetProfileCubit(getIt<ProfileRepository>()),
        ),
        BlocProvider(
          create: (_) => DeleteProfileCubit(
            getIt<ProfileRepository>(),
            getIt<DioClient>(),
          ),
        ),
        BlocProvider(create: (_) => AdminCubit(getIt<AdminRepository>())),
        BlocProvider(create: (_) => UsersCubit(getIt<AdminRepository>())),
      ],

      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Labella',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeState.themeMode,
            home: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                if (authState is AuthInitial) {
                  return const _SplashView();
                }
                if (authState is AuthAuthenticated) {
                  return BottomNavShell(role: authState.user.role);
                }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}

/// Simple branded splash while checking auth status.
class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Labella',
              style: TextStyle(
                fontFamily: 'GreatVibes',
                fontSize: 48,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
