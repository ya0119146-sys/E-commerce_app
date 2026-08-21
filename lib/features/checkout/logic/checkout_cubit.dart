import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/address_model.dart';
import '../data/models/order_model.dart';
import '../data/repos/checkout_repository.dart';
import '../../../core/network/api_exception.dart';

part 'checkout_state.dart';

/// Checkout Cubit — manages addresses, order placement, and order history.
class CheckoutCubit extends Cubit<CheckoutState> {
  final CheckoutRepository _repository;

  CheckoutCubit(this._repository) : super(const CheckoutState());

  /// Set addresses from user model.
  void getAddressesFromUser(List<AddressModel> addresses) {
    emit(
      state.copyWith(
        status: CheckoutStatus.loaded,
        addresses: addresses,
        selectedAddressId: addresses.isNotEmpty
            ? (state.selectedAddressId ?? addresses.first.id)
            : null,
      ),
    );
  }

  /// Add a new address.
  Future<void> addAddress(
    String street,
    String city,
    String stateName,
    String zip,
  ) async {
    emit(state.copyWith(status: CheckoutStatus.loading));
    try {
      await _repository.addAddress(street, city, stateName, zip);
      await fetchAddresses(); // Refresh list
    } on ApiException catch (e) {
      emit(
        state.copyWith(status: CheckoutStatus.error, errorMessage: e.message),
      );
    }
  }

  /// Remove an address.
  Future<void> removeAddress(String id) async {
    emit(state.copyWith(status: CheckoutStatus.loading));
    try {
      await _repository.removeAddress(id);
      await fetchAddresses(); // Refresh list
    } on ApiException catch (e) {
      emit(
        state.copyWith(status: CheckoutStatus.error, errorMessage: e.message),
      );
    }
  }

  /// Fetch all saved addresses.
  Future<void> fetchAddresses() async {
    emit(state.copyWith(status: CheckoutStatus.loading));
    try {
      final addresses = await _repository.getAddresses();
      emit(
        state.copyWith(
          status: CheckoutStatus.loaded,
          addresses: addresses,
          selectedAddressId: addresses.isNotEmpty
              ? (state.selectedAddressId ?? addresses.first.id)
              : null,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(status: CheckoutStatus.error, errorMessage: e.message),
      );
    }
  }

  /// Select an address.
  void selectAddress(String addressId) {
    emit(state.copyWith(selectedAddressId: addressId));
  }

  /// Place order.
  Future<void> placeOrder() async {
    if (state.selectedAddressId == null) {
      emit(
        state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: 'Please select a shipping address',
        ),
      );
      return;
    }

    emit(state.copyWith(status: CheckoutStatus.placingOrder));
    try {
      final selectedAddress = state.addresses.firstWhere(
        (a) => a.id == state.selectedAddressId,
        orElse: () =>
            throw const ApiException(message: 'Selected address not found'),
      );
      final order = await _repository.placeOrder(
        selectedAddress.street,
        selectedAddress.city,
        selectedAddress.state,
        selectedAddress.zip,
        selectedAddress.id,
      );
      emit(
        state.copyWith(status: CheckoutStatus.orderPlaced, lastOrder: order),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(status: CheckoutStatus.error, errorMessage: e.message),
      );
    }
  }

  /// Fetch order history.
  Future<void> fetchOrderHistory() async {
    emit(state.copyWith(ordersStatus: OrdersStatus.loading));
    try {
      final orders = await _repository.getOrderHistory();
      emit(state.copyWith(ordersStatus: OrdersStatus.loaded, orders: orders));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          ordersStatus: OrdersStatus.error,
          errorMessage: e.message,
        ),
      );
    }
  }

  /// Mark order as delivered.
  Future<void> deliverOrder(String orderId) async {
    try {
      await _repository.deliverOrder(orderId);
      await fetchOrderHistory(); // Refresh
    } on ApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    }
  }

  /// Mark order as paid.
  Future<void> payOrder(String orderId) async {
    try {
      await _repository.payOrder(orderId);
      await fetchOrderHistory(); // Refresh
    } on ApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    }
  }
}
