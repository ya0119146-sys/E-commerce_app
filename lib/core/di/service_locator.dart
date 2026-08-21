import 'package:e_commerce/features/profile/data/repos/profile_repo.dart';
import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../../features/auth/data/repos/auth_repository.dart';
import '../../features/store/data/repos/product_repository.dart';
import '../../features/store/data/repos/category_repository.dart';
import '../../features/cart/data/repos/cart_repository.dart';
import '../../features/wishlist/data/repos/wishlist_repository.dart';
import '../../features/checkout/data/repos/checkout_repository.dart';
import '../../features/reviews/data/repos/review_repository.dart';
import '../../features/admin/data/repos/admin_repository.dart';

final getIt = GetIt.instance;

/// Initialize all app-level dependencies.
Future<void> setupServiceLocator() async {
  // ─── Network ───
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // ─── Repositories ───
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<WishlistRepository>(
    () => WishlistRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<ReviewRepository>(
    () => ReviewRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepository(getIt<DioClient>()),
  );
}
