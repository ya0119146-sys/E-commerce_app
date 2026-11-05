import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/auth/logic/auth_cubit.dart';
import 'package:e_commerce/features/auth/data/models/user_model.dart';
import 'package:e_commerce/core/utils/auth_guard.dart';
import 'package:e_commerce/core/localization/app_translations.dart';
import 'package:e_commerce/features/wishlist/logic/wishlist_cubit.dart';
import 'package:e_commerce/features/wishlist/data/repos/wishlist_repository.dart';
import 'package:e_commerce/features/store/data/models/product_model.dart';

class _FakeWishlistRepository implements WishlistRepository {
  @override
  Future<List<ProductModel>> getWishlist() async => [];

  @override
  Future<List<ProductModel>> addToWishlist(String productId) async => [];

  @override
  Future<List<ProductModel>> removeFromWishlist(String productId) async => [];

  @override
  Future<List<ProductModel>> toggleWishlist(
    String productId, {
    required bool isInWishlist,
  }) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Guest Browsing - Auth State Classification', () {
    test(
      'AuthInitial is recognized as initializing (not authenticated, not guest)',
      () {
        final state = AuthInitial();
        expect(state.isAuthenticated, isFalse);
        expect(state.isGuest, isFalse);
      },
    );

    test(
      'AuthUnauthenticated is recognized as guest and not authenticated',
      () {
        final state = AuthUnauthenticated();
        expect(state.isAuthenticated, isFalse);
        expect(state.isGuest, isTrue);
      },
    );

    test(
      'AuthLoading is recognized as loading (not authenticated, not guest)',
      () {
        final state = AuthLoading();
        expect(state.isAuthenticated, isFalse);
        expect(state.isGuest, isFalse);
      },
    );

    test('AuthError is recognized as error (not authenticated, not guest)', () {
      final state = AuthError('Network error');
      expect(state.isAuthenticated, isFalse);
      expect(state.isGuest, isFalse);
    });

    test('AuthAuthenticated is recognized as authenticated and not guest', () {
      const user = UserModel(
        id: 'u123',
        name: 'Sara Ahmed',
        userName: 'sara123',
        email: 'sara@example.com',
        role: 'user',
      );
      final state = AuthAuthenticated(user);
      expect(state.isAuthenticated, isTrue);
      expect(state.isGuest, isFalse);
    });
  });

  group('Guest Browsing - Localization Translations Coverage', () {
    final requiredGuestKeys = [
      'Sign in required',
      'Please sign in to add products to your wishlist.',
      'Please sign in to add products to your cart.',
      'Please sign in to complete your purchase.',
      'Please sign in to access your personal account.',
      'Not Now',
      'Welcome to Labella',
      'Sign in or create an account to enjoy your complete shopping experience.',
      'Member Benefits',
      'Order Tracking',
      'Track your orders and follow their delivery status.',
      'Save your favorite products and access them anytime.',
      'Faster Checkout',
      'Save your delivery information for a smoother shopping experience.',
      'Personal Account',
      'Manage your profile and view your shopping history.',
      'Your cart is waiting',
      'Please sign in to view your cart and start shopping.',
      'Your wishlist is waiting',
      'Please sign in to view and save your favorite items.',
      'Explore Store',
      'Guest',
      'Guest Account',
      'checkout_now',
      'in_cart',
      'max_stock_reached',
    ];

    test('All guest browsing keys exist and are non-empty in English', () {
      final en = AppTranslations.en;
      for (final key in requiredGuestKeys) {
        expect(
          en.containsKey(key),
          isTrue,
          reason: 'Missing English key: $key',
        );
        expect(
          en[key]!.trim(),
          isNotEmpty,
          reason: 'Empty English translation for: $key',
        );
      }
    });

    test('All guest browsing keys exist and are non-empty in Arabic', () {
      final ar = AppTranslations.ar;
      for (final key in requiredGuestKeys) {
        expect(ar.containsKey(key), isTrue, reason: 'Missing Arabic key: $key');
        expect(
          ar[key]!.trim(),
          isNotEmpty,
          reason: 'Empty Arabic translation for: $key',
        );
      }
    });
  });

  group('Guest Browsing - AuthGuard & Interception Logic', () {
    testWidgets(
      'AuthGuard.requireAuth intercepts guest before callback execution',
      (tester) async {
        bool callbackExecuted = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await AuthGuard.requireAuth(
                      context,
                      action: AuthActionType.cart,
                      onAuthenticated: () {
                        callbackExecuted = true;
                      },
                    );
                  },
                  child: const Text('Add to Cart'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Add to Cart'));
        await tester.pumpAndSettle();

        // Callback MUST NOT execute for unauthenticated guest
        expect(callbackExecuted, isFalse);

        // Auth sheet with 'Sign in required' should be displayed
        expect(find.text('Sign in required'), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Not Now'), findsOneWidget);
      },
    );

    testWidgets('AuthGuard.requireAuth runs callback when authenticated', (
      tester,
    ) async {
      bool callbackExecuted = false;

      const user = UserModel(
        id: 'u1',
        name: 'Amina',
        userName: 'amina1',
        email: 'amina@example.com',
        role: 'user',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: _FakeAuthCubit(AuthAuthenticated(user)),
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await AuthGuard.requireAuth(
                      context,
                      action: AuthActionType.wishlist,
                      onAuthenticated: () {
                        callbackExecuted = true;
                      },
                    );
                  },
                  child: const Text('Add to Wishlist'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add to Wishlist'));
      await tester.pumpAndSettle();

      // Callback must execute immediately for authenticated user
      expect(callbackExecuted, isTrue);

      // No auth sheet should appear
      expect(find.text('Sign in required'), findsNothing);
    });
  });

  group('Guest Browsing - WishlistCubit Session Sanitization', () {
    test(
      'clearWishlist resets items and sets state to initial empty state',
      () {
        final cubit = WishlistCubit(_FakeWishlistRepository());
        cubit.clearWishlist();

        expect(cubit.state.status, equals(WishlistStatus.initial));
        expect(cubit.state.wishlistIds, isEmpty);
        expect(cubit.state.products, isEmpty);
      },
    );
  });
}

class _FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _FakeAuthCubit(super.initialState);

  @override
  bool get isAuthenticated => state is AuthAuthenticated;

  @override
  bool get isGuest => !isAuthenticated;

  @override
  UserModel? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
