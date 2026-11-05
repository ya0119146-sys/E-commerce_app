import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'locale_cubit.dart';

/// Comprehensive two-dictionary localization system for Labella.

/// Contains English and Arabic dictionaries for every single screen, widget, dialog, and message.

class AppTranslations {
  AppTranslations._();

  /// English Dictionary

  static const Map<String, String> en = {
    'invalid_login': 'Invalid email or password',

    'Invalid email or password': 'Invalid email or password',

    'Invalid Email or Password': 'Invalid Email or Password',

    'Invalid Email Or Password': 'Invalid Email Or Password',

    'check_email': 'Email not found',

    'Email not found': 'Email not found',

    'send_email': 'Error while sending email, please try again later',

    'Error while sending email, please try again later':
        'Error while sending email, please try again later',

    'Error while sending mail... try again later':
        'Error while sending mail... try again later',

    'check_verify_code': 'You do not have permission to verify reset code',

    'You do not have permission to verify reset code':
        'You do not have permission to verify reset code',

    'you don\'t have permission to verify reset code':
        'You do not have permission to verify reset code',

    'check_code_valid': 'Invalid or expired reset code',

    'Invalid or expired reset code': 'Invalid or expired reset code',

    'check_reset_code': 'You do not have permission to change password',

    'You do not have permission to change password':
        'You do not have permission to change password',

    'You don\'t have permission to change password':
        'You don\'t have permission to change password',

    'check_code_verify': 'Please verify your code first',

    'Please verify your code first': 'Please verify your code first',

    'check_login': 'You are not logged in! Please log in to get access',

    'You are not logged in! Please log in to get access':
        'You are not logged in! Please log in to get access',

    'You are not logged in! Please log in to get access.':
        'You are not logged in! Please log in to get access.',

    'check_user': 'The user no longer exists',

    'The user no longer exists': 'The user no longer exists',

    'The user does not exist anymore...': 'The user does not exist anymore...',

    'sign UP First': 'Please sign up first',

    'check_password_changed':
        'Your password was recently changed. Please log in again',

    'Your password was recently changed. Please log in again':
        'Your password was recently changed. Please log in again',

    'Your password has been updated since you logged in last time. Please log in again.':
        'Your password has been updated since you logged in last time. Please log in again.',

    'logIn Again you or Your manager changed Your Password':
        'Your password was updated. Please log in again.',

    'check_active': 'Your account is deactivated',

    'Your account is deactivated': 'Your account is deactivated',

    'You are not Active': 'You are not Active',

    'allowed_to': 'Privilege denied! You cannot perform this action',

    'Privilege denied! You cannot perform this action':
        'Privilege denied! You cannot perform this action',

    'not_authorized': 'You are not authorized to perform this action',

    'You are not authorized to perform this action':
        'You are not authorized to perform this action',

    'You are not authorized to do that': 'You are not authorized to do that',

    'UserName already exist': 'Username already exists',

    'Username already exists': 'Username already exists',

    'success_signup': 'Signed up successfully, please login',

    'Signed up successfully, please login':
        'Signed up successfully, please login',

    'signed up successfully , please login':
        'signed up successfully , please login',

    'code_verified_success': 'Code verified successfully',

    'Code verified successfully': 'Code verified successfully',

    'reset_code_sent': 'Reset code sent successfully',

    'Reset code sent successfully': 'Reset code sent successfully',

    'reset code sent successfully': 'reset code sent successfully',

    'wrong_password': 'Please enter your current password',

    'Please enter your current password': 'Please enter your current password',

    'Please Enter Your Currant Password': 'Please Enter Your Currant Password',

    'Session expired, please login again':
        'Session expired, please login again',

    'session time Expired, please login again..':
        'session time Expired, please login again..',

    'Session expired. Please log in again.':
        'Session expired. Please log in again.',

    'not_found': 'Data not found',

    'Data not found': 'Data not found',

    'invalid_id': 'Invalid ID',

    'Invalid ID': 'Invalid ID',

    'Invalid Id': 'Invalid Id',

    'validation_field': 'Field Required',

    'Field Required': 'Field Required',

    'validation_value': 'Invalid Value',

    'Invalid Value': 'Invalid Value',
    'validation_email_invalid': 'Please enter a valid email address',
    'validation_name': 'This name already exists',

    'This name already exists': 'This name already exists',

    'This name already exits': 'This name already exits',

    'validation_email_check': 'Email already exists',

    'Email already exists': 'Email already exists',

    'Email is Already Exist': 'Email is Already Exist',

    'validation_length_short': 'Length must be between 2 and 50 characters',

    'Length must be between 2 and 50 characters':
        'Length must be between 2 and 50 characters',

    'length is between 10, 50': 'length is between 10, 50',

    'validation_length_phone':
        'Phone number length must be between 11 and 15 digits',

    'Phone number length must be between 11 and 15 digits':
        'Phone number length must be between 11 and 15 digits',

    'length must be between 11 ,15': 'length must be between 11 ,15',

    'validation_length_medium': 'Length must be between 10 and 150 characters',

    'Length must be between 10 and 150 characters':
        'Length must be between 10 and 150 characters',

    'length is between 10, 150': 'length is between 10, 150',

    'validation_length_long': 'Length must be between 10 and 500 characters',

    'Length must be between 10 and 500 characters':
        'Length must be between 10 and 500 characters',

    'length is between 10, 500': 'length is between 10, 500',

    'validation_length_password':
        'Password must be between 6 and 20 characters',
    'Reset code sent to your email': 'Reset code sent to your email',
    'Code verified': 'Code verified',
    'Invalid reset code': 'Invalid reset code',
    'Reset session expired. Please request a new reset code.':
        'Reset session expired. Please request a new reset code.',
    'Failed to reset password': 'Failed to reset password',
    'Failed to send reset code': 'Failed to send reset code',
    'Failed to verify reset code': 'Failed to verify reset code',

    'Password must be between 6 and 20 characters':
        'Password must be between 6 and 20 characters',

    'Password is between 6, 20': 'Password is between 6, 20',

    'validation_password_match': 'Passwords do not match',

    'password don\'t match': 'Passwords do not match',

    'validation_phone_format': 'Invalid Phone Number',

    'Invalid Phone Number': 'Invalid Phone Number',

    'your cart is empty': 'your cart is empty',

    'السلة فارغة': 'Your cart is empty',

    'cart_cleared': 'Cart cleared successfully',

    'Cart cleared successfully': 'Cart cleared successfully',

    'Cart Cleared Successfully': 'Cart Cleared Successfully',

    'no_such_product': 'There is no such product in cart',

    'There is no such product in cart': 'There is no such product in cart',

    'There is no such product': 'There is no such product',

    'quantity_positive_integer': 'Quantity must be a positive integer',

    'Quantity must be a positive integer':
        'Quantity must be a positive integer',

    'quantity must be a positive integer':
        'quantity must be a positive integer',

    'quantity_max_stock': 'Quantity exceeds available stock',

    'Quantity exceeds available stock': 'Quantity exceeds available stock',

    'wishlist_empty': 'Your wishlist is empty',

    'review_already_exists': 'You have already reviewed this product',

    'You have already reviewed this product':
        'You have already reviewed this product',

    'review_not_found': 'Review not found',

    'Review not found': 'Review not found',

    'invalid_address': 'Invalid address ID',

    'Invalid address ID': 'Invalid address ID',

    'address_not_found': 'Address not found',

    'Address not found': 'Address not found',

    'address_deleted': 'Address deleted successfully',

    'Address deleted successfully': 'Address deleted successfully',

    'Address deleted scussefully': 'Address deleted successfully',

    'user_not_found': 'User or addresses not found',

    'User or addresses not found': 'User or addresses not found',

    'item_not_found': 'Item not found',

    'Item not found': 'Item not found',

    'category_not_found': 'Category not found',

    'Category not found': 'Category not found',

    'Catgory DoesNot exits': 'Category not found',

    'category_exists': 'Category name already exists',

    'Category name already exists': 'Category name already exists',

    'category already exits': 'Category name already exists',

    'Category Name already exits': 'Category name already exists',

    'subcategory_not_found': 'Subcategory not found',

    'Subcategory not found': 'Subcategory not found',

    'Subcategory doesn\'t exit': 'Subcategory not found',

    'subcategory_exists': 'Subcategory name already exists',

    'Subcategory name already exists': 'Subcategory name already exists',

    'subcategory_wrong_category':
        'Subcategory does not belong to this category',

    'Subcategory does not belong to this category':
        'Subcategory does not belong to this category',

    'subcategory doesn\'t exit in that category':
        'Subcategory does not belong to this category',

    'invalid_category_id': 'Invalid category ID',

    'Invalid category ID': 'Invalid category ID',

    'Invalid category id': 'Invalid category ID',

    'Wrong category Id': 'Invalid category ID',

    'wrong category Id': 'Invalid category ID',

    'discount_remove_hint':
        'To remove the discount, set the product price only',

    'To remove the discount, set the product price only':
        'To remove the discount, set the product price only',

    'discount_max_half':
        'Maximum discount cannot exceed half of the product price',

    'Maximum discount cannot exceed half of the product price':
        'Maximum discount cannot exceed half of the product price',

    'discount_min_zero': 'Discount value must be greater than 0',

    'Discount value must be greater than 0':
        'Discount value must be greater than 0',

    'Login failed. Please try again.': 'Login failed. Please try again.',

    'Signup failed. Please try again.': 'Signup failed. Please try again.',

    'Failed to send reset code.': 'Failed to send reset code.',

    'Failed to verify reset code.': 'Failed to verify reset code.',

    'Failed to reset password.': 'Failed to reset password.',

    'Failed to change password.': 'Failed to change password.',

    'Please select a shipping address': 'Please select a shipping address',

    'Failed to load cart': 'Failed to load cart',

    'Failed to load categories': 'Failed to load categories',

    'Failed to load products': 'Failed to load products',

    'Failed to load wishlist': 'Failed to load wishlist',

    'Failed to load product details': 'Failed to load product details',

    'Failed to load product reviews.': 'Failed to load product reviews.',

    'Failed to load your reviews.': 'Failed to load your reviews.',

    'Failed to create review.': 'Failed to create review.',

    'Failed to update review.': 'Failed to update review.',

    'Failed to delete review.': 'Failed to delete review.',

    'Failed to delete profile.': 'Failed to delete profile.',

    'No internet connection.': 'No internet connection.',

    'Connection timed out. Please check your internet.':
        'Connection timed out. Please check your internet.',

    'Something went wrong. Please try again.':
        'Something went wrong. Please try again.',

    'Server error. Please try again later.':
        'Server error. Please try again later.',

    'Invalid request. Please check your input.':
        'Invalid request. Please check your input.',

    'The requested resource was not found.':
        'The requested resource was not found.',

    'You don\'t have permission to perform this action.':
        'You don\'t have permission to perform this action.',

    'Too many requests. Please wait a moment.':
        'Too many requests. Please wait a moment.',

    'Start Shopping': 'Start Shopping',

    'Status': 'Status',

    'Change Password': 'Change Password',

    'Password must be at least 6 characters':
        'Password must be at least 6 characters',

    'Passwords do not match': 'Passwords do not match',

    'not_logged_in': 'Not logged in',

    // ─── App General & Common ───
    'app_name': 'Labella',

    'Labella': 'Labella',

    'app_tagline': 'Sign in to continue your luxury experience',

    'Sign in to continue your luxury experience':
        'Sign in to continue your luxury experience',

    'luxury_tagline': 'Join the world of luxury beauty',
    'Press back again to exit': 'Press back again to exit',

    'Join the world of luxury beauty': 'Join the world of luxury beauty',

    'Discover luxury beauty essentials': 'Discover luxury beauty essentials',

    'cancel': 'Cancel',

    'Cancel': 'Cancel',

    'save': 'Save',

    'Save': 'Save',

    'confirm': 'Confirm',

    'Confirm': 'Confirm',

    'delete': 'Delete',

    'Delete': 'Delete',

    'remove': 'Remove',

    'Remove': 'Remove',

    'edit': 'Edit',

    'Edit': 'Edit',

    'New': 'New',

    'Edit Product': 'Edit Product',

    'Product created successfully!': 'Product created successfully!',
    'Product updated successfully!': 'Product updated successfully!',
    'Product deleted successfully!': 'Product deleted successfully!',
    'Category created successfully!': 'Category created successfully!',
    'Category updated successfully!': 'Category updated successfully!',
    'Category deleted successfully!': 'Category deleted successfully!',
    'Subcategory created successfully!': 'Subcategory created successfully!',
    'Subcategory updated successfully!': 'Subcategory updated successfully!',
    'Subcategory deleted successfully!': 'Subcategory deleted successfully!',
    'User created successfully!': 'User created successfully!',
    'User updated successfully!': 'User updated successfully!',
    'User deleted successfully!': 'User deleted successfully!',
    'Failed to create category': 'Failed to create category',
    'Failed to update category': 'Failed to update category',
    'Failed to delete category': 'Failed to delete category',
    'Failed to create subcategory': 'Failed to create subcategory',
    'Failed to update subcategory': 'Failed to update subcategory',
    'Failed to delete subcategory': 'Failed to delete subcategory',
    'Failed to create product': 'Failed to create product',
    'Failed to update product': 'Failed to update product',
    'Failed to delete product': 'Failed to delete product',
    'Failed to create user': 'Failed to create user',
    'Failed to update user': 'Failed to update user',
    'Failed to delete user': 'Failed to delete user',

    'done': 'Done',

    'Done': 'Done',

    'close': 'Close',

    'Close': 'Close',

    'back': 'Back',

    'Back': 'Back',

    'search': 'Search',

    'Search': 'Search',

    'search_products': 'Search luxury cosmetics, skincare...',

    'Search products...': 'Search products...',

    'Try a different search term': 'Try a different search term',

    'loading': 'Loading...',

    'Loading...': 'Loading...',

    'error': 'Error',

    'Error': 'Error',

    'success': 'Success',

    'Success': 'Success',

    'retry': 'Retry',

    'Retry': 'Retry',

    'warning': 'Warning',

    'Warning': 'Warning',

    'show_more': 'Show more',

    'Show more': 'Show more',

    'show_less': 'Show less',

    'Show less': 'Show less',

    // ─── Navigation ───
    'nav_home': 'Home',

    'Home': 'Home',

    'nav_store': 'Store',

    'Store': 'Store',

    'Shop': 'Shop',

    'Shop Now': 'Shop Now',

    'nav_cart': 'Cart',

    'Cart': 'Cart',

    'nav_wishlist': 'Wishlist',

    'Wishlist': 'Wishlist',

    'nav_profile': 'Profile',

    'Profile': 'Profile',

    // ─── Authentication ───
    'welcome_back': 'Welcome back',

    'Welcome back': 'Welcome back',

    'sign_in': 'Sign In',

    'Sign In': 'Sign In',

    'sign_up': 'Sign Up',

    'Sign Up': 'Sign Up',

    'create_account': 'Create Account',

    'Create Account': 'Create Account',

    "Don't have an account?": "Don't have an account?",

    'dont_have_account': "Don't have an account?",

    'already_have_account': 'Already have an account?',

    'Already have an account?': 'Already have an account?',

    'email': 'Email',

    'Email': 'Email',

    'Email Address': 'Email Address',

    'email_hint': 'Enter your email',

    'password': 'Password',

    'Password': 'Password',

    'password_hint': 'Enter your password',

    'confirm_password': 'Confirm Password',

    'Confirm Password': 'Confirm Password',

    'confirm_password_hint': 'Confirm your password',

    'full_name': 'Full Name',

    'Full Name': 'Full Name',

    'full_name_hint': 'Enter your full name',

    'username': 'Username',

    'Username': 'Username',

    'username_hint': 'Enter your username',

    'phone_number': 'Phone Number',

    'Phone Number': 'Phone Number',

    'Phone': 'Phone',

    'phone_number_hint': 'Enter your phone number',

    'e.g. 01012345678': 'e.g. 01012345678',

    'forgot_password': 'Forgot Password?',

    'Forgot Password?': 'Forgot Password?',

    'forgot_password_title': 'Reset Password',

    'forgot_password_subtitle':
        'Enter your email address to receive a reset code',

    'Enter your email to receive a reset code':
        'Enter your email to receive a reset code',

    'send_code': 'Send Code',

    'Send Code': 'Send Code',

    'verify_code': 'Verify Code',

    'Verify Code': 'Verify Code',

    'verify_code_subtitle': 'Enter the 6-digit code sent to your email',

    'We have sent a verification code to your email':
        'We have sent a verification code to your email',

    'Reset Code': 'Reset Code',

    'Code verified successfully!': 'Code verified successfully!',

    'enter_new_password': 'Enter New Password',

    'Enter your new password below': 'Enter your new password below',

    'new_password': 'New Password',

    'New Password': 'New Password',

    'Set New Password': 'Set New Password',

    'reset_password': 'Reset Password',

    'Reset Password': 'Reset Password',

    'password_reset_success': 'Password reset successfully! Please log in.',

    'Password reset successfully! Please log in.':
        'Password reset successfully! Please log in.',

    'account_created': 'Account created! Please log in.',

    'Account created! Please log in.': 'Account created! Please log in.',

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

    // ─── Store & Home & Products ───
    'all_products': 'All Products',

    'All Products': 'All Products',

    'All': 'All',

    'categories': 'Categories',

    'Categories': 'Categories',

    'featured': 'Featured',

    'New Collection': 'New Collection',

    'Trending Now': 'Trending Now',

    'new_arrivals': 'New Arrivals',

    'best_sellers': 'Best Sellers',

    'sale': 'SALE',

    'SALE': 'SALE',

    'in_stock': 'In Stock',

    'In Stock': 'In Stock',

    'out_of_stock': 'Out of Stock',

    'Out of Stock': 'Out of Stock',

    'add_to_cart': 'Add to Cart',

    'Add to Cart': 'Add to Cart',

    'added_to_cart': 'Added to cart!',

    'Added to cart!': 'Added to cart!',

    'Added to cart ✨': 'Added to cart ✨',

    'view_cart': 'View Cart',

    'rating': 'Rating',

    'reviews': 'Reviews',

    'Reviews': 'Reviews',

    'Customer Reviews': 'Customer Reviews',

    'no_reviews': 'No reviews yet',

    'No reviews yet': 'No reviews yet',

    'No reviews yet. Be the first to review!':
        'No reviews yet. Be the first to review!',

    'write_review': 'Write a Review',

    'Write a Review': 'Write a Review',

    'Add Review': 'Add Review',

    'Delete Review': 'Delete Review',

    'Are you sure you want to delete this review?':
        'Are you sure you want to delete this review?',

    'Could not load reviews': 'Could not load reviews',

    'your_review': 'Your Review',

    'Share your experience with this product...':
        'Share your experience with this product...',

    'submit_review': 'Submit Review',

    'review_submitted': 'Review submitted successfully!',

    'description': 'Description',

    'Description': 'Description',

    'price': 'Price',

    'Price': 'Price',

    'quantity': 'Quantity',

    'Quantity': 'Quantity',

    'product_details': 'Product Details',

    'no_products_found': 'No products found',

    'No products found': 'No products found',

    'pinch_to_zoom': 'Pinch or double tap to zoom',

    // ─── Cart & Checkout ───
    'your_cart': 'My Cart',

    'My Cart': 'My Cart',

    'cart_empty': 'Your cart is empty',

    'Your cart is empty': 'Your cart is empty',

    'cart_empty_subtitle':
        'Explore our luxury collection and add items to your cart',

    'Add some items to get started': 'Add some items to get started',

    'Clear All': 'Clear All',

    'Clear Cart?': 'Clear Cart?',

    'Are you sure you want to remove all items?':
        'Are you sure you want to remove all items?',

    'start_shopping': 'Start Shopping',

    'subtotal': 'Subtotal',

    'Subtotal': 'Subtotal',

    'delivery_fee': 'Delivery Fee',

    'Contact Us': 'Contact Us',

    'Contact on WhatsApp': 'Contact on WhatsApp',

    'Contact Us on WhatsApp': 'Contact Us on WhatsApp',

    'Governorate': 'Governorate',

    'Free Delivery': 'Free Delivery',

    'Calculated at checkout': 'Calculated at checkout',

    'Shipping Policy Note':
        'Free delivery to Al Sharqia • 100 EGP for other governorates',

    'Shipping & Tax': 'Shipping & Tax',

    'total': 'Total',

    'Total': 'Total',

    'checkout': 'Checkout',

    'Checkout': 'Checkout',

    'place_order': 'Place Order',

    'order_summary': 'Order Summary',

    'Order Summary': 'Order Summary',

    'shipping_address': 'Shipping Address',

    'Shipping Address': 'Shipping Address',

    'payment_method': 'Payment Method',

    'cash_on_delivery': 'Cash on Delivery',

    'order_placed_success': 'Order placed successfully!',

    'thank_you_order': 'Thank you for your order.',

    'Order Confirmed!': 'Order Confirmed!',

    'Continue Shopping': 'Continue Shopping',

    'Thank you for your purchase.\nYour order is being processed.':
        'Thank you for your purchase.\nYour order is being processed.',

    'address': 'Address',

    'Street': 'Street',

    'Street Address': 'Street Address',

    'City': 'City',

    'State': 'State',

    'Zip Code': 'Zip Code',

    'ZIP Code': 'ZIP Code',

    'phone': 'Phone',

    'postal_code': 'Postal Code',

    'Add Address': 'Add Address',

    'Add New': 'Add New',

    'Add New Address': 'Add New Address',

    'Add First Address': 'Add First Address',

    'Save Address': 'Save Address',

    'Delete Address': 'Delete Address',

    'Are you sure you want to remove this address?':
        'Are you sure you want to remove this address?',

    'My Addresses': 'My Addresses',

    'No addresses saved yet': 'No addresses saved yet',

    'No addresses saved': 'No addresses saved',

    'select_address': 'Select Shipping Address',

    'remove_from_cart': 'Remove from cart',

    'item_removed': 'Item removed from cart',

    'clear_cart': 'Clear Cart',

    'items_count': 'items',

    'items': 'items',

    'Items': 'Items',

    'Reached maximum stock': 'Reached maximum stock',

    // ─── Wishlist ───
    'your_wishlist': 'Your Wishlist',

    'Your wishlist is empty': 'Your wishlist is empty',

    'wishlist_empty_subtitle': 'Save items you love to revisit anytime',

    'Save items you love to your wishlist and they will appear here.':
        'Save items you love to your wishlist and they will appear here.',

    'Explore Products': 'Explore Products',

    'added_to_wishlist': 'Added to wishlist',

    'removed_from_wishlist': 'Removed from wishlist',

    // ─── Profile & Orders ───
    'my_profile': 'My Profile',

    'edit_profile': 'Edit Profile',

    'personal_information': 'Personal Information',

    'orders': 'Orders',

    'my_orders': 'My Orders',

    'Order History': 'Order History',

    'Order Details': 'Order Details',

    'No orders yet': 'No orders yet',

    'no_orders': 'No orders yet',

    'order_id': 'Order ID',

    'Order ID': 'Order ID',

    'order_date': 'Date',

    'order_status': 'Status',

    'Customer': 'Customer',

    'Mark as Delivered': 'Mark as Delivered',

    'Mark as Paid': 'Mark as Paid',

    'Mark Deposit as Paid': 'Mark Deposit as Paid',

    'Deposit Paid': 'Deposit Paid',

    'Deposit Pending': 'Deposit Pending',

    'Deposit': 'Deposit',

    'No address provided': 'No address provided',

    'dark_mode': 'Dark Mode',

    'language': 'Language',

    'current_language': 'English',

    'change_language': 'Change Language',

    'arabic': 'العربية',

    'english': 'English',

    'change_password': 'Change Password',

    'current_password': 'Current Password',

    'Current Password': 'Current Password',

    'Confirm New Password': 'Confirm New Password',

    'Password changed successfully! Please login again.':
        'Password changed successfully! Please login again.',

    'Enter name': 'Enter name',

    'Not logged in': 'Not logged in',

    'logout': 'Log Out',

    'Log Out': 'Log Out',

    'logout_confirm_title': 'Log Out',

    'logout_confirm_message': 'Are you sure you want to log out?',

    'delete_account': 'Delete Account',

    'Delete Account': 'Delete Account',

    'delete_account_confirm':
        'Are you sure you want to delete your account? This action cannot be undone.',

    'Profile deleted successfully': 'Profile deleted successfully',

    // ─── Admin Panel ───

    // ─── Admin Panel ───
    'admin_dashboard': 'Admin Dashboard',

    'Admin Panel': 'Admin Panel',

    'Confirm Delete': 'Confirm Delete',

    'Are you sure you want to delete this item?':
        'Are you sure you want to delete this item?',

    'No orders found': 'No orders found',

    'No users found': 'No users found',

    'manage_products': 'Manage Products',

    'manage_categories': 'Manage Categories',

    'manage_orders': 'Manage Orders',

    'manage_users': 'Manage Users',

    'Product Name': 'Product Name',

    'Cover Image': 'Cover Image',

    'Additional Images': 'Additional Images',

    'Add More': 'Add More',

    'Pick multiple images': 'Pick multiple images',

    'Size': 'Size',
    'Size (e.g. S, M, L, XL, Standard)': 'Size (e.g. S, M, L, XL, Standard)',

    'Category': 'Category',

    'Category Name': 'Category Name',

    'Subcategory': 'Subcategory',

    'Subcategory Name': 'Subcategory Name',

    'Subcategory Image': 'Subcategory Image',

    'Parent Category': 'Parent Category',

    'Please select a parent category': 'Please select a parent category',

    'Role': 'Role',

    'User': 'User',

    'Admin': 'Admin',

    'Confirm Order': 'Confirm Order',

    'Required': 'Required',

    'View Order Details': 'View Order Details',

    'Tax & Shipping': 'Tax & Shipping',

    'PAID': 'PAID',

    'UNPAID': 'UNPAID',

    'DELIVERED': 'DELIVERED',

    'PENDING DELIVERY': 'PENDING DELIVERY',

    'Pending': 'Pending',

    'Paid': 'Paid',

    'Unpaid': 'Unpaid',

    'Delivered': 'Delivered',

    'Try Again': 'Try Again',

    'Reviews will appear here when customers share feedback.':
        'Reviews will appear here when customers share feedback.',

    'Be the first to share your experience.':
        'Be the first to share your experience.',

    'review': 'review',

    'Delete review': 'Delete review',

    'Please enter a review': 'Please enter a review',

    'Submit': 'Submit',

    'Operation successful': 'Operation successful',

    'Error occurred': 'Error occurred',

    'Products': 'Products',

    'Orders': 'Orders',

    'Users': 'Users',

    'Subcategories': 'Subcategories',

    'Create Product': 'Create Product',

    'Tap to choose cover': 'Tap to choose cover',

    'Update Product': 'Update Product',

    'Create Category': 'Create Category',

    'Update Category': 'Update Category',

    'Create Subcategory': 'Create Subcategory',

    'Update Subcategory': 'Update Subcategory',

    'Create User': 'Create User',

    'Update User': 'Update User',

    'Category (Optional)': 'Category (Optional)',

    'Subcategory (Optional)': 'Subcategory (Optional)',

    'None (Optional)': 'None (Optional)',

    'None': 'None',

    'Create': 'Create',

    'Update': 'Update',

    'Size is required': 'Size is required',

    'Name is required': 'Name is required',

    'Parent category is required': 'Parent category is required',

    'Phone is required': 'Phone is required',

    'Must be 11-15 digits': 'Must be 11-15 digits',

    'Invalid email': 'Invalid email',

    'Min 6 characters': 'Min 6 characters',

    'Please enter current password': 'Please enter current password',

    'Please enter new password': 'Please enter new password',

    'By': 'By',
    'Discount (%)': 'Discount (%)',
    'Price after discount': 'Price after discount',
    '0-99': '0-99',
    'Must be 0-99': 'Must be 0-99',
    'You save': 'You save',
    'Exclusive Collection': 'Exclusive Collection',
    'Special Offers': 'Special Offers',
    'Up to 50% Off': 'Up to 50% Off',
    'On luxury skincare and premium fragrances':
        'On luxury skincare and premium fragrances',
    'Radiant Beauty': 'Radiant Beauty',
    'Selected from world-class luxury beauty brands':
        'Selected from world-class luxury beauty brands',

    // ─── Guest Browsing & Auth Protection ───
    'Sign in required': 'Sign in required',
    'Please sign in to add products to your wishlist.':
        'Please sign in to add products to your wishlist.',
    'Please sign in to add products to your cart.':
        'Please sign in to add products to your cart.',
    'Please sign in to complete your purchase.':
        'Please sign in to complete your purchase.',
    'Please sign in to access your personal account.':
        'Please sign in to access your personal account.',
    'Not Now': 'Not Now',
    'Welcome to Labella': 'Welcome to Labella',
    'Sign in or create an account to enjoy your complete shopping experience.':
        'Sign in or create an account to enjoy your complete shopping experience.',
    'Member Benefits': 'Member Benefits',
    'Order Tracking': 'Order Tracking',
    'Track your orders and follow their delivery status.':
        'Track your orders and follow their delivery status.',
    'Save your favorite products and access them anytime.':
        'Save your favorite products and access them anytime.',
    'Faster Checkout': 'Faster Checkout',
    'Save your delivery information for a smoother shopping experience.':
        'Save your delivery information for a smoother shopping experience.',
    'Personal Account': 'Personal Account',
    'Manage your profile and view your shopping history.':
        'Manage your profile and view your shopping history.',
    'Your cart is waiting': 'Your cart is waiting',
    'Please sign in to view your cart and start shopping.':
        'Please sign in to view your cart and start shopping.',
    'Your wishlist is waiting': 'Your wishlist is waiting',
    'Please sign in to view and save your favorite items.':
        'Please sign in to view and save your favorite items.',
    'Explore Store': 'Explore Store',
    'Guest': 'Guest',
    'Guest Account': 'Guest Account',
    'guest': 'Guest',
  };

  /// Arabic Dictionary

  static const Map<String, String> ar = {
    'invalid_login': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',

    'Invalid email or password': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',

    'Invalid Email or Password': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',

    'Invalid Email Or Password': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',

    'check_email': 'البريد الإلكتروني غير موجود',

    'Email not found': 'البريد الإلكتروني غير موجود',

    'send_email': 'حدث خطأ أثناء إرسال البريد الإلكتروني، يرجى المحاولة لاحقاً',

    'Error while sending email, please try again later':
        'حدث خطأ أثناء إرسال البريد الإلكتروني، يرجى المحاولة لاحقاً',

    'Error while sending mail... try again later':
        'حدث خطأ أثناء إرسال البريد الإلكتروني، يرجى المحاولة لاحقاً',

    'check_verify_code': 'ليس لديك إذن لتأكيد رمز الاستعادة',

    'You do not have permission to verify reset code':
        'ليس لديك إذن لتأكيد رمز الاستعادة',

    'you don\'t have permission to verify reset code':
        'ليس لديك إذن لتأكيد رمز الاستعادة',

    'check_code_valid': 'رمز تحقق غير صالح أو منتهي الصلاحية',

    'Invalid or expired reset code': 'رمز تحقق غير صالح أو منتهي الصلاحية',

    'check_reset_code': 'ليس لديك إذن لتغيير كلمة المرور',

    'You do not have permission to change password':
        'ليس لديك إذن لتغيير كلمة المرور',

    'You don\'t have permission to change password':
        'ليس لديك إذن لتغيير كلمة المرور',

    'check_code_verify': 'يرجى التحقق من الرمز أولاً',

    'Please verify your code first': 'يرجى التحقق من الرمز أولاً',

    'check_login': 'يرجى تسجيل الدخول أولاً للوصول',

    'You are not logged in! Please log in to get access':
        'يرجى تسجيل الدخول أولاً للوصول',

    'You are not logged in! Please log in to get access.':
        'يرجى تسجيل الدخول أولاً للوصول',

    'check_user': 'المستخدم غير موجود',

    'The user no longer exists': 'المستخدم غير موجود',

    'The user does not exist anymore...': 'المستخدم غير موجود',

    'sign UP First': 'يرجى إنشاء حساب أولاً',

    'check_password_changed':
        'تم تحديث كلمة المرور مؤخراً. يرجى تسجيل الدخول مجدداً',

    'Your password was recently changed. Please log in again':
        'تم تحديث كلمة المرور مؤخراً. يرجى تسجيل الدخول مجدداً',

    'Your password has been updated since you logged in last time. Please log in again.':
        'تم تحديث كلمة المرور مؤخراً. يرجى تسجيل الدخول مجدداً',

    'logIn Again you or Your manager changed Your Password':
        'تم تحديث كلمة المرور مؤخراً. يرجى تسجيل الدخول مجدداً',

    'check_active': 'تم تعطيل حسابك',

    'Your account is deactivated': 'تم تعطيل حسابك',

    'You are not Active': 'تم تعطيل حسابك',

    'allowed_to': 'غير مصرح لك بالقيام بهذا الإجراء',

    'Privilege denied! You cannot perform this action':
        'غير مصرح لك بالقيام بهذا الإجراء',

    'not_authorized': 'غير مصرح لك بالقيام بهذه العملية',

    'You are not authorized to perform this action':
        'غير مصرح لك بالقيام بهذه العملية',

    'You are not authorized to do that': 'غير مصرح لك بالقيام بهذا الإجراء',

    'UserName already exist': 'اسم المستخدم موجود بالفعل',

    'Username already exists': 'اسم المستخدم موجود بالفعل',

    'success_signup': 'تم إنشاء الحساب بنجاح، يرجى تسجيل الدخول',

    'Signed up successfully, please login':
        'تم إنشاء الحساب بنجاح، يرجى تسجيل الدخول',

    'signed up successfully , please login':
        'تم إنشاء الحساب بنجاح، يرجى تسجيل الدخول',

    'code_verified_success': 'تم التحقق من الرمز بنجاح',

    'Code verified successfully': 'تم التحقق من الرمز بنجاح',

    'reset_code_sent': 'تم إرسال رمز إعادة التعيين بنجاح',

    'Reset code sent successfully': 'تم إرسال رمز إعادة التعيين بنجاح',

    'reset code sent successfully': 'تم إرسال رمز إعادة التعيين بنجاح',

    'wrong_password': 'الرجاء إدخال كلمة المرور الحالية',

    'Please enter your current password': 'الرجاء إدخال كلمة المرور الحالية',

    'Please Enter Your Currant Password': 'الرجاء إدخال كلمة المرور الحالية',

    'Session expired, please login again':
        'انتهت الجلسة، يرجى تسجيل الدخول مجدداً',

    'session time Expired, please login again..':
        'انتهت الجلسة، يرجى تسجيل الدخول مجدداً',

    'Session expired. Please log in again.':
        'انتهت الجلسة، يرجى تسجيل الدخول مجدداً',

    'not_found': 'لم يتم العثور على البيانات',

    'Data not found': 'لم يتم العثور على البيانات',

    'invalid_id': 'معرف غير صالح',

    'Invalid ID': 'معرف غير صالح',

    'Invalid Id': 'معرف غير صالح',

    'validation_field': 'الحقل مطلوب',

    'Field Required': 'الحقل مطلوب',

    'validation_value': 'قيمة غير صالحة',

    'Invalid Value': 'قيمة غير صالحة',
    'validation_email_invalid': 'يرجى إدخال بريد إلكتروني صالح',
    'validation_name': 'هذا الاسم موجود بالفعل',

    'This name already exists': 'هذا الاسم موجود بالفعل',

    'This name already exits': 'هذا الاسم موجود بالفعل',

    'validation_email_check': 'البريد الإلكتروني موجود بالفعل',

    'Email already exists': 'البريد الإلكتروني موجود بالفعل',

    'Email is Already Exist': 'البريد الإلكتروني موجود بالفعل',

    'validation_length_short': 'يجب أن يكون الطول بين 2 و 50 حرفاً',

    'Length must be between 2 and 50 characters':
        'يجب أن يكون الطول بين 2 و 50 حرفاً',

    'length is between 10, 50': 'يجب أن يكون الطول بين 10 و 50 حرفاً',

    'validation_length_phone': 'يجب أن يتراوح طول رقم الهاتف بين 11 و 15 رقماً',

    'Phone number length must be between 11 and 15 digits':
        'يجب أن يتراوح طول رقم الهاتف بين 11 و 15 رقماً',

    'length must be between 11 ,15':
        'يجب أن يتراوح طول رقم الهاتف بين 11 و 15 رقماً',

    'validation_length_medium': 'يجب أن يكون الطول بين 10 و 150 حرفاً',

    'Length must be between 10 and 150 characters':
        'يجب أن يكون الطول بين 10 و 150 حرفاً',

    'length is between 10, 150': 'يجب أن يكون الطول بين 10 و 150 حرفاً',

    'validation_length_long': 'يجب أن يكون الطول بين 10 و 500 حرفاً',

    'Length must be between 10 and 500 characters':
        'يجب أن يكون الطول بين 10 و 500 حرفاً',

    'length is between 10, 500': 'يجب أن يكون الطول بين 10 و 500 حرفاً',

    'validation_length_password': 'يجب أن تكون كلمة المرور بين 6 و 20 حرفاً',
    'Reset code sent to your email':
        'تم إرسال رمز إعادة التعيين إلى بريدك الإلكتروني',
    'Code verified': 'تم التحقق من الرمز بنجاح',
    'Invalid reset code': 'رمز إعادة التعيين غير صالح',
    'Reset session expired. Please request a new reset code.':
        'انتهت صلاحية جلسة إعادة التعيين. يرجى طلب رمز جديد.',
    'Failed to reset password': 'فشل إعادة تعيين كلمة المرور',
    'Failed to send reset code': 'فشل إرسال رمز التحقق',
    'Failed to verify reset code': 'فشل التحقق من الرمز',

    'Password must be between 6 and 20 characters':
        'كلمة المرور يجب أن تكون بين 6 و 20 حرفاً أو رقماً',

    'Password is between 6, 20':
        'كلمة المرور يجب أن تكون بين 6 و 20 حرفاً أو رقماً',

    'validation_password_match': 'كلمات المرور غير متطابقة',

    'password don\'t match': 'كلمات المرور غير متطابقة',

    'validation_phone_format': 'رقم هاتف غير صالح',

    'Invalid Phone Number': 'رقم هاتف غير صالح',

    'your cart is empty': 'سلة التسوق فارغة',

    'السلة فارغة': 'سلة التسوق فارغة',

    'cart_cleared': 'تم إفراغ السلة بنجاح',

    'Cart cleared successfully': 'تم إفراغ السلة بنجاح',

    'Cart Cleared Successfully': 'تم إفراغ السلة بنجاح',

    'no_such_product': 'هذا المنتج غير موجود في السلة',

    'There is no such product in cart': 'هذا المنتج غير موجود في السلة',

    'There is no such product': 'هذا المنتج غير موجود في السلة',

    'quantity_positive_integer': 'الكمية يجب أن تكون عدداً صحيحاً موجباً',

    'Quantity must be a positive integer':
        'الكمية يجب أن تكون عدداً صحيحاً موجباً',

    'quantity must be a positive integer':
        'الكمية يجب أن تكون عدداً صحيحاً موجباً',

    'quantity_max_stock': 'الكمية تتجاوز المخزون المتوفر',

    'Quantity exceeds available stock': 'الكمية تتجاوز المخزون المتوفر',

    'wishlist_empty': 'قائمة الرغبات فارغة',

    'review_already_exists': 'لقد قمت بتقييم هذا المنتج من قبل',

    'You have already reviewed this product':
        'لقد قمت بتقييم هذا المنتج من قبل',

    'review_not_found': 'التقييم غير موجود',

    'Review not found': 'التقييم غير موجود',

    'invalid_address': 'معرف العنوان غير صالح',

    'Invalid address ID': 'معرف العنوان غير صالح',

    'address_not_found': 'العنوان غير موجود',

    'Address not found': 'العنوان غير موجود',

    'address_deleted': 'تم حذف العنوان بنجاح',

    'Address deleted successfully': 'تم حذف العنوان بنجاح',

    'Address deleted scussefully': 'تم حذف العنوان بنجاح',

    'user_not_found': 'لم يتم العثور على المستخدم أو العناوين',

    'User or addresses not found': 'لم يتم العثور على المستخدم أو العناوين',

    'item_not_found': 'العنصر غير موجود',

    'Item not found': 'العنصر غير موجود',

    'category_not_found': 'القسم غير موجود',

    'Category not found': 'القسم غير موجود',

    'Catgory DoesNot exits': 'القسم غير موجود',

    'category_exists': 'اسم القسم موجود بالفعل',

    'Category name already exists': 'اسم القسم موجود بالفعل',

    'category already exits': 'اسم القسم موجود بالفعل',

    'Category Name already exits': 'اسم القسم موجود بالفعل',

    'subcategory_not_found': 'القسم الفرعي غير موجود',

    'Subcategory not found': 'القسم الفرعي غير موجود',

    'Subcategory doesn\'t exit': 'القسم الفرعي غير موجود',

    'subcategory_exists': 'اسم القسم الفرعي موجود بالفعل',

    'Subcategory name already exists': 'اسم القسم الفرعي موجود بالفعل',

    'subcategory_wrong_category': 'القسم الفرعي لا ينتمي إلى هذا القسم',

    'Subcategory does not belong to this category':
        'القسم الفرعي لا ينتمي إلى هذا القسم',

    'subcategory doesn\'t exit in that category':
        'القسم الفرعي لا ينتمي إلى هذا القسم',

    'invalid_category_id': 'معرف القسم غير صالح',

    'Invalid category ID': 'معرف القسم غير صالح',

    'Invalid category id': 'معرف القسم غير صالح',

    'Wrong category Id': 'معرف القسم غير صالح',

    'wrong category Id': 'معرف القسم غير صالح',

    'discount_remove_hint': 'لإزالة الخصم قم بوضع سعر المنتج فقط',

    'To remove the discount, set the product price only':
        'لإزالة الخصم قم بوضع سعر المنتج فقط',

    'discount_max_half': 'أعلى قيمة للخصم لا يمكن أن تتجاوز نصف سعر المنتج',

    'Maximum discount cannot exceed half of the product price':
        'أعلى قيمة للخصم لا يمكن أن تتجاوز نصف سعر المنتج',

    'discount_min_zero': 'قيمة الخصم يجب أن تكون أكبر من 0',

    'Discount value must be greater than 0': 'قيمة الخصم يجب أن تكون أكبر من 0',

    'Login failed. Please try again.':
        'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.',

    'Signup failed. Please try again.':
        'فشل إنشاء الحساب. يرجى المحاولة مرة أخرى.',

    'Failed to send reset code.': 'فشل إرسال رمز الاستعادة.',

    'Failed to verify reset code.': 'فشل التحقق من رمز الاستعادة.',

    'Failed to reset password.': 'فشل إعادة تعيين كلمة المرور.',

    'Failed to change password.': 'فشل تغيير كلمة المرور.',

    'Please select a shipping address': 'يرجى اختيار عنوان الشحن',

    'Failed to load cart': 'فشل تحميل سلة التسوق',

    'Failed to load categories': 'فشل تحميل الأقسام',

    'Failed to load products': 'فشل تحميل المنتجات',

    'Failed to load wishlist': 'فشل تحميل قائمة الرغبات',

    'Failed to load product details': 'فشل تحميل تفاصيل المنتج',

    'Failed to load product reviews.': 'فشل تحميل تقييمات المنتج.',

    'Failed to load your reviews.': 'فشل تحميل تقييماتك.',

    'Failed to create review.': 'فشل إضافة التقييم.',

    'Failed to update review.': 'فشل تعديل التقييم.',

    'Failed to delete review.': 'فشل حذف التقييم.',

    'Failed to delete profile.': 'فشل حذف الحساب.',

    'No internet connection.': 'لا يوجد اتصال بالإنترنت.',

    'Connection timed out. Please check your internet.':
        'انتهت مهلة الاتصال. يرجى التحقق من اتصالك بالإنترنت.',

    'Something went wrong. Please try again.':
        'حدث خطأ ما. يرجى المحاولة مرة أخرى.',

    'Server error. Please try again later.':
        'خطأ في الخادم. يرجى المحاولة لاحقاً.',

    'Invalid request. Please check your input.':
        'طلب غير صالح. يرجى التحقق من المدخلات.',

    'The requested resource was not found.':
        'لم يتم العثور على العنصر المطلوب.',

    'You don\'t have permission to perform this action.':
        'ليس لديك الإذن للقيام بهذا الإجراء.',

    'Too many requests. Please wait a moment.':
        'طلبات كثيرة جداً. يرجى الانتظار قليلاً.',

    'Start Shopping': 'ابدأ التسوق',

    'Status': 'الحالة',

    'Change Password': 'تغيير كلمة المرور',

    'Password must be at least 6 characters':
        'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل',

    'Passwords do not match': 'كلمات المرور غير متطابقة',

    'not_logged_in': 'لم يتم تسجيل الدخول',

    // ─── App General & Common ───
    'app_name': 'لابيلا',

    'Labella': 'لابيلا',

    'app_tagline': 'سجل الدخول لمواصلة تجربة التسوق الفاخرة',

    'Sign in to continue your luxury experience':
        'سجل الدخول لمواصلة تجربة التسوق الفاخرة',

    'luxury_tagline': 'انضم إلى عالم الجمال والفخامة',
    'Press back again to exit': 'اضغط مرة أخرى للخروج من التطبيق',

    'Join the world of luxury beauty': 'انضم إلى عالم الجمال والفخامة',

    'Discover luxury beauty essentials':
        'اكتشف أساسيات الجمال ومستحضرات العناية الفاخرة',

    'cancel': 'إلغاء',

    'Cancel': 'إلغاء',

    'save': 'حفظ',

    'Save': 'حفظ',

    'confirm': 'تأكيد',

    'Confirm': 'تأكيد',

    'delete': 'حذف',

    'Delete': 'حذف',

    'remove': 'إزالة',

    'Remove': 'إزالة',

    'edit': 'تعديل',

    'Edit': 'تعديل',

    'New': 'جديد',

    'Edit Product': 'تعديل المنتج',

    'Product created successfully!': 'تم إضافة المنتج بنجاح!',
    'Product updated successfully!': 'تم تحديث المنتج بنجاح!',
    'Product deleted successfully!': 'تم حذف المنتج بنجاح!',
    'Category created successfully!': 'تم إضافة التصنيف بنجاح!',
    'Category updated successfully!': 'تم تحديث التصنيف بنجاح!',
    'Category deleted successfully!': 'تم حذف التصنيف بنجاح!',
    'Subcategory created successfully!': 'تم إضافة التصنيف الفرعي بنجاح!',
    'Subcategory updated successfully!': 'تم تحديث التصنيف الفرعي بنجاح!',
    'Subcategory deleted successfully!': 'تم حذف التصنيف الفرعي بنجاح!',
    'User created successfully!': 'تم إضافة المستخدم بنجاح!',
    'User updated successfully!': 'تم تحديث بيانات المستخدم بنجاح!',
    'User deleted successfully!': 'تم حذف المستخدم بنجاح!',
    'Failed to create category': 'فشل إضافة التصنيف',
    'Failed to update category': 'فشل تحديث التصنيف',
    'Failed to delete category': 'فشل حذف التصنيف',
    'Failed to create subcategory': 'فشل إضافة التصنيف الفرعي',
    'Failed to update subcategory': 'فشل تحديث التصنيف الفرعي',
    'Failed to delete subcategory': 'فشل حذف التصنيف الفرعي',
    'Failed to create product': 'فشل إضافة المنتج',
    'Failed to update product': 'فشل تحديث المنتج',
    'Failed to delete product': 'فشل حذف المنتج',
    'Failed to create user': 'فشل إضافة المستخدم',
    'Failed to update user': 'فشل تحديث المستخدم',
    'Failed to delete user': 'فشل حذف المستخدم',

    'done': 'تم',

    'Done': 'تم',

    'close': 'إغلاق',

    'Close': 'إغلاق',

    'back': 'رجوع',

    'Back': 'رجوع',

    'search': 'بحث',

    'Search': 'بحث',

    'search_products': 'ابحث عن مستحضرات التجميل، العناية بالبشرة...',

    'Search products...': 'ابحث عن المنتجات...',

    'Try a different search term': 'جرب كلمة بحث أخرى أو تصفح التصنيفات',

    'loading': 'جاري التحميل...',

    'Loading...': 'جاري التحميل...',

    'error': 'خطأ',

    'Error': 'خطأ',

    'success': 'نجاح',

    'Success': 'نجاح',

    'retry': 'إعادة المحاولة',

    'Retry': 'إعادة المحاولة',

    'warning': 'تنبيه',

    'Warning': 'تنبيه',

    'show_more': 'عرض المزيد',

    'Show more': 'عرض المزيد',

    'show_less': 'عرض أقل',

    'Show less': 'عرض أقل',

    // ─── Navigation ───
    'nav_home': 'الرئيسية',

    'Home': 'الرئيسية',

    'nav_store': 'المتجر',

    'Store': 'المتجر',

    'Shop': 'المتجر',

    'Shop Now': 'تسوق الآن',

    'nav_cart': 'السلة',

    'Cart': 'السلة',

    'nav_wishlist': 'المفضلة',

    'Wishlist': 'المفضلة',

    'nav_profile': 'حسابي',

    'Profile': 'حسابي',

    // ─── Authentication ───
    'welcome_back': 'مرحباً بعودتك',

    'Welcome back': 'مرحباً بعودتك',

    'sign_in': 'تسجيل الدخول',

    'Sign In': 'تسجيل الدخول',

    'sign_up': 'إنشاء حساب جديد',

    'Sign Up': 'إنشاء حساب',

    'create_account': 'إنشاء حساب',

    'Create Account': 'إنشاء حساب',

    'dont_have_account': 'ليس لديك حساب؟',

    "Don't have an account?": 'ليس لديك حساب؟',

    'already_have_account': 'لديك حساب بالفعل؟',

    'Already have an account?': 'لديك حساب بالفعل؟',

    'email': 'البريد الإلكتروني',

    'Email': 'البريد الإلكتروني',

    'Email Address': 'البريد الإلكتروني',

    'email_hint': 'أدخل بريدك الإلكتروني',

    'password': 'كلمة المرور',

    'Password': 'كلمة المرور',

    'password_hint': 'أدخل كلمة المرور',

    'confirm_password': 'تأكيد كلمة المرور',

    'Confirm Password': 'تأكيد كلمة المرور',

    'confirm_password_hint': 'أعد إدخال كلمة المرور',

    'full_name': 'الاسم الكامل',

    'Full Name': 'الاسم الكامل',

    'full_name_hint': 'أدخل اسمك الكامل',

    'username': 'اسم المستخدم',

    'Username': 'اسم المستخدم',

    'username_hint': 'أدخل اسم المستخدم',

    'phone_number': 'رقم الهاتف',

    'Phone Number': 'رقم الهاتف',

    'Phone': 'الهاتف',

    'phone_number_hint': 'أدخل رقم هاتفك',

    'e.g. 01012345678': 'مثال: 01012345678',

    'forgot_password': 'نسيت كلمة المرور؟',

    'Forgot Password?': 'نسيت كلمة المرور؟',

    'forgot_password_title': 'استعادة كلمة المرور',

    'forgot_password_subtitle': 'أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق.',

    'Enter your email to receive a reset code':
        'أدخل بريدك الإلكتروني لاستلام رمز إعادة التعيين',

    'send_code': 'إرسال الرمز',

    'Send Code': 'إرسال الرمز',

    'verify_code': 'تأكيد الرمز',

    'Verify Code': 'تأكيد الرمز',

    'verify_code_subtitle': 'أدخل الرمز المكون من 6 أرقام المرسل إلى بريدك',

    'We have sent a verification code to your email':
        'لقد أرسلنا رمز التحقق إلى بريدك الإلكتروني',

    'Reset Code': 'رمز التحقق',

    'Code verified successfully!': 'تم التحقق من الرمز بنجاح!',

    'enter_new_password': 'أدخل كلمة المرور الجديدة',

    'Enter your new password below': 'أدخل كلمة المرور الجديدة بالأسفل',

    'new_password': 'كلمة المرور الجديدة',

    'New Password': 'كلمة المرور الجديدة',

    'Set New Password': 'تعيين كلمة المرور الجديدة',

    'reset_password': 'إعادة تعيين كلمة المرور',

    'Reset Password': 'إعادة تعيين كلمة المرور',

    'password_reset_success':
        'تمت إعادة تعيين كلمة المرور بنجاح! يرجى تسجيل الدخول.',

    'Password reset successfully! Please log in.':
        'تمت إعادة تعيين كلمة المرور بنجاح! يرجى تسجيل الدخول.',

    'account_created': 'تم إنشاء الحساب بنجاح! يرجى تسجيل الدخول.',

    'Account created! Please log in.':
        'تم إنشاء الحساب بنجاح! يرجى تسجيل الدخول.',

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

    // ─── Store & Home & Products ───
    'all_products': 'جميع المنتجات',

    'All Products': 'جميع المنتجات',

    'All': 'الكل',

    'categories': 'التصنيفات',

    'Categories': 'التصنيفات',

    'featured': 'المميزة',

    'New Collection': 'تشكيلة جديدة',

    'Trending Now': 'الأكثر رواجاً',

    'new_arrivals': 'وصل حديثاً',

    'best_sellers': 'الأكثر مبيعاً',

    'sale': 'تخفيض',

    'SALE': 'تخفيض',

    'in_stock': 'متوفر',

    'In Stock': 'متوفر',

    'out_of_stock': 'غير متوفر',

    'Out of Stock': 'غير متوفر',

    'add_to_cart': 'إضافة إلى السلة',

    'Add to Cart': 'إضافة إلى السلة',

    'added_to_cart': 'تمت الإضافة إلى السلة!',

    'Added to cart!': 'تمت الإضافة إلى السلة!',

    'Added to cart ✨': 'تمت الإضافة إلى السلة ✨',

    'view_cart': 'عرض السلة',

    'rating': 'التقييم',

    'reviews': 'التقييمات',

    'Reviews': 'التقييمات',

    'Customer Reviews': 'تقييمات العملاء',

    'no_reviews': 'لا توجد تقييمات بعد',

    'No reviews yet': 'لا توجد تقييمات بعد',

    'No reviews yet. Be the first to review!':
        'لا توجد تقييمات بعد. كن أول من يقيّم هذا المنتج!',

    'write_review': 'أضف تقييماً',

    'Write a Review': 'كتابة تقييم',

    'Add Review': 'إضافة تقييم',

    'Delete Review': 'حذف التقييم',

    'Are you sure you want to delete this review?':
        'هل أنت متأكد من رغبتك في حذف هذا التقييم؟',

    'Could not load reviews': 'تعذر تحميل التقييمات',

    'your_review': 'تقييمك',

    'Share your experience with this product...':
        'شاركنا تجربتك ورأيك الصادق حول هذا المنتج...',

    'submit_review': 'إرسال التقييم',

    'review_submitted': 'تم إرسال التقييم بنجاح!',

    'description': 'الوصف',

    'Description': 'الوصف',

    'price': 'السعر',

    'Price': 'السعر',

    'quantity': 'الكمية',

    'Quantity': 'الكمية',

    'product_details': 'تفاصيل المنتج',

    'no_products_found': 'لم يتم العثور على منتجات',

    'No products found': 'لم يتم العثور على أي منتجات',

    'pinch_to_zoom': 'قرّب بالإصبعين أو اضغط مرتين للتكبير',

    // ─── Cart & Checkout ───
    'your_cart': 'سلة المشتريات',

    'My Cart': 'سلة المشتريات',

    'cart_empty': 'سلتك فارغة',

    'Your cart is empty': 'سلتك فارغة حالياً',

    'cart_empty_subtitle': 'استكشف تشكيلتنا الفاخرة وأضف منتجاتك المفضلة',

    'Add some items to get started': 'أضف بعض المنتجات للبدء في التسوق',

    'Clear All': 'تفريغ الكل',

    'Clear Cart?': 'تفريغ السلة؟',

    'Are you sure you want to remove all items?':
        'هل أنت متأكد من رغبتك في تفريغ وحذف جميع منتجات السلة؟',

    'start_shopping': 'ابدأ التسوق',

    'subtotal': 'المجموع الفرعي',

    'Subtotal': 'المجموع الفرعي',

    'delivery_fee': 'قيمة التوصيل',

    'Contact Us': 'تواصل معنا',

    'Contact on WhatsApp': 'تواصل عبر واتساب',

    'Contact Us on WhatsApp': 'تواصل معنا عبر واتساب',

    'Governorate': 'المحافظة',

    'Free Delivery': 'توصيل مجاني',

    'Calculated at checkout': 'يُحسب عند إتمام الطلب',

    'Shipping Policy Note':
        'التوصيل لمحافظة الشرقية مجاناً • باقي المحافظات 100 ج.م',

    'Shipping & Tax': 'الشحن والضريبة',

    'total': 'الإجمالي',

    'Total': 'الإجمالي',

    'checkout': 'إتمام الطلب',

    'Checkout': 'إتمام الطلب',

    'place_order': 'تأكيد الطلب',

    'order_summary': 'ملخص الطلب',

    'Order Summary': 'ملخص الطلب',

    'shipping_address': 'عنوان الشحن',

    'Shipping Address': 'عنوان الشحن',

    'payment_method': 'طريقة الدفع',

    'cash_on_delivery': 'الدفع عند الاستلام',

    'order_placed_success': 'تم تأكيد طلبك بنجاح!',

    'thank_you_order': 'شكراً لطلبك من لابيلا.',

    'Order Confirmed!': 'تم تأكيد طلبك بنجاح!',

    'Continue Shopping': 'متابعة التسوق',

    'Thank you for your purchase.\nYour order is being processed.':
        'شكراً لتسوقك من لابيلا.\nطلبك قيد التجهيز الآن.',

    'address': 'العنوان',

    'Street': 'الشارع',

    'Street Address': 'العنوان بالتفصيل / الشارع',

    'City': 'المدينة',

    'State': 'المحافظة / الولاية',

    'Zip Code': 'الرمز البريدي',

    'ZIP Code': 'الرمز البريدي',

    'phone': 'الهاتف',

    'postal_code': 'الرمز البريدي',

    'Add Address': 'إضافة عنوان',

    'Add New': 'إضافة جديد',

    'Add New Address': 'إضافة عنوان جديد',

    'Add First Address': 'إضافة العنوان الأول',

    'Save Address': 'حفظ العنوان',

    'Delete Address': 'حذف العنوان',

    'Are you sure you want to remove this address?':
        'هل أنت متأكد من رغبتك في حذف هذا العنوان؟',

    'My Addresses': 'عناويني المحفوظة',

    'No addresses saved yet': 'لا توجد عناوين محفوظة بعد',

    'No addresses saved': 'لا توجد عناوين محفوظة',

    'select_address': 'اختر عنوان الشحن',

    'remove_from_cart': 'إزالة من السلة',

    'item_removed': 'تمت إزالة المنتج من السلة',

    'clear_cart': 'تفريغ السلة',

    'items_count': 'منتجات',

    'items': 'منتجات',

    'Items': 'المنتجات',

    'Reached maximum stock': 'وصلت للحد الأقصى للكمية المتاحة في المخزن',

    // ─── Wishlist ───
    'your_wishlist': 'قائمة أمنياتك',

    'Your wishlist is empty': 'قائمة أمنياتك فارغة',

    'wishlist_empty_subtitle': 'احفظ منتجاتك المفضلة لتعود إليها في أي وقت',

    'Save items you love to your wishlist and they will appear here.':
        'احفظ المنتجات التي تعجبك وستظهر لك هنا دائماً.',

    'Explore Products': 'استكشف المنتجات',

    'added_to_wishlist': 'تمت الإضافة إلى المفضلة',

    'removed_from_wishlist': 'تمت الإزالة من المفضلة',

    // ─── Profile & Orders ───
    'my_profile': 'الملف الشخصي',

    'edit_profile': 'تعديل الملف الشخصي',

    'personal_information': 'المعلومات الشخصية',

    'orders': 'الطلبات',

    'my_orders': 'طلباتي',

    'Order History': 'سجل الطلبات',

    'Order Details': 'تفاصيل الطلب',

    'No orders yet': 'لا توجد طلبات سابقة بعد',

    'no_orders': 'لا توجد طلبات سابقة',

    'order_id': 'رقم الطلب',

    'Order ID': 'رقم الطلب',

    'order_date': 'التاريخ',

    'order_status': 'الحالة',

    'Customer': 'العميل',

    'Mark as Delivered': 'تحديد كمُستلم',

    'Mark as Paid': 'تحديد كمدفوع',

    'Mark Deposit as Paid': 'تأكيد دفع العربون',

    'Deposit Paid': 'تم دفع العربون',

    'Deposit Pending': 'العربون قيد الانتظار',

    'Deposit': 'العربون',

    'No address provided': 'لم يتم تحديد عنوان',

    'dark_mode': 'الوضع الداكن',

    'language': 'اللغة',

    'current_language': 'العربية',

    'change_language': 'تغيير اللغة',

    'arabic': 'العربية',

    'english': 'English',

    'change_password': 'تغيير كلمة المرور',

    'current_password': 'كلمة المرور الحالية',

    'Current Password': 'كلمة المرور الحالية',

    'Confirm New Password': 'تأكيد كلمة المرور الجديدة',

    'Password changed successfully! Please login again.':
        'تم تغيير كلمة المرور بنجاح! يرجى تسجيل الدخول مجدداً.',

    'Enter name': 'أدخل الاسم',

    'Not logged in': 'لم يتم تسجيل الدخول',

    'logout': 'تسجيل الخروج',

    'Log Out': 'تسجيل الخروج',

    'logout_confirm_title': 'تسجيل الخروج',

    'logout_confirm_message': 'هل أنت متأكد من رغبتك في تسجيل الخروج؟',

    'delete_account': 'حذف الحساب',

    'Delete Account': 'حذف الحساب',

    'delete_account_confirm':
        'هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.',

    'Profile deleted successfully': 'تم حذف الحساب بنجاح',

    // ─── Admin Panel ───

    // ─── Admin Panel ───
    'admin_dashboard': 'لوحة تحكم المشرف',

    'Admin Panel': 'لوحة الإدارة',

    'Confirm Delete': 'تأكيد الحذف',

    'Are you sure you want to delete this item?':
        'هل أنت متأكد من رغبتك في حذف هذا العنصر نهائياً؟',

    'No orders found': 'لم يتم العثور على أي طلبات',

    'No users found': 'لم يتم العثور على مستخدمين',

    'manage_products': 'إدارة المنتجات',

    'manage_categories': 'إدارة التصنيفات',

    'manage_orders': 'إدارة الطلبات',

    'manage_users': 'إدارة المستخدمين',

    'Product Name': 'اسم المنتج',

    'Cover Image': 'الصورة الرئيسية',

    'Additional Images': 'صور إضافية للمنتج',

    'Add More': 'إضافة المزيد',

    'Pick multiple images': 'اختر عدة صور',

    'Size': 'الحجم',
    'Size (e.g. S, M, L, XL, Standard)': 'المقاس (مثال: S, M, L, XL)',

    'Category': 'التصنيف',

    'Category Name': 'اسم التصنيف',

    'Subcategory': 'التصنيف الفرعي',

    'Subcategory Name': 'اسم التصنيف الفرعي',

    'Subcategory Image': 'صورة التصنيف الفرعي',

    'Parent Category': 'التصنيف الرئيسي',

    'Please select a parent category': 'يرجى اختيار التصنيف الرئيسي أولاً',

    'Role': 'الدور والصلاحية',

    'User': 'مستخدم عادي',

    'Admin': 'مشرف نظام',

    'Confirm Order': 'تأكيد الطلب',

    'Required': 'حقل مطلوب',

    'View Order Details': 'عرض تفاصيل الطلب',

    'Tax & Shipping': 'الضريبة والشحن',

    'PAID': 'مدفوع',

    'UNPAID': 'غير مدفوع',

    'DELIVERED': 'تم التوصيل',

    'PENDING DELIVERY': 'قيد التوصيل',

    'Pending': 'قيد الانتظار',

    'Paid': 'تم الدفع',

    'Unpaid': 'غير مدفوع',

    'Delivered': 'تم التوصيل',

    'Try Again': 'حاول مجدداً',

    'Reviews will appear here when customers share feedback.':
        'ستظهر التقييمات هنا عندما يشارك العملاء آراءهم.',

    'Be the first to share your experience.':
        'كن أول من يشارك تجربته مع هذا المنتج.',

    'review': 'تقييم',

    'Delete review': 'حذف التقييم',

    'Please enter a review': 'يرجى كتابة نص التقييم',

    'Submit': 'إرسال',

    'Operation successful': 'تمت العملية بنجاح',

    'Error occurred': 'حدث خطأ أثناء تنفيذ العملية',

    'Products': 'المنتجات',

    'Orders': 'الطلبات',

    'Users': 'المستخدمين',

    'Subcategories': 'التصنيفات الفرعية',

    'Create Product': 'إضافة منتج جديد',

    'Tap to choose cover': 'اضغط لاختيار صورة الغلاف',

    'Update Product': 'تعديل المنتج',

    'Create Category': 'إضافة تصنيف جديد',

    'Update Category': 'تعديل التصنيف',

    'Create Subcategory': 'إضافة تصنيف فرعي',

    'Update Subcategory': 'تعديل التصنيف الفرعي',

    'Create User': 'إضافة مستخدم جديد',

    'Update User': 'تعديل المستخدم',

    'Category (Optional)': 'التصنيف (اختياري)',

    'Subcategory (Optional)': 'التصنيف الفرعي (اختياري)',

    'None (Optional)': 'بدون (اختياري)',

    'None': 'بدون',

    'Create': 'إنشاء',

    'Update': 'تحديث',

    'Size is required': 'يرجى تحديد المقاس',

    'Name is required': 'الاسم مطلوب',

    'Parent category is required': 'التصنيف الرئيسي مطلوب',

    'Phone is required': 'رقم الهاتف مطلوب',

    'Must be 11-15 digits': 'يجب أن يكون رقم الهاتف بين 11 و 15 رقماً',

    'Invalid email': 'بريد إلكتروني غير صالح',

    'Min 6 characters': 'كلمة المرور يجب أن لا تقل عن 6 أحرف',

    'Please enter current password': 'يرجى إدخال كلمة المرور الحالية',

    'Please enter new password': 'يرجى إدخال كلمة المرور الجديدة',

    'By': 'بواسطة',
    'Discount (%)': 'خصم (%)',
    'Price after discount': 'السعر بعد الخصم',
    '0-99': '0-99',
    'Must be 0-99': 'يجب أن يكون بين 0 و 99',
    'You save': 'وفرت',
    'Exclusive Collection': 'تشكيلة حصرية',
    'Special Offers': 'عروض خاصة 🌟',
    'Up to 50% Off': 'خصومات تصل 50%',
    'On luxury skincare and premium fragrances':
        'على أرقى مستحضرات العناية بالبشرة والعطور',
    'Radiant Beauty': 'إشراقة لا مثيل لها',
    'Selected from world-class luxury beauty brands':
        'مختارة بعناية من أفخم العلامات العالمية',

    // ─── Guest Browsing & Auth Protection ───
    'Sign in required': 'تسجيل الدخول مطلوب',
    'Please sign in to add products to your wishlist.':
        'يجب عليك تسجيل الدخول لإضافة المنتجات إلى المفضلة.',
    'Please sign in to add products to your cart.':
        'يجب عليك تسجيل الدخول لإضافة المنتجات إلى السلة.',
    'Please sign in to complete your purchase.':
        'يجب عليك تسجيل الدخول لإتمام عملية الشراء.',
    'Please sign in to access your personal account.':
        'يجب عليك تسجيل الدخول للوصول إلى حسابك الشخصي.',
    'Not Now': 'ليس الآن',
    'Welcome to Labella': 'أهلاً بك في Labella',
    'Sign in or create an account to enjoy your complete shopping experience.':
        'سجّل الدخول أو أنشئ حسابك للاستمتاع بتجربة تسوق متكاملة.',
    'Member Benefits': 'مميزات الحساب',
    'Order Tracking': 'تتبع الطلبات',
    'Track your orders and follow their delivery status.':
        'تتبع طلباتك ومتابعة حالة التوصيل أولاً بأول.',
    'Save your favorite products and access them anytime.':
        'احفظ منتجاتك المفضلة للوصول إليها في أي وقت.',
    'Faster Checkout': 'شراء أسرع',
    'Save your delivery information for a smoother shopping experience.':
        'احفظ معلومات التوصيل لتجربة تسوق أسرع وأسهل.',
    'Personal Account': 'حساب مخصص',
    'Manage your profile and view your shopping history.':
        'إدارة ملفك الشخصي ومتابعة سجل مشترياتك بسهولة.',
    'Your cart is waiting': 'سلتك في انتظارك',
    'Please sign in to view your cart and start shopping.':
        'سجل دخولك لعرض سلتك وإتمام مشترياتك.',
    'Your wishlist is waiting': 'قائمة أمنياتك في انتظارك',
    'Please sign in to view and save your favorite items.':
        'سجل دخولك لحفظ منتجاتك المفضلة والرجوع إليها في أي وقت.',
    'Explore Store': 'تصفح المتجر',
    'Guest': 'زائر',
    'Guest Account': 'حساب زائر',
    'guest': 'زائر',
  };

  /// Translate key or English phrase according to current locale

  static String translate(String key, String languageCode) {
    final dict = languageCode == 'ar' ? ar : en;

    if (dict.containsKey(key)) {
      return dict[key]!;
    }

    // Case-insensitive / trimmed fallback

    final clean = key.trim().toLowerCase();

    for (final entry in dict.entries) {
      if (entry.key.trim().toLowerCase() == clean) {
        return entry.value;
      }
    }

    // Punctuation-stripped fallback (e.g. trailing periods or exclamation marks)

    final stripped = clean.replaceAll(RegExp(r'[\.\!\:\,\-]+$'), '').trim();

    for (final entry in dict.entries) {
      final entryStripped = entry.key
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[\.\!\:\,\-]+$'), '')
          .trim();

      if (entryStripped == stripped) {
        return entry.value;
      }
    }

    // Check other dict if not found

    final fallbackDict = languageCode == 'ar' ? en : ar;

    if (fallbackDict.containsKey(key)) {
      return fallbackDict[key]!;
    }

    return key;
  }
}

/// Extension on String for translating keys: `'sign_in'.tr(context)` or `'Welcome back'.tr(context)`

extension StringTranslationExtension on String {
  String tr(BuildContext context) {
    String? lang;
    try {
      lang = context.read<LocaleCubit>().state.locale.languageCode;
    } catch (_) {
      try {
        lang = context.watch<LocaleCubit>().state.locale.languageCode;
      } catch (_) {
        lang = LocaleCubit.currentLanguage;
      }
    }
    return AppTranslations.translate(this, lang);
  }

  /// Read without watch (e.g. in callbacks / initState / SnackBar)
  String trOnce(BuildContext context) {
    String? lang;
    try {
      lang = context.read<LocaleCubit>().state.locale.languageCode;
    } catch (_) {
      lang = LocaleCubit.currentLanguage;
    }
    return AppTranslations.translate(this, lang);
  }
}

/// Extension on BuildContext: `context.tr('sign_in')`
extension ContextTranslationExtension on BuildContext {
  String tr(String key) {
    String? lang;
    try {
      lang = read<LocaleCubit>().state.locale.languageCode;
    } catch (_) {
      try {
        lang = watch<LocaleCubit>().state.locale.languageCode;
      } catch (_) {
        lang = LocaleCubit.currentLanguage;
      }
    }
    return AppTranslations.translate(key, lang);
  }

  bool get isArabic {
    try {
      return read<LocaleCubit>().isArabic;
    } catch (_) {
      try {
        return watch<LocaleCubit>().isArabic;
      } catch (_) {
        return LocaleCubit.currentLanguage == 'ar';
      }
    }
  }
}
