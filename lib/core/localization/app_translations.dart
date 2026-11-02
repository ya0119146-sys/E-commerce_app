import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'locale_cubit.dart';

/// Comprehensive two-dictionary localization system for Labella.
/// Contains English and Arabic dictionaries for every string in the application.
class AppTranslations {
  AppTranslations._();

  /// English Dictionary
  static const Map<String, String> en = {
    // ─── App General ───
    'app_name': 'Labella',
    'app_tagline': 'Sign in to continue your luxury experience',
    'luxury_tagline': 'Join the world of luxury beauty',
    'cancel': 'Cancel',
    'save': 'Save',
    'confirm': 'Confirm',
    'delete': 'Delete',
    'remove': 'Remove',
    'edit': 'Edit',
    'done': 'Done',
    'close': 'Close',
    'back': 'Back',
    'search': 'Search',
    'search_products': 'Search luxury cosmetics, skincare...',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'retry': 'Retry',
    'warning': 'Warning',
    'show_more': 'Show more',
    'show_less': 'Show less',

    // ─── Navigation ───
    'nav_home': 'Home',
    'nav_store': 'Store',
    'nav_cart': 'Cart',
    'nav_wishlist': 'Wishlist',
    'nav_profile': 'Profile',

    // ─── Authentication ───
    'welcome_back': 'Welcome back',
    'sign_in': 'Sign In',
    'sign_up': 'Create Account',
    'create_account': 'Create Account',
    'dont_have_account': "Don't have an account?",
    'already_have_account': 'Already have an account?',
    'email': 'Email',
    'email_hint': 'Enter your email',
    'password': 'Password',
    'password_hint': 'Enter your password',
    'confirm_password': 'Confirm Password',
    'confirm_password_hint': 'Confirm your password',
    'full_name': 'Full Name',
    'full_name_hint': 'Enter your full name',
    'username': 'Username',
    'username_hint': 'Enter your username',
    'phone_number': 'Phone Number',
    'phone_number_hint': 'Enter your phone number',
    'forgot_password': 'Forgot Password?',
    'forgot_password_title': 'Reset Password',
    'forgot_password_subtitle': 'Enter your email address and we will send you a verification code.',
    'send_code': 'Send Code',
    'verify_code': 'Verify Code',
    'verify_code_subtitle': 'Enter the 6-digit code sent to your email',
    'enter_new_password': 'Enter New Password',
    'new_password': 'New Password',
    'reset_password': 'Reset Password',
    'password_reset_success': 'Password reset successfully! Please sign in.',
    'account_created': 'Account created! Please log in.',
    'login_success': 'Welcome back!',
    'session_expired': 'Session expired. Please sign in again.',
    'please_enter_email': 'Please enter your email',
    'please_enter_valid_email': 'Please enter a valid email address',
    'please_enter_password': 'Please enter your password',
    'password_too_short': 'Password must be at least 6 characters',
    'passwords_dont_match': 'Passwords do not match',
    'please_enter_name': 'Please enter your name',
    'please_enter_username': 'Please enter your username',
    'please_enter_phone': 'Please enter your phone number',
    'phone_invalid': 'Please enter a valid phone number (10-15 digits)',

    // ─── Store & Products ───
    'all_products': 'All Products',
    'categories': 'Categories',
    'featured': 'Featured',
    'new_arrivals': 'New Arrivals',
    'best_sellers': 'Best Sellers',
    'sale': 'SALE',
    'in_stock': 'In Stock',
    'out_of_stock': 'Out of Stock',
    'add_to_cart': 'Add to Cart',
    'added_to_cart': 'Added to cart!',
    'view_cart': 'View Cart',
    'rating': 'Rating',
    'reviews': 'Reviews',
    'no_reviews': 'No reviews yet. Be the first to review!',
    'write_review': 'Write a Review',
    'your_review': 'Your Review',
    'submit_review': 'Submit Review',
    'review_submitted': 'Review submitted successfully!',
    'description': 'Description',
    'price': 'Price',
    'quantity': 'Quantity',
    'product_details': 'Product Details',
    'no_products_found': 'No products found',
    'pinch_to_zoom': 'Pinch or double tap to zoom',

    // ─── Cart & Checkout ───
    'your_cart': 'Your Cart',
    'cart_empty': 'Your cart is empty',
    'cart_empty_subtitle': 'Explore our luxury collection and add items to your cart',
    'start_shopping': 'Start Shopping',
    'subtotal': 'Subtotal',
    'delivery_fee': 'Delivery Fee',
    'total': 'Total',
    'checkout': 'Checkout',
    'place_order': 'Place Order',
    'order_summary': 'Order Summary',
    'shipping_address': 'Shipping Address',
    'payment_method': 'Payment Method',
    'cash_on_delivery': 'Cash on Delivery',
    'order_placed_success': 'Order placed successfully!',
    'thank_you_order': 'Thank you for your order.',
    'address': 'Address',
    'street': 'Street Address',
    'city': 'City',
    'phone': 'Phone',
    'postal_code': 'Postal Code',
    'add_new_address': 'Add New Address',
    'select_address': 'Select Shipping Address',
    'remove_from_cart': 'Remove from cart',
    'item_removed': 'Item removed from cart',
    'clear_cart': 'Clear Cart',
    'items_count': 'items',

    // ─── Wishlist ───
    'your_wishlist': 'Your Wishlist',
    'wishlist_empty': 'Your wishlist is empty',
    'wishlist_empty_subtitle': 'Save items you love to revisit anytime',
    'added_to_wishlist': 'Added to wishlist',
    'removed_from_wishlist': 'Removed from wishlist',

    // ─── Profile & Settings ───
    'my_profile': 'My Profile',
    'profile': 'Profile',
    'edit_profile': 'Edit Profile',
    'personal_information': 'Personal Information',
    'orders': 'Orders',
    'my_orders': 'My Orders',
    'no_orders': 'No orders yet',
    'order_id': 'Order ID',
    'order_date': 'Date',
    'order_status': 'Status',
    'dark_mode': 'Dark Mode',
    'language': 'Language',
    'current_language': 'English',
    'change_language': 'Change Language',
    'arabic': 'العربية',
    'english': 'English',
    'change_password': 'Change Password',
    'current_password': 'Current Password',
    'logout': 'Log Out',
    'logout_confirm_title': 'Log Out',
    'logout_confirm_message': 'Are you sure you want to log out?',
    'delete_account': 'Delete Account',
    'delete_account_confirm': 'Are you sure you want to delete your account? This action cannot be undone.',
    'admin_dashboard': 'Admin Dashboard',
    'manage_products': 'Manage Products',
    'manage_categories': 'Manage Categories',
    'manage_orders': 'Manage Orders',
    'manage_users': 'Manage Users',
    'profile_updated': 'Profile updated successfully!',
    'password_changed': 'Password changed successfully!',
  };

  /// Arabic Dictionary
  static const Map<String, String> ar = {
    // ─── App General ───
    'app_name': 'لابيلا',
    'app_tagline': 'سجل الدخول لمواصلة تجربة التسوق الفاخرة',
    'luxury_tagline': 'انضم إلى عالم الجمال والفخامة',
    'cancel': 'إلغاء',
    'save': 'حفظ',
    'confirm': 'تأكيد',
    'delete': 'حذف',
    'remove': 'إزالة',
    'edit': 'تعديل',
    'done': 'تم',
    'close': 'إغلاق',
    'back': 'رجوع',
    'search': 'بحث',
    'search_products': 'ابحث عن مستحضرات التجميل، العناية بالبشرة...',
    'loading': 'جاري التحميل...',
    'error': 'خطأ',
    'success': 'نجاح',
    'retry': 'إعادة المحاولة',
    'warning': 'تنبيه',
    'show_more': 'عرض المزيد',
    'show_less': 'عرض أقل',

    // ─── Navigation ───
    'nav_home': 'الرئيسية',
    'nav_store': 'المتجر',
    'nav_cart': 'السلة',
    'nav_wishlist': 'المفضلة',
    'nav_profile': 'حسابي',

    // ─── Authentication ───
    'welcome_back': 'مرحباً بعودتك',
    'sign_in': 'تسجيل الدخول',
    'sign_up': 'إنشاء حساب جديد',
    'create_account': 'إنشاء حساب',
    'dont_have_account': 'ليس لديك حساب؟',
    'already_have_account': 'لديك حساب بالفعل؟',
    'email': 'البريد الإلكتروني',
    'email_hint': 'أدخل بريدك الإلكتروني',
    'password': 'كلمة المرور',
    'password_hint': 'أدخل كلمة المرور',
    'confirm_password': 'تأكيد كلمة المرور',
    'confirm_password_hint': 'أعد إدخال كلمة المرور',
    'full_name': 'الاسم الكامل',
    'full_name_hint': 'أدخل اسمك الكامل',
    'username': 'اسم المستخدم',
    'username_hint': 'أدخل اسم المستخدم',
    'phone_number': 'رقم الهاتف',
    'phone_number_hint': 'أدخل رقم هاتفك',
    'forgot_password': 'نسيت كلمة المرور؟',
    'forgot_password_title': 'استعادة كلمة المرور',
    'forgot_password_subtitle': 'أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق.',
    'send_code': 'إرسال الرمز',
    'verify_code': 'تأكيد الرمز',
    'verify_code_subtitle': 'أدخل الرمز المكون من 6 أرقام المرسل إلى بريدك',
    'enter_new_password': 'أدخل كلمة المرور الجديدة',
    'new_password': 'كلمة المرور الجديدة',
    'reset_password': 'إعادة تعيين كلمة المرور',
    'password_reset_success': 'تمت إعادة تعيين كلمة المرور بنجاح! يرجى تسجيل الدخول.',
    'account_created': 'تم إنشاء الحساب بنجاح! يرجى تسجيل الدخول.',
    'login_success': 'مرحباً بعودتك!',
    'session_expired': 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.',
    'please_enter_email': 'يرجى إدخال البريد الإلكتروني',
    'please_enter_valid_email': 'يرجى إدخال بريد إلكتروني صحيح',
    'please_enter_password': 'يرجى إدخال كلمة المرور',
    'password_too_short': 'كلمة المرور يجب أن لا تقل عن 6 أحرف',
    'passwords_dont_match': 'كلمتا المرور غير متطابقتين',
    'please_enter_name': 'يرجى إدخال اسمك',
    'please_enter_username': 'يرجى إدخال اسم المستخدم',
    'please_enter_phone': 'يرجى إدخال رقم الهاتف',
    'phone_invalid': 'يرجى إدخال رقم هاتف صحيح (10-15 رقماً)',

    // ─── Store & Products ───
    'all_products': 'جميع المنتجات',
    'categories': 'التصنيفات',
    'featured': 'المميزة',
    'new_arrivals': 'وصل حديثاً',
    'best_sellers': 'الأكثر مبيعاً',
    'sale': 'تخفيض',
    'in_stock': 'متوفر',
    'out_of_stock': 'غير متوفر',
    'add_to_cart': 'إضافة إلى السلة',
    'added_to_cart': 'تمت الإضافة إلى السلة!',
    'view_cart': 'عرض السلة',
    'rating': 'التقييم',
    'reviews': 'التقييمات',
    'no_reviews': 'لا توجد تقييمات بعد. كن أول من يقيّم!',
    'write_review': 'أضف تقييماً',
    'your_review': 'تقييمك',
    'submit_review': 'إرسال التقييم',
    'review_submitted': 'تم إرسال التقييم بنجاح!',
    'description': 'الوصف',
    'price': 'السعر',
    'quantity': 'الكمية',
    'product_details': 'تفاصيل المنتج',
    'no_products_found': 'لم يتم العثور على منتجات',
    'pinch_to_zoom': 'قرّب بالإصبعين أو اضغط مرتين للتكبير',

    // ─── Cart & Checkout ───
    'your_cart': 'سلة المشتريات',
    'cart_empty': 'سلتك فارغة',
    'cart_empty_subtitle': 'استكشف تشكيلتنا الفاخرة وأضف منتجاتك المفضلة',
    'start_shopping': 'ابدأ التسوق',
    'subtotal': 'المجموع الفرعي',
    'delivery_fee': 'قيمة التوصيل',
    'total': 'الإجمالي',
    'checkout': 'إتمام الطلب',
    'place_order': 'تأكيد الطلب',
    'order_summary': 'ملخص الطلب',
    'shipping_address': 'عنوان الشحن',
    'payment_method': 'طريقة الدفع',
    'cash_on_delivery': 'الدفع عند الاستلام',
    'order_placed_success': 'تم تأكيد طلبك بنجاح!',
    'thank_you_order': 'شكراً لطلبك من لابيلا.',
    'address': 'العنوان',
    'street': 'اسم الشارع / العنوان',
    'city': 'المدينة',
    'phone': 'الهاتف',
    'postal_code': 'الرمز البريدي',
    'add_new_address': 'إضافة عنوان جديد',
    'select_address': 'اختر عنوان الشحن',
    'remove_from_cart': 'إزالة من السلة',
    'item_removed': 'تمت إزالة المنتج من السلة',
    'clear_cart': 'تفريغ السلة',
    'items_count': 'منتجات',

    // ─── Wishlist ───
    'your_wishlist': 'قائمة أمنياتك',
    'wishlist_empty': 'قائمة الأمنيات فارغة',
    'wishlist_empty_subtitle': 'احفظ منتجاتك المفضلة لتعود إليها في أي وقت',
    'added_to_wishlist': 'تمت الإضافة إلى المفضلة',
    'removed_from_wishlist': 'تمت الإزالة من المفضلة',

    // ─── Profile & Settings ───
    'my_profile': 'الملف الشخصي',
    'profile': 'حسابي',
    'edit_profile': 'تعديل الملف الشخصي',
    'personal_information': 'المعلومات الشخصية',
    'orders': 'الطلبات',
    'my_orders': 'طلباتي',
    'no_orders': 'لا توجد طلبات سابقة',
    'order_id': 'رقم الطلب',
    'order_date': 'التاريخ',
    'order_status': 'الحالة',
    'dark_mode': 'الوضع الداكن',
    'language': 'اللغة',
    'current_language': 'العربية',
    'change_language': 'تغيير اللغة',
    'arabic': 'العربية',
    'english': 'English',
    'change_password': 'تغيير كلمة المرور',
    'current_password': 'كلمة المرور الحالية',
    'logout': 'تسجيل الخروج',
    'logout_confirm_title': 'تسجيل الخروج',
    'logout_confirm_message': 'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
    'delete_account': 'حذف الحساب',
    'delete_account_confirm': 'هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.',
    'admin_dashboard': 'لوحة تحكم المشرف',
    'manage_products': 'إدارة المنتجات',
    'manage_categories': 'إدارة التصنيفات',
    'manage_orders': 'إدارة الطلبات',
    'manage_users': 'إدارة المستخدمين',
    'profile_updated': 'تم تحديث الملف الشخصي بنجاح!',
    'password_changed': 'تم تغيير كلمة المرور بنجاح!',
  };

  /// Translate key according to current locale
  static String translate(String key, String languageCode) {
    final dict = languageCode == 'ar' ? ar : en;
    if (dict.containsKey(key)) {
      return dict[key]!;
    }
    // Fallback: check other language dictionary
    final fallbackDict = languageCode == 'ar' ? en : ar;
    if (fallbackDict.containsKey(key)) {
      return fallbackDict[key]!;
    }
    return key;
  }
}

/// Handy extension on String for translating keys: `'sign_in'.tr(context)`
extension StringTranslationExtension on String {
  String tr(BuildContext context) {
    try {
      final localeState = context.watch<LocaleCubit>().state;
      return AppTranslations.translate(this, localeState.locale.languageCode);
    } catch (_) {
      return this;
    }
  }

  /// Read without watch (e.g. in callbacks / initState)
  String trOnce(BuildContext context) {
    try {
      final localeState = context.read<LocaleCubit>().state;
      return AppTranslations.translate(this, localeState.locale.languageCode);
    } catch (_) {
      return this;
    }
  }
}

/// Handy extension on BuildContext: `context.tr('sign_in')`
extension ContextTranslationExtension on BuildContext {
  String tr(String key) {
    try {
      final localeState = watch<LocaleCubit>().state;
      return AppTranslations.translate(key, localeState.locale.languageCode);
    } catch (_) {
      return key;
    }
  }

  bool get isArabic {
    try {
      return watch<LocaleCubit>().isArabic;
    } catch (_) {
      return false;
    }
  }
}
