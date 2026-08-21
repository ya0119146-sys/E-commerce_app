import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API endpoint constants for the Labella backend.
class ApiConstants {
  ApiConstants._();

  /// Base URL — loaded from .env.
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  // ─── Auth ───
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String adminLogin = '/auth/login/admin';
  static const String forgetPassword = '/auth/forget-password';
  static const String verifyCode = '/auth/verify-code';
  static const String resetPassword = '/auth/reset-password';

  // ─── Profile ───
  static const String profile = '/profile/me';
  static const String profileUpdate = '/profile/updateMe';
  static const String profileDelete = '/profile/delete';
  static const String changePassword = '/profile/change-password';

  // ─── Products ───
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static const String createProduct = '/products';
  static String updateProduct(String id) => '/products/$id';
  static String deleteProduct(String id) => '/products/$id';

  // ─── Categories ───
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';
  static String subcategories(String categoryId) =>
      '/categories/$categoryId/subcategories';

  // ─── Subcategories ───
  static const String getAllSubcategories = '/subcategories';
  static String getSubcategoryById(String id) => '/subcategories/$id';
  static String createSubCategory = '/subcategories';
  static String updateSubCategory(String id) => '/subcategories/$id';
  static String deleteSubCategory(String id) => '/subcategories/$id';

  // ─── Cart ───
  static const String cart = '/cart';
  static const String addToCart = '/cart/add';
  static const String removeFromCart = '/cart/remove';
  static const String deleteCart = '/cart';
  static const String updateCart = '/cart/update';

  // ─── Wishlist ───
  static const String getWishlist = '/wishlist';
  static const String addToWishlist = '/wishlist';
  static String deleteWishlist(String id) => '/wishlist/$id';

  // ─── Address ───
  static const String address = '/address';
  static const String addressAdd = '/address';
  static String addressDelete(String id) => '/address/$id';

  // ─── Orders ───
  static const String order = '/order';
  static String orderDetails(String orderId) => '/order/$orderId';
  static String orderDeliver(String orderId) => '/order/$orderId/deliver';
  static String orderPay(String orderId) => '/order/$orderId/pay';

  // ─── Reviews ───
  static const String reviews = '/reviews';
  static String reviewsByProductId(String productId) =>
      '/products/$productId/reviews';
  static String updateReview(String id) => '/reviews/$id';
  static String createReview = '/reviews';
  static String deleteReview(String id) => '/reviews/$id';

  // ─── Users (Admin) ───
  static const String users = '/users';
  static String userById(String id) => '/users/$id';

  /// Builds the full image URL from a relative path.
  static String imageUrl(String path) => '$baseUrl/$path';
}
