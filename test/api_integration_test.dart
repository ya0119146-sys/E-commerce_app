import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce/core/constants/egypt_governorates.dart';
import 'package:e_commerce/core/utils/whatsapp_helper.dart';
import 'package:e_commerce/core/widgets/product_grid_delegate.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/core/network/api_constants.dart';
import 'package:e_commerce/core/network/api_exception.dart';
import 'package:e_commerce/core/network/dio_client.dart';
import 'package:e_commerce/features/auth/data/models/user_model.dart';
import 'package:e_commerce/features/store/data/models/product_model.dart';
import 'package:e_commerce/features/cart/data/models/cart_model.dart';
import 'package:e_commerce/features/cart/data/repos/cart_repository.dart';
import 'package:e_commerce/features/checkout/data/models/order_model.dart';
import 'package:e_commerce/features/checkout/data/repos/checkout_repository.dart';
import 'package:e_commerce/core/localization/app_translations.dart';
import 'package:e_commerce/features/reviews/data/models/review_model.dart';

void main() {
  group('Backend API Contracts & Error Parsing', () {
    test(
      'Prioritizes server message on 401 rather than generic session expired',
      () {
        final msg = ApiException.friendlyMessage(
          401,
          'Invalid Email Or Password',
        );
        expect(msg, equals('Invalid Email Or Password'));
      },
    );

    test(
      'Falls back to default message when server message is null or empty',
      () {
        expect(
          ApiException.friendlyMessage(401, null),
          equals('Session expired. Please log in again.'),
        );
        expect(
          ApiException.friendlyMessage(403, ''),
          equals('You don\'t have permission to perform this action.'),
        );
        expect(
          ApiException.friendlyMessage(404, null),
          equals('The requested resource was not found.'),
        );
      },
    );

    test('Prioritizes server message on 403 and 404', () {
      expect(
        ApiException.friendlyMessage(403, 'reset code not verified'),
        equals('reset code not verified'),
      );
      expect(
        ApiException.friendlyMessage(404, 'Email not found in database'),
        equals('Email not found in database'),
      );
    });

    test('ApiConstants endpoint paths and prefixes', () {
      expect(ApiConstants.signup, equals('/api/v1/auth/signup'));
      expect(ApiConstants.login, equals('/api/v1/auth/login'));
      expect(ApiConstants.cart, equals('/api/v1/cart'));
      expect(ApiConstants.reviewsMe, equals('/api/v1/reviews/me'));
      expect(
        ApiConstants.deleteWishlist('123'),
        equals('/api/v1/wishlist/123'),
      );
      expect(
        ApiConstants.orderDeposite('123'),
        equals('/api/v1/order/123/deposite'),
      );
    });
  });

  test('Translates server validation keys properly', () {
    expect(
      ApiException.friendlyMessage(400, 'validation_email_check'),
      anyOf(
        equals('Email already exists'),
        equals('البريد الإلكتروني موجود بالفعل'),
      ),
    );
    expect(
      ApiException.friendlyMessage(400, 'validation_email_invalid'),
      anyOf(
        equals('Please enter a valid email address'),
        equals('يرجى إدخال بريد إلكتروني صالح'),
      ),
    );
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
            'zip': '12345',
          },
        ],
      };

      final user = UserModel.fromJson(json);
      expect(user.id, equals('user_123'));
      expect(user.name, equals('Test User'));
      expect(user.phone, equals('1012345678'));
      expect(user.addresses?.length, equals(1));
      expect(user.addresses?.first.street, equals('123 Main St'));
    });

    test(
      'ProductModel parses priceAfterDiscount and calculates onSale accurately',
      () {
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

        // Case 3: Product created with discount percentage
        final discountProductJson = {
          '_id': 'prod_3',
          'name': 'Luxury Cream',
          'price': 200,
          'discount': 25,
          'priceAfterDiscount': 150,
        };
        final discountProduct = ProductModel.fromJson(discountProductJson);
        expect(discountProduct.onSale, isTrue);
        expect(discountProduct.displayPrice, equals(150.0));
        expect(discountProduct.discountPercentage, equals(25));
        expect(discountProduct.savingsAmount, equals(50.0));
      },
    );

    test(
      'CartModel deserializes backend typos totelPrice and items accurately',
      () {
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
            },
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
      },
    );

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

    test(
      'OrderModel deserializes deposit fields, user and item details safely',
      () {
        final orderJson = {
          '_id': 'order_123456789012',
          'totalPrice': 500,
          'itemsPrice': 450,
          'taxPrice': 50,
          'isPaid': false,
          'isDelivered': false,
          'isDepositePaid': true,
          'DepositeAmount': 225.0,
          'payment': 'cash',
          'user': {
            '_id': 'user_1',
            'name': 'Fatima',
            'image': 'https://res.cloudinary.com/demo/image/upload/user1.jpg',
          },
          'items': [
            {
              'product': {
                '_id': 'p1',
                'name': 'Perfume Oil',
                'cover': 'https://res.cloudinary.com/demo/image/upload/p1.jpg',
              },
              'quantity': 2,
              'price': 225,
            },
          ],
          'address': {
            '_id': 'addr_1',
            'street': 'Al-Tahrir St',
            'city': 'Cairo',
            'state': 'Cairo',
            'zip': '11511',
          },
        };

        final order = OrderModel.fromJson(orderJson);
        expect(order.id, equals('order_123456789012'));
        expect(order.isDepositePaid, isTrue);
        expect(order.depositeAmount, equals(225.0));
        expect(order.userName, equals('Fatima'));
        expect(order.items.length, equals(1));
        expect(order.items.first.title, equals('Perfume Oil'));
        expect(order.address?.street, equals('Al-Tahrir St'));
      },
    );
  });

  group('HTTP 404 Tolerant Repositories', () {
    test(
      'CartRepository returns CartModel.empty when backend returns 404',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
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
          ),
        );

        final client = DioClient(customDio: dio);

        final cartRepo = CartRepository(client);
        final cart = await cartRepo.getCart();

        expect(cart, equals(CartModel.empty));
        expect(cart.items, isEmpty);
        expect(cart.totalPrice, equals(0.0));
      },
    );

    test(
      'CheckoutRepository returns empty list when backend returns 404 for address',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
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
          ),
        );

        final client = DioClient(customDio: dio);

        final checkoutRepo = CheckoutRepository(client);
        final addresses = await checkoutRepo.getAddresses();

        expect(addresses, isEmpty);
      },
    );
  });

  group('Egyptian Governorates & Shipping Policy', () {
    test('Contains all 27 Egyptian governorates', () {
      expect(EgyptGovernorates.governorates.length, equals(27));
      expect(EgyptGovernorates.governorates, contains('محافظة الشرقية'));
      expect(EgyptGovernorates.governorates, contains('محافظة القاهرة'));
      expect(EgyptGovernorates.governorates, contains('محافظة الإسكندرية'));
    });

    test('Correctly identifies Sharqia and applies free shipping', () {
      expect(EgyptGovernorates.isSharqia('محافظة الشرقية'), isTrue);
      expect(EgyptGovernorates.isSharqia('الشرقية'), isTrue);
      expect(EgyptGovernorates.isSharqia('Sharqia'), isTrue);
      expect(EgyptGovernorates.getShippingFee('محافظة الشرقية'), equals(0.0));
      expect(EgyptGovernorates.getShippingFee('الشرقية'), equals(0.0));
    });

    test('Applies 100 EGP shipping to other governorates', () {
      expect(EgyptGovernorates.isSharqia('محافظة القاهرة'), isFalse);
      expect(EgyptGovernorates.isSharqia('محافظة الجيزة'), isFalse);
      expect(EgyptGovernorates.getShippingFee('محافظة القاهرة'), equals(100.0));
      expect(
        EgyptGovernorates.getShippingFee('محافظة الإسكندرية'),
        equals(100.0),
      );
      expect(EgyptGovernorates.getShippingFee(null), equals(100.0));
    });
  });

  group('WhatsApp Integration', () {
    test('Merchant phone format is correct', () {
      expect(WhatsAppHelper.merchantPhone, equals('201093727578'));
      expect(WhatsAppHelper.displayPhone, equals('01093727578'));
    });
  });

  group('ProductGridDelegate Responsive Layout', () {
    testWidgets('Calculates 3 columns for tablet/desktop viewports', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final delegate = ProductGridDelegate.create(context);
              expect(
                delegate,
                isA<SliverGridDelegateWithFixedCrossAxisCount>(),
              );
              final fixed =
                  delegate as SliverGridDelegateWithFixedCrossAxisCount;
              expect(fixed.crossAxisCount, equals(3));
              expect(fixed.childAspectRatio, greaterThan(0.4));
              expect(fixed.childAspectRatio, lessThan(0.7));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Calculates 2 columns for standard mobile viewports', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final delegate = ProductGridDelegate.create(context);
              final fixed =
                  delegate as SliverGridDelegateWithFixedCrossAxisCount;
              expect(fixed.crossAxisCount, equals(2));
              expect(fixed.childAspectRatio, greaterThanOrEqualTo(0.45));
              expect(fixed.childAspectRatio, lessThanOrEqualTo(0.65));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Calculates 1 column for ultra-compact mini-windows', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(240 * 2, 400 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final delegate = ProductGridDelegate.create(context);
              final fixed =
                  delegate as SliverGridDelegateWithFixedCrossAxisCount;
              expect(fixed.crossAxisCount, equals(1));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('Double-tap Exit Localization & Shell Routing', () {
    test('Translation map contains double-tap exit prompt in AR and EN', () {
      expect(
        AppTranslations.en['Press back again to exit'],
        equals('Press back again to exit'),
      );
      expect(
        AppTranslations.ar['Press back again to exit'],
        equals('اضغط مرة أخرى للخروج من التطبيق'),
      );
    });
  });
}
