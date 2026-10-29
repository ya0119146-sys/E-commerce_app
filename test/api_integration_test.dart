import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce/core/network/api_constants.dart';
import 'package:e_commerce/core/network/api_exception.dart';
import 'package:e_commerce/core/network/dio_client.dart';
import 'package:e_commerce/features/auth/data/models/user_model.dart';
import 'package:e_commerce/features/store/data/models/product_model.dart';
import 'package:e_commerce/features/cart/data/models/cart_model.dart';
import 'package:e_commerce/features/cart/data/repos/cart_repository.dart';
import 'package:e_commerce/features/checkout/data/repos/checkout_repository.dart';
import 'package:e_commerce/features/reviews/data/models/review_model.dart';

void main() {
  group('Backend API Contracts & Error Parsing', () {
    test('Prioritizes server message on 401 rather than generic session expired', () {
      final msg = ApiException.friendlyMessage(401, 'Invalid Email Or Password');
      expect(msg, equals('Invalid Email Or Password'));
    });

    test('Falls back to default message when server message is null or empty', () {
      expect(ApiException.friendlyMessage(401, null), equals('Session expired. Please log in again.'));
      expect(ApiException.friendlyMessage(403, ''), equals('You don\'t have permission to perform this action.'));
      expect(ApiException.friendlyMessage(404, null), equals('The requested resource was not found.'));
    });

    test('Prioritizes server message on 403 and 404', () {
      expect(ApiException.friendlyMessage(403, 'reset code not verified'), equals('reset code not verified'));
      expect(ApiException.friendlyMessage(404, 'Email not found in database'), equals('Email not found in database'));
    });

    test('ApiConstants endpoint paths and prefixes', () {
      expect(ApiConstants.signup, equals('/api/v1/auth/signup'));
      expect(ApiConstants.login, equals('/api/v1/auth/login'));
      expect(ApiConstants.cart, equals('/api/v1/cart'));
      expect(ApiConstants.reviewsMe, equals('/api/v1/reviews/me'));
      expect(ApiConstants.deleteWishlist('123'), equals('/api/v1/wishlist/123'));
    });
  });

  group('Model Deserialization Contracts', () {
    test('UserModel deserializes numeric phone and addresses safely', () {
      final json = {
        '_id': 'user_123',
        'name': 'Test User',
        'username': 'testuser',
        'email': 'test@example.com',
        'role': 'user',
        'phone': 1012345678, // MongoDB returns Number
        'address': [
          {
            '_id': 'addr_1',
            'street': '123 Main St',
            'city': 'Cairo',
            'state': 'Cairo',
            'zip': '12345'
          }
        ]
      };

      final user = UserModel.fromJson(json);
      expect(user.id, equals('user_123'));
      expect(user.name, equals('Test User'));
      expect(user.phone, equals('1012345678'));
      expect(user.addresses?.length, equals(1));
      expect(user.addresses?.first.street, equals('123 Main St'));
    });

    test('ProductModel parses priceAfterDiscount and calculates onSale accurately', () {
      // Case 1: Product with discount
      final discountedJson = {
        '_id': 'prod_1',
        'name': 'Silk Scarf',
        'size': 'Standard',
        'price': 200,
        'priceAfterDiscount': 150,
        'rateAvg': 4.5,
        'rating': 12,
        'quantity': 30,
        'sold': 5,
        'cover': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        'images': ['https://res.cloudinary.com/demo/image/upload/sample.jpg'],
      };

      final discountedProduct = ProductModel.fromJson(discountedJson);
      expect(discountedProduct.id, equals('prod_1'));
      expect(discountedProduct.size, equals('Standard'));
      expect(discountedProduct.price, equals(200.0));
      expect(discountedProduct.salePrice, equals(150.0));
      expect(discountedProduct.onSale, isTrue);
      expect(discountedProduct.displayPrice, equals(150.0));
      expect(discountedProduct.ratingAvg, equals(4.5));
      expect(discountedProduct.ratingCount, equals(12));

      // Case 2: Product with default priceAfterDiscount = 0 (no discount)
      final regularJson = {
        '_id': 'prod_2',
        'name': 'Wool Coat',
        'size': 'L',
        'price': 500,
        'priceAfterDiscount': 0, // Backend default is 0
        'rateAvg': 5,
        'rating': 3,
        'quantity': 10,
        'sold': 0,
      };

      final regularProduct = ProductModel.fromJson(regularJson);
      expect(regularProduct.price, equals(500.0));
      expect(regularProduct.salePrice, isNull);
      expect(regularProduct.onSale, isFalse);
      expect(regularProduct.displayPrice, equals(500.0));
    });

    test('CartModel deserializes backend typos totelPrice and items accurately', () {
      final json = {
        '_id': 'cart_1',
        'items': [
          {
            '_id': 'item_1',
            'product': {
              '_id': 'prod_1',
              'name': 'Dress',
              'price': 100,
              'priceAfterDiscount': 0,
            },
            'quantity': 2,
            'price': 100,
          }
        ],
        'totelPrice': 200, // backend typo
        'taxPrice': 100,
        'totelPriceAfterDiscount': null,
      };

      final cart = CartModel.fromJson(json);
      expect(cart.id, equals('cart_1'));
      expect(cart.items.length, equals(1));
      expect(cart.totalPrice, equals(200.0));
      expect(cart.itemCount, equals(2));
      expect(cart.taxPrice, equals(100.0));
    });

    test('ReviewModel handles product as both Map and MongoId String', () {
      // When product is a MongoId String (e.g. from create response)
      final reviewWithStringProduct = {
        '_id': 'rev_1',
        'comment': 'Love it!',
        'rate': 5.0,
        'user': {'_id': 'u1', 'name': 'Sarah', 'email': 'sarah@example.com'},
        'product': 'prod_abc123',
      };

      final r1 = ReviewModel.fromJson(reviewWithStringProduct);
      expect(r1.id, equals('rev_1'));
      expect(r1.product.id, equals('prod_abc123'));
      expect(r1.toJson()['product'], equals('prod_abc123'));

      // When product is populated
      final reviewWithPopulatedProduct = {
        '_id': 'rev_2',
        'comment': 'Nice',
        'rate': 4.0,
        'user': {'_id': 'u2', 'name': 'Alex'},
        'product': {'_id': 'prod_xyz', 'name': 'Handbag', 'price': 350},
      };

      final r2 = ReviewModel.fromJson(reviewWithPopulatedProduct);
      expect(r2.id, equals('rev_2'));
      expect(r2.product.id, equals('prod_xyz'));
      expect(r2.product.name, equals('Handbag'));
      expect(r2.toJson()['product'], equals('prod_xyz'));
    });
  });

  group('HTTP 404 Tolerant Repositories', () {
    test('CartRepository returns CartModel.empty when backend returns 404', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 404,
                data: {'status': 'failed', 'message': 'السلة فارغة'},
              ),
              type: DioExceptionType.badResponse,
            ),
          );
        },
      ));

      final client = DioClient(customDio: dio);

      final cartRepo = CartRepository(client);
      final cart = await cartRepo.getCart();

      expect(cart, equals(CartModel.empty));
      expect(cart.items, isEmpty);
      expect(cart.totalPrice, equals(0.0));
    });

    test('CheckoutRepository returns empty list when backend returns 404 for address', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 404,
                data: {'status': 'failed', 'message': 'No addresses found'},
              ),
              type: DioExceptionType.badResponse,
            ),
          );
        },
      ));

      final client = DioClient(customDio: dio);

      final checkoutRepo = CheckoutRepository(client);
      final addresses = await checkoutRepo.getAddresses();

      expect(addresses, isEmpty);
    });
  });
}
