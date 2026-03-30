import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/cart/cart_event.dart';
import '../../blocs/cart/cart_state.dart';
import '../../blocs/order/order_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/cart/cart_item_tile.dart';
import '../../widgets/cart/payment_method_selector.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promoController = TextEditingController();
  String _paymentMethod = 'cash';
  bool _isProcessingOrder = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _onPlaceOrder(CartLoaded cartState) {
    setState(() => _isProcessingOrder = true);

    final authState = context.read<AuthBloc>().state;
    String userId = 'guest';
    if (authState is Authenticated) {
      userId = authState.user.id;
    }

    context.read<OrderBloc>().add(PlaceOrderEvent(
      userId: userId,
      items: cartState.items,
      totalAmount: cartState.total,
      paymentMethod: _paymentMethod,
    ));
    
    // Simulate slight delay before success bottom sheet
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isProcessingOrder = false);
        context.read<CartBloc>().add(ClearCart());
        _showSuccessBottomSheet();
      }
    });
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BounceInUnit(
                child: const Icon(Icons.check_circle, color: AppColors.successGreen, size: 100),
              ),
              const SizedBox(height: 16),
              const Text(
                'Order Placed Successfully!',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Estimated Delivery: 45 minutes',
                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                  ),
                  onPressed: () {
                    context.pop(); // close bottom sheet
                    context.go(AppRoutes.orders); // go to orders
                  },
                  child: const Text('Track Order'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.pop();
                    context.go(AppRoutes.home);
                  },
                  child: const Text('Continue Shopping'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
         if (state is CartError) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
         }
      },
      builder: (context, state) {
        if (state is CartLoading) return const Center(child: CircularProgressIndicator());
        if (state is CartLoaded) {
          if (state.items.isEmpty) return _buildEmptyCart();
          return _buildCartList(state);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyCart() {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.bag_2, size: 100, color: AppColors.textMuted),
            const SizedBox(height: 24),
            const Text(
              AppStrings.yourCartIsEmpty,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text(AppStrings.startShopping),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCartList(CartLoaded state) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.myCart} (${state.items.length})'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<CartBloc>().add(LoadCart());
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  return CartItemTile(item: state.items[index]);
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        decoration: InputDecoration(
                          hintText: 'PROMO CODE (Try FAROOQUE10)',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: AppColors.textDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        context.read<CartBloc>().add(ApplyPromoCode(_promoController.text));
                      },
                      child: const Text('Apply'),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildOrderSummary(state),
              const SizedBox(height: 16),
              PaymentMethodSelector(
                onMethodSelected: (method) {
                  setState(() => _paymentMethod = method);
                },
              ),
              const SizedBox(height: 100), // padding for bottom button
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.shade300, offset: const Offset(0, -2), blurRadius: 10),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
            onPressed: _isProcessingOrder ? null : () => _onPlaceOrder(state),
            child: _isProcessingOrder
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('Place Order — ₹${state.total.toInt()}', style: const TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('₹${state.subtotal.toInt()}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery Fee'),
              Text(state.deliveryFee == 0 ? 'FREE' : '₹${state.deliveryFee.toInt()}',
                  style: TextStyle(color: state.deliveryFee == 0 ? AppColors.successGreen : AppColors.textDark)),
            ],
          ),
          if (state.discount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Discount Applied', style: TextStyle(color: AppColors.successGreen)),
                Text('-₹${state.discount.toInt()}', style: const TextStyle(color: AppColors.successGreen)),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('₹${state.total.toInt()}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
            ],
          ),
        ],
      ),
    );
  }
}

class BounceInUnit extends StatelessWidget {
  final Widget child;
  const BounceInUnit({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return BounceIn(child: child);
  }
}
