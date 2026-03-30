import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../sources/local/hive_service.dart';

class OrderRepository {
  final HiveService _hiveService;
  final Uuid _uuid = const Uuid();

  OrderRepository(this._hiveService);

  Future<List<OrderModel>> getOrders() async {
    final box = _hiveService.orderBox;
    return box.values.toList().reversed.toList(); // most recent first
  }

  Future<OrderModel> placeOrder({
    required String userId,
    required List<CartItemModel> items,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    final box = _hiveService.orderBox;
    
    // Copy items to unlinked objects so clearing cart doesn't delete them from order
    final savedItems = items.map((i) => i.copyWith()).toList();
    
    final newOrder = OrderModel(
      id: 'FK${_uuid.v4().substring(0, 5).toUpperCase()}',
      userId: userId,
      items: savedItems,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      status: 'confirmed',
      orderedAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(minutes: 45)),
      isCurrent: true,
    );

    await box.add(newOrder);
    return newOrder;
  }

  Future<void> updateOrderStatuses() async {
    // Demo: auto-progress orders based on time
    final box = _hiveService.orderBox;
    for (int i = 0; i < box.length; i++) {
        final order = box.getAt(i);
        if (order != null && order.isCurrent) {
            final diff = DateTime.now().difference(order.orderedAt);
            if (diff.inMinutes > 60) {
                 // After 60 mins, delivered
                 await box.putAt(i, order.copyWith(status: 'delivered', isCurrent: false));
            } else if (diff.inMinutes > 30) {
                 await box.putAt(i, order.copyWith(status: 'out_for_delivery'));
            } else if (diff.inMinutes > 10) {
                 await box.putAt(i, order.copyWith(status: 'preparing'));
            }
        }
    }
  }
}
