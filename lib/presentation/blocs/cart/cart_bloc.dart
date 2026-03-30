import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/models/cart_item_model.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;
  double _currentDiscount = 0.0;
  String _currentPromoCode = '';

  CartBloc({required this.cartRepository}) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddProductToCart>(_onAddProductToCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<RemoveCartItem>(_onRemoveCartItem);
    on<ClearCart>(_onClearCart);
    on<ApplyPromoCode>(_onApplyPromoCode);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final items = await cartRepository.getCartItems();
      _emitLoadedState(emit, items);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddProductToCart(AddProductToCart event, Emitter<CartState> emit) async {
    try {
      await cartRepository.addToCart(event.product, qty: event.quantity);
      final items = await cartRepository.getCartItems();
      _emitLoadedState(emit, items);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateCartItemQuantity(UpdateCartItemQuantity event, Emitter<CartState> emit) async {
    try {
      await cartRepository.updateQuantity(event.productId, event.quantity);
      final items = await cartRepository.getCartItems();
      _emitLoadedState(emit, items);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveCartItem(RemoveCartItem event, Emitter<CartState> emit) async {
    try {
      await cartRepository.removeFromCart(event.productId);
      final items = await cartRepository.getCartItems();
      _emitLoadedState(emit, items);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      await cartRepository.clearCart();
      _currentDiscount = 0.0;
      _currentPromoCode = '';
      _emitLoadedState(emit, []);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onApplyPromoCode(ApplyPromoCode event, Emitter<CartState> emit) async {
    try {
      if (event.code.toUpperCase() == 'FAROOQUE10') {
        _currentDiscount = 0.10; // 10% discount
        _currentPromoCode = event.code;
      } else {
        throw Exception('Invalid Promo Code');
      }
      final items = await cartRepository.getCartItems();
      _emitLoadedState(emit, items);
    } catch (e) {
      final items = await cartRepository.getCartItems();
      // Keep old state but show error by temporarily emitting error
      emit(CartError(e.toString().replaceAll('Exception: ', '')));
      _emitLoadedState(emit, items);
    }
  }

  void _emitLoadedState(Emitter<CartState> emit, List<CartItemModel> items) {
    double subtotal = 0;
    for (var item in items) {
      subtotal += item.price * item.quantity;
    }

    // Delivery logic: FREE if > 500
    double deliveryFee = (subtotal > 500 || subtotal == 0) ? 0 : 40.0;
    
    double discountAmount = subtotal * _currentDiscount;
    double total = subtotal + deliveryFee - discountAmount;

    emit(CartLoaded(
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discountAmount,
      total: total,
    ));
  }
}
