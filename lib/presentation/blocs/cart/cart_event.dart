import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/cart_item_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object> get props => [];
}

class LoadCart extends CartEvent {}

class AddProductToCart extends CartEvent {
  final ProductModel product;
  final int quantity;
  const AddProductToCart(this.product, {this.quantity = 1});
  @override
  List<Object> get props => [product, quantity];
}

class UpdateCartItemQuantity extends CartEvent {
  final String productId;
  final int quantity;
  const UpdateCartItemQuantity(this.productId, this.quantity);
  @override
  List<Object> get props => [productId, quantity];
}

class RemoveCartItem extends CartEvent {
  final String productId;
  const RemoveCartItem(this.productId);
  @override
  List<Object> get props => [productId];
}

class ClearCart extends CartEvent {}

class ApplyPromoCode extends CartEvent {
  final String code;
  const ApplyPromoCode(this.code);
  @override
  List<Object> get props => [code];
}
