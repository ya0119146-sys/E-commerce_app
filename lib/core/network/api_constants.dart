import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API endpoint constants for the Labella backend.
///
/// Base URL (from .env): https://backend-gleaming-frost-9826.fly.dev
/// All paths include the /api/v1 prefix since the base URL does NOT include it.
class ApiConstants {
  ApiConstants._();

  /// Base URL — loaded from .env with fallback to production URL. Must NOT include /api/v1.
  static String get baseUrl {
    try {
      final url = dotenv.maybeGet('BASE_URL');
      if (url != null && url.isNotEmpty) return url;
    } catch (_) {}
    return 'https://backend-gleaming-frost-9826.fly.dev';
  }

  // ─── Auth ───
  static const String signup = '/api/v1/auth/signup';
  static const String login = '/api/v1/auth/login';
  static const String adminLogin = '/api/v1/auth/login/admin';
  static const String forgetPassword = '/api/v1/auth/forget-password';
  static const String verifyCode = '/api/v1/auth/verify-code';
  static const String resetPassword = '/api/v1/auth/reset-password';

  // ─── Profile ───
  static const String profile = '/api/v1/profile/me';
  static const String profileUpdate = '/api/v1/profile/updateMe';
  static const String profileDelete = '/api/v1/profile/delete';
  static const String changePassword = '/api/v1/profile/change-password';

  // ─── Products ───
  static const String products = '/api/v1/products';
  static String productById(String id) => '/api/v1/products/$id';
  static const String createProduct = '/api/v1/products';
  static String updateProduct(String id) => '/api/v1/products/$id';
  static String deleteProduct(String id) => '/api/v1/products/$id';

  // ─── Categories ───
  static const String categories = '/api/v1/categories';
  static String categoryById(String id) => '/api/v1/categories/$id';
  static String subcategories(String categoryId) =>
      '/api/v1/categories/$categoryId/subcategories';

  // ─── Subcategories ───
  static const String getAllSubcategories = '/api/v1/subcategories';
  static String getSubcategoryById(String id) => '/api/v1/subcategories/$id';
  static String createSubCategory = '/api/v1/subcategories';
  static String updateSubCategory(String id) => '/api/v1/subcategories/$id';
  static String deleteSubCategory(String id) => '/api/v1/subcategories/$id';

  // ─── Cart ───
  static const String cart = '/api/v1/cart';
  static const String addToCart = '/api/v1/cart/add';
  static const String removeFromCart = '/api/v1/cart/remove';
  static const String deleteCart = '/api/v1/cart';
  static const String updateCart = '/api/v1/cart/update';

  // ─── Wishlist ───
  static const String getWishlist = '/api/v1/wishlist';
  static const String addToWishlist = '/api/v1/wishlist';
  static String deleteWishlist(String id) => '/api/v1/wishlist/$id';

  // ─── Address ───
  static const String address = '/api/v1/address';
  static const String addressAdd = '/api/v1/address';
  static String addressDelete(String id) => '/api/v1/address/$id';

  // ─── Orders ───
  static const String order = '/api/v1/order';
  static String orderDetails(String orderId) => '/api/v1/order/$orderId';
  static String orderDeliver(String orderId) => '/api/v1/order/$orderId/deliver';
  static String orderPay(String orderId) => '/api/v1/order/$orderId/pay';

  // ─── Reviews ───
  static const String reviews = '/api/v1/reviews';
  static const String reviewsMe = '/api/v1/reviews/me';
  static String reviewsByProductId(String productId) =>
      '/api/v1/products/$productId/reviews';
  static String updateReview(String id) => '/api/v1/reviews/$id';
  static String createReview = '/api/v1/reviews';
  static String deleteReview(String id) => '/api/v1/reviews/$id';

  // ─── Users (Admin) ───
  static const String users = '/api/v1/users';
  static String userById(String id) => '/api/v1/users/$id';

  /// Images from this backend are absolute Cloudinary URLs — use them directly.
  /// This helper is kept for backward compatibility but should not be needed.
  static String imageUrl(String path) => path.startsWith('http') ? path : '$baseUrl/$path';
}
