import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../sources/local/hive_service.dart';

class CartRepository {
  final HiveService _hiveService;

  CartRepository(this._hiveService);

  Future<List<CartItemModel>> getCartItems() async {
    return _hiveService.cartBox.values.toList();
  }

  Future<void> addToCart(ProductModel product, {int qty = 1}) async {
    final box = _hiveService.cartBox;
    // Check if already in cart
    int existingItemIndex = -1;
    for (int i = 0; i < box.length; i++) {
      if (box.getAt(i)?.productId == product.id) {
        existingItemIndex = i;
        break;
      }
    }

    if (existingItemIndex != -1) {
      // Update qty
      final existingItem = box.getAt(existingItemIndex)!;
      existingItem.quantity += qty;
      await existingItem.save();
    } else {
      // Add new
      final newItem = CartItemModel(
        productId: product.id,
        productName: product.name,
        imageUrl: product.imageUrl,
        price: product.price,
        quantity: qty,
      );
      await box.add(newItem);
    }
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    final box = _hiveService.cartBox;
    for (int i = 0; i < box.length; i++) {
      final item = box.getAt(i);
      if (item?.productId == productId) {
        if (newQuantity <= 0) {
          await item?.delete();
        } else {
          item!.quantity = newQuantity;
          await item.save();
        }
        break;
      }
    }
  }

  Future<void> removeFromCart(String productId) async {
    final box = _hiveService.cartBox;
    final itemToRemove = box.values.where((element) => element.productId == productId).firstOrNull;
    if (itemToRemove != null) {
      await itemToRemove.delete();
    }
  }

  Future<void> clearCart() async {
    await _hiveService.cartBox.clear();
  }
}
