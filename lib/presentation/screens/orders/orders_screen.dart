import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/cart/cart_event.dart';
import '../../blocs/order/order_bloc.dart';
import '../../widgets/orders/order_tile.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadOrders());
    context.read<OrderBloc>().add(UpdateOrderStatusesEvent());
  }

  void _handleReorder(OrderModel order) {
    for (var item in order.items) {
      final p = ProductModel(
        id: item.productId,
        name: item.productName,
        category: '', // not needed for cart
        imageUrl: item.imageUrl,
        description: '',
        price: item.price,
        originalPrice: item.price,
        rating: 0,
        reviewCount: 0,
        inStock: true,
        isOnOffer: false,
        discountPercent: 0,
      );
      context.read<CartBloc>().add(AddProductToCart(p, quantity: item.quantity));
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Items added to cart')));
    context.go(AppRoutes.cart);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderLoaded) {
            final orders = state.orders;
            if (orders.isEmpty) {
              return _buildEmptyState();
            }

            final currentOrders = orders.where((o) => o.isCurrent).toList();
            final pastOrders = orders.where((o) => !o.isCurrent).toList();

            return RefreshIndicator(
              onRefresh: () async {
                 context.read<OrderBloc>().add(UpdateOrderStatusesEvent());
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  if (currentOrders.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Current Orders',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    ...currentOrders.map((o) => _buildCurrentOrderCard(o)),
                  ],
                  if (pastOrders.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Order History',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    ...pastOrders.map((o) => OrderTile(
                          order: o,
                          onReorderTap: () => _handleReorder(o),
                        )),
                  ]
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.receipt, size: 80, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text('No orders yet', style: TextStyle(fontSize: 18, color: AppColors.textMuted)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Start Shopping'),
          )
        ],
      ),
    );
  }

  Widget _buildCurrentOrderCard(OrderModel order) {
    final steps = ['Confirmed', 'Preparing', 'Out for Delivery'];
    
    int currentStepIndex = 1;
    if (order.status == 'preparing') currentStepIndex = 2;
    if (order.status == 'out_for_delivery') currentStepIndex = 3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: AppColors.accentGold, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                const Text('Order in Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(order.id, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            // Tracker stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: steps.asMap().entries.map((entry) {
                int i = entry.key + 1;
                bool isCompleted = i <= currentStepIndex;
                bool isActive = i == currentStepIndex;
                
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? AppColors.primaryGreen : Colors.grey.shade300,
                        ),
                        child: isActive 
                            ? const Icon(Icons.sync, size: 14, color: Colors.white)
                            : isCompleted 
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                      ),
                      const SizedBox(height: 4),
                      Text(entry.value, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: isActive ? AppColors.primaryGreen : AppColors.textMuted)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimated Arrival:'),
                Text(
                  order.estimatedDelivery != null 
                    ? DateFormat('HH:mm').format(order.estimatedDelivery!) 
                    : '--:--',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
