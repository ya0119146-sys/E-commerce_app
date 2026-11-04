import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/core/network/dio_client.dart';
import 'package:e_commerce/features/checkout/data/repos/checkout_repository.dart';
import 'package:e_commerce/features/checkout/logic/checkout_cubit.dart';
import 'package:e_commerce/features/checkout/data/models/order_model.dart';
import 'package:e_commerce/features/checkout/data/models/address_model.dart';
import 'package:e_commerce/features/checkout/ui/order_detail_screen.dart';

void main() {
  const viewports = [
    Size(320, 568), // iPhone SE / Compact
    Size(360, 800), // Standard Android
    Size(412, 915), // High-res flagship Android
    Size(600, 960), // Tablet
  ];

  final sampleOrderWithDeposit = OrderModel(
    id: 'ord_987654321098',
    totalPrice: 1250.0,
    itemsPrice: 1150.0,
    taxPrice: 100.0,
    status: 'pending',
    isPaid: false,
    isDelivered: false,
    isDepositePaid: true,
    depositeAmount: 575.0,
    paymentMethod: 'cash',
    createdAt: DateTime(2026, 11, 3, 14, 30),
    userName: 'سارة أحمد محمد مصطفى',
    userImage: null,
    address: const AddressModel(
      id: 'addr_1',
      street: '15 شارع قصر النيل، وسط البلد، الدور الخامس، شقة 12',
      city: 'القاهرة',
      state: 'محافظة القاهرة',
      zip: '11511',
    ),
    items: const [
      OrderItemModel(
        productId: 'prod_1',
        title:
            'عطر الورد الدمشقي الفاخر الطبيعي 100 مل - إصدار محدود خاص لعام 2026',
        image: 'https://example.com/perfume.jpg',
        quantity: 2,
        price: 575.0,
      ),
    ],
  );

  Widget createTestWidget({
    required Widget child,
    Locale locale = const Locale('en'),
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return BlocProvider<CheckoutCubit>(
      create: (_) => CheckoutCubit(CheckoutRepository(DioClient())),
      child: MaterialApp(
        locale: locale,
        home: Directionality(
          textDirection: textDirection,
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  for (final size in viewports) {
    testWidgets(
      'OrderDetailScreen renders without overflow on ${size.width}x${size.height}',
      (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(
            child: OrderDetailScreen(
              order: sampleOrderWithDeposit,
              isAdmin: true,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(OrderDetailScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'OrderDetailScreen renders in Arabic RTL on ${size.width}x${size.height}',
      (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestWidget(
            locale: const Locale('ar'),
            textDirection: TextDirection.rtl,
            child: OrderDetailScreen(
              order: sampleOrderWithDeposit,
              isAdmin: false,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(OrderDetailScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
