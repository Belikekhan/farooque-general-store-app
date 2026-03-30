import 'package:equatable/equatable.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/cart_item_model.dart';

abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderModel> orders;
  const OrderLoaded(this.orders);
  @override
  List<Object> get props => [orders];
}

class OrderSuccess extends OrderState {
  final OrderModel order;
  const OrderSuccess(this.order);
  @override
  List<Object> get props => [order];
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
  @override
  List<Object> get props => [message];
}

// Events
abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object> get props => [];
}

class LoadOrders extends OrderEvent {}

class UpdateOrderStatusesEvent extends OrderEvent {}

class PlaceOrderEvent extends OrderEvent {
  final String userId;
  final List<CartItemModel> items;
  final double totalAmount;
  final String paymentMethod;

  const PlaceOrderEvent({
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
  });

  @override
  List<Object> get props => [userId, items, totalAmount, paymentMethod];
}
