import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_state.dart';
import '../../../data/repositories/order_repository.dart';

export 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc({required this.orderRepository}) : super(OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<UpdateOrderStatusesEvent>(_onUpdateStatus);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await orderRepository.getOrders();
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onPlaceOrder(PlaceOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await orderRepository.placeOrder(
        userId: event.userId,
        items: event.items,
        totalAmount: event.totalAmount,
        paymentMethod: event.paymentMethod,
      );
      emit(OrderSuccess(order));
      // Reload orders to show in history
      final orders = await orderRepository.getOrders();
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(UpdateOrderStatusesEvent event, Emitter<OrderState> emit) async {
    try {
      await orderRepository.updateOrderStatuses();
      final orders = await orderRepository.getOrders();
      emit(OrderLoaded(orders));
    } catch (e) {
      // Background update failed silently
    }
  }
}
