import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'cart_item_model.dart';

part 'order_model.g.dart';

@HiveType(typeId: 3)
class OrderModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final List<CartItemModel> items;

  @HiveField(3)
  final double totalAmount;

  @HiveField(4)
  final String paymentMethod;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final DateTime orderedAt;

  @HiveField(7)
  final DateTime? estimatedDelivery;

  @HiveField(8)
  final bool isCurrent;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.orderedAt,
    this.estimatedDelivery,
    required this.isCurrent,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        totalAmount,
        paymentMethod,
        status,
        orderedAt,
        estimatedDelivery,
        isCurrent,
      ];
      
  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    double? totalAmount,
    String? paymentMethod,
    String? status,
    DateTime? orderedAt,
    DateTime? estimatedDelivery,
    bool? isCurrent,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      orderedAt: orderedAt ?? this.orderedAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}
