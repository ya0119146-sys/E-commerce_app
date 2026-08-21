part of 'checkout_cubit.dart';

enum CheckoutStatus {
  initial,
  loading,
  loaded,
  placingOrder,
  orderPlaced,
  error,
}

enum OrdersStatus { initial, loading, loaded, error }

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final String? selectedAddressId;
  final OrderModel? lastOrder;
  final OrdersStatus ordersStatus;
  final List<OrderModel> orders;
  final List<AddressModel> addresses;
  final String? errorMessage;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.selectedAddressId,
    this.lastOrder,
    this.ordersStatus = OrdersStatus.initial,
    this.orders = const [],
    this.addresses = const [],
    this.errorMessage,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    String? selectedAddressId,
    OrderModel? lastOrder,
    OrdersStatus? ordersStatus,
    List<OrderModel>? orders,
    List<AddressModel>? addresses,
    String? errorMessage,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      lastOrder: lastOrder ?? this.lastOrder,
      ordersStatus: ordersStatus ?? this.ordersStatus,
      orders: orders ?? this.orders,
      addresses: addresses ?? this.addresses,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,

    selectedAddressId,
    lastOrder?.id,
    ordersStatus,
    orders.length,
    addresses.length,
  ];
}
