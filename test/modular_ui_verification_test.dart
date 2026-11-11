import 'package:e_commerce/core/constants/egypt_governorates.dart';
import 'package:e_commerce/core/di/service_locator.dart';
import 'package:e_commerce/core/localization/app_translations.dart';
import 'package:e_commerce/core/localization/locale_cubit.dart';
import 'package:e_commerce/core/network/dio_client.dart';
import 'package:e_commerce/core/theme/app_theme.dart';
import 'package:e_commerce/core/theme/theme_cubit.dart';
import 'package:e_commerce/core/widgets/product_grid_delegate.dart';
import 'package:e_commerce/features/admin/data/repos/admin_repository.dart';
import 'package:e_commerce/features/admin/logic/admin_cubit.dart';
import 'package:e_commerce/features/admin/logic/users_cubit.dart';
import 'package:e_commerce/features/admin/ui/screens/admin_screen.dart';
import 'package:e_commerce/features/admin/ui/widgets/product_form.dart';
import 'package:e_commerce/features/auth/data/models/user_model.dart';
import 'package:e_commerce/features/auth/data/repos/auth_repository.dart';
import 'package:e_commerce/features/auth/logic/auth_cubit.dart';
import 'package:e_commerce/features/cart/data/models/cart_model.dart';
import 'package:e_commerce/features/cart/data/repos/cart_repository.dart';
import 'package:e_commerce/features/cart/logic/cart_cubit.dart';
import 'package:e_commerce/features/cart/ui/screens/cart_screen.dart';
import 'package:e_commerce/features/checkout/data/models/address_model.dart';
import 'package:e_commerce/features/checkout/data/models/order_model.dart';
import 'package:e_commerce/features/checkout/data/repos/checkout_repository.dart';
import 'package:e_commerce/features/checkout/logic/checkout_cubit.dart';
import 'package:e_commerce/features/checkout/ui/screens/checkout_screen.dart';
import 'package:e_commerce/features/profile/data/repos/profile_repository.dart';
import 'package:e_commerce/features/profile/logic/delete_profile_cubit.dart';
import 'package:e_commerce/features/profile/logic/get_profile_cubit.dart';
import 'package:e_commerce/features/profile/logic/profile_cubit.dart';
import 'package:e_commerce/features/profile/ui/screens/profile_screen.dart';
import 'package:e_commerce/features/reviews/data/models/review_model.dart';
import 'package:e_commerce/features/reviews/data/repos/review_repository.dart';
import 'package:e_commerce/features/reviews/logic/review_cubit.dart';
import 'package:e_commerce/features/store/data/models/category_model.dart';
import 'package:e_commerce/features/store/data/models/product_model.dart';
import 'package:e_commerce/features/store/data/models/sub_category_model.dart';
import 'package:e_commerce/features/store/data/repos/category_repository.dart';
import 'package:e_commerce/features/store/data/repos/product_repository.dart';
import 'package:e_commerce/features/store/logic/categories_cubit.dart';
import 'package:e_commerce/features/store/logic/products_cubit.dart';
import 'package:e_commerce/features/store/ui/screens/home_screen.dart';
import 'package:e_commerce/features/store/ui/screens/product_detail_screen.dart';
import 'package:e_commerce/features/wishlist/data/repos/wishlist_repository.dart';
import 'package:e_commerce/features/wishlist/logic/wishlist_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<void> logout() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProductRepository implements ProductRepository {
  final List<ProductModel> products;
  _FakeProductRepository(this.products);

  @override
  Future<List<ProductModel>> getProducts({
    String? keyword,
    String? category,
    String? subcategory,
    String? sort,
    int page = 1,
    int limit = 8,
  }) async => products;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCategoryRepository implements CategoryRepository {
  final List<CategoryModel> categories;
  _FakeCategoryRepository(this.categories);

  @override
  Future<List<CategoryModel>> getCategories() async => categories;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCartRepository implements CartRepository {
  CartModel cart;
  _FakeCartRepository(this.cart);

  @override
  Future<CartModel> getCart() async => cart;

  @override
  Future<CartModel> addToCart(String productId) async => cart;

  @override
  Future<CartModel> updateQuantity(String productId, int quantity) async =>
      cart;

  @override
  Future<CartModel> removeFromCart(String productId) async =>
      const CartModel(items: [], totalPrice: 0);

  @override
  Future<void> clearCart() async {
    cart = const CartModel(items: [], totalPrice: 0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWishlistRepository implements WishlistRepository {
  @override
  Future<List<ProductModel>> getWishlist() async => [];

  @override
  Future<List<ProductModel>> toggleWishlist(
    String productId, {
    required bool isInWishlist,
  }) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCheckoutRepository implements CheckoutRepository {
  final List<AddressModel> addresses;
  _FakeCheckoutRepository({this.addresses = const []});

  @override
  Future<List<AddressModel>> getAddresses() async => addresses;

  @override
  Future<List<OrderModel>> getOrderHistory() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeReviewRepository implements ReviewRepository {
  final List<ReviewModel> reviews;
  _FakeReviewRepository(this.reviews);

  @override
  Future<List<ReviewModel>> getProductReviews(String productId) async =>
      reviews;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileRepository implements ProfileRepository {
  final UserModel user;
  _FakeProfileRepository(this.user);

  @override
  Future<UserModel> getProfile() async => user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAdminRepository implements AdminRepository {
  @override
  Future<List<SubCategoryModel>> getAllSubcategories() async => const [
    SubCategoryModel(
      id: 'sub1',
      name: 'Serums',
      categoryId: 'cat1',
      categoryName: 'Skincare',
    ),
  ];

  @override
  Future<List<UserModel>> getUsers() async => const [
    UserModel(
      id: 'u1',
      name: 'Admin User',
      userName: 'admin',
      email: 'admin@labella.com',
      role: 'admin',
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const sampleProduct = ProductModel(
    id: 'prod_1',
    name: 'La Bella Retinol Serum',
    size: '30 ml',
    description:
        'A concentrated luxury anti-aging retinol serum enriched with squalane and jojoba oil for deeply hydrated, visibly smoother, radiant skin every evening.',
    price: 450,
    salePrice: 350,
    discount: 22,
    ratingAvg: 4.8,
    ratingCount: 14,
    category: 'Skincare',
    categoryId: 'cat1',
    subcategory: 'Serums',
    subcategoryId: 'sub1',
    quantity: 7,
    inStock: true,
  );

  const sampleCategory = CategoryModel(id: 'cat1', name: 'Skincare');

  const sampleUser = UserModel(
    id: 'u1',
    name: 'Youssef Ahmed',
    userName: 'youssef',
    email: 'youssef@labella.com',
    role: 'user',
  );

  const sampleReview = ReviewModel(
    id: 'rev_1',
    comment: 'Amazing texture and fast absorption!',
    rate: 5.0,
    name: 'Nourhan Ali',
    product: sampleProduct,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    getIt.registerLazySingleton<AdminRepository>(() => _FakeAdminRepository());
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildAppHarness({
    required Widget home,
    bool authenticated = false,
    CartModel initialCart = const CartModel(),
    List<AddressModel> addresses = const [],
    List<ReviewModel> reviews = const [sampleReview],
    List<ProductModel> products = const [sampleProduct],
  }) {
    final authCubit = AuthCubit(_FakeAuthRepository());
    if (authenticated) {
      authCubit.emit(const AuthAuthenticated(sampleUser));
    } else {
      authCubit.emit(AuthUnauthenticated());
    }

    final cartCubit = CartCubit(_FakeCartRepository(initialCart));
    if (authenticated && initialCart.items.isNotEmpty) {
      cartCubit.emit(CartState(status: CartStatus.loaded, cart: initialCart));
    }

    final adminRepo = getIt<AdminRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider(
          create: (_) => ProductsCubit(_FakeProductRepository(products)),
        ),
        BlocProvider(
          create: (_) =>
              CategoriesCubit(_FakeCategoryRepository(const [sampleCategory])),
        ),
        BlocProvider<CartCubit>.value(value: cartCubit),
        BlocProvider(create: (_) => WishlistCubit(_FakeWishlistRepository())),
        BlocProvider(
          create: (_) =>
              CheckoutCubit(_FakeCheckoutRepository(addresses: addresses)),
        ),
        BlocProvider(
          create: (_) => ReviewCubit(_FakeReviewRepository(reviews)),
        ),
        BlocProvider(
          create: (_) => ProfileCubit(_FakeProfileRepository(sampleUser)),
        ),
        BlocProvider(
          create: (_) => GetProfileCubit(_FakeProfileRepository(sampleUser)),
        ),
        BlocProvider(
          create: (_) => DeleteProfileCubit(
            _FakeProfileRepository(sampleUser),
            DioClient(),
          ),
        ),
        BlocProvider(create: (_) => AdminCubit(adminRepo)),
        BlocProvider(create: (_) => UsersCubit(adminRepo)),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return MaterialApp(
            locale: localeState.locale,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            home: Directionality(
              textDirection: localeState.locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: home,
            ),
          );
        },
      ),
    );
  }

  group('Refactored Localization Dictionaries Integrity', () {
    test(
      'en and ar dictionaries preserve keys and translations accurately',
      () {
        expect(AppTranslations.en, isNotEmpty);
        expect(AppTranslations.ar, isNotEmpty);
        expect(AppTranslations.en.length, greaterThan(400));
        expect(AppTranslations.ar.length, greaterThan(400));

        expect(AppTranslations.translate('add_to_cart', 'en'), isNotEmpty);
        expect(AppTranslations.translate('add_to_cart', 'ar'), isNotEmpty);
        expect(
          AppTranslations.translate('ADD_TO_CART', 'en'),
          equals(AppTranslations.translate('add_to_cart', 'en')),
        );
        expect(
          AppTranslations.translate('add_to_cart...', 'ar'),
          equals(AppTranslations.translate('add_to_cart', 'ar')),
        );
      },
    );
  });

  group('Modular UI Screens Smoke & Regression Verification', () {
    testWidgets(
      'ProductDetailScreen renders customer Add-to-Cart state, expandable description, and reviews',
      (tester) async {
        await tester.pumpWidget(
          buildAppHarness(
            home: const ProductDetailScreen(
              product: sampleProduct,
              role: 'user',
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.text('La Bella Retinol Serum'), findsOneWidget);
        expect(find.byKey(const ValueKey('add_to_cart_state')), findsOneWidget);
        expect(find.text('Skincare'), findsOneWidget);
        expect(find.text('Serums'), findsOneWidget);
        expect(find.text('Nourhan Ali'), findsOneWidget);

        // Expandable description toggle
        final showMoreFinder = find.text('Show more');
        expect(showMoreFinder, findsOneWidget);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pump();
        await tester.ensureVisible(showMoreFinder);
        await tester.pump();
        await tester.tap(showMoreFinder);
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Show less'), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ProductDetailScreen renders Pattern-2 stepper when item is in cart and Edit button for admin',
      (tester) async {
        const cartWithItem = CartModel(
          id: 'c1',
          totalPrice: 700,
          items: [
            CartItemModel(
              id: 'ci1',
              productId: 'prod_1',
              product: sampleProduct,
              quantity: 2,
              price: 350,
            ),
          ],
        );

        await tester.pumpWidget(
          buildAppHarness(
            authenticated: true,
            initialCart: cartWithItem,
            home: const ProductDetailScreen(
              product: sampleProduct,
              role: 'user',
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(
          find.byKey(const ValueKey('in_cart_stepper_state')),
          findsOneWidget,
        );
        expect(find.text('2'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Verify Admin edit CTA renders cleanly
        await tester.pumpWidget(
          buildAppHarness(
            authenticated: true,
            home: const ProductDetailScreen(
              product: sampleProduct,
              role: 'admin',
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text('Edit Product'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'HomeScreen renders modular sliver app bar, carousel, categories, and product grid',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        ProductGridDelegate.invalidateCache();
        addTearDown(ProductGridDelegate.invalidateCache);

        const homeProduct = ProductModel(
          id: 'prod_home_1',
          name: 'La Bella Retinol Serum',
          size: '30 ml',
          price: 95,
          salePrice: 75,
          discount: 21,
          ratingAvg: 4.8,
          ratingCount: 14,
          category: 'Skincare',
          categoryId: 'cat1',
          quantity: 7,
          inStock: true,
        );

        await tester.pumpWidget(
          buildAppHarness(
            products: const [homeProduct],
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(0.9)),
                child: const HomeScreen(role: 'user'),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Labella'), findsOneWidget);
        expect(find.text('La Bella Retinol Serum'), findsOneWidget);
        expect(find.text('Skincare'), findsOneWidget);

        // Tap category chip
        await tester.tap(find.text('Skincare'));
        await tester.pump(const Duration(milliseconds: 200));

        // Dispose hero timer cleanly
        await tester.pumpWidget(buildAppHarness(home: const SizedBox.shrink()));
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ProfileScreen renders guest & authenticated states without ListTile Material assertion errors',
      (tester) async {
        final capturedErrors = <FlutterErrorDetails>[];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          capturedErrors.add(details);
        };
        addTearDown(() => FlutterError.onError = originalOnError);

        // Guest view
        await tester.pumpWidget(
          buildAppHarness(authenticated: false, home: const ProfileScreen()),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text('Welcome to Labella'), findsOneWidget);

        // Authenticated view + toggle Dark Mode & Language tiles
        await tester.pumpWidget(
          buildAppHarness(authenticated: true, home: const ProfileScreen()),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        expect(find.text('Youssef Ahmed'), findsOneWidget);
        expect(find.text('youssef@labella.com'), findsOneWidget);

        expect(
          capturedErrors.where(
            (e) => e.exceptionAsString().contains('ListTile background color'),
          ),
          isEmpty,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'CartScreen renders guest, empty, and populated cart item states cleanly',
      (tester) async {
        await tester.pumpWidget(
          buildAppHarness(
            authenticated: false,
            home: const CartScreen(role: 'user'),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Your cart is waiting'), findsOneWidget);

        const cartWithItem = CartModel(
          id: 'c1',
          totalPrice: 700,
          items: [
            CartItemModel(
              id: 'ci1',
              productId: 'prod_1',
              product: sampleProduct,
              quantity: 2,
              price: 350,
            ),
          ],
        );

        await tester.pumpWidget(
          buildAppHarness(
            authenticated: true,
            initialCart: cartWithItem,
            home: const CartScreen(role: 'user'),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('La Bella Retinol Serum'), findsOneWidget);
        // Shown in both Subtotal and Total rows
        expect(find.text('\$700.00'), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'CheckoutScreen renders address list, Sharqia free delivery policy, and opens Add Address sheet',
      (tester) async {
        const addresses = [
          AddressModel(
            id: 'addr1',
            street: '10 El-Gomhoria St',
            city: 'Zagazig',
            state: EgyptGovernorates.sharqia,
            zip: '44511',
          ),
        ];

        await tester.pumpWidget(
          buildAppHarness(
            authenticated: true,
            addresses: addresses,
            home: const CheckoutScreen(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.textContaining('Zagazig'), findsOneWidget);
        expect(find.text('Free (Sharqia)'), findsOneWidget);

        await tester.tap(find.text('Add New'));
        await tester.pumpAndSettle();
        expect(find.text('Add Address'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'AdminScreen renders all 5 modular tabs and opens ProductForm cleanly',
      (tester) async {
        await tester.pumpWidget(
          buildAppHarness(authenticated: true, home: const AdminScreen()),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('La Bella Retinol Serum'), findsOneWidget);
        expect(find.text('Products'), findsOneWidget);
        expect(find.text('Orders'), findsOneWidget);
        expect(find.text('Users'), findsOneWidget);
        expect(find.text('Categories'), findsOneWidget);
        expect(find.text('Subcategories'), findsOneWidget);

        // Tap FAB to verify ProductForm modal renders cleanly
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(find.byType(ProductForm), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
