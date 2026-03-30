import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 2)
class CartItemModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final double price;

  @HiveField(4)
  int quantity;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, productName, imageUrl, price, quantity];
  
  CartItemModel copyWith({
    String? productId,
    String? productName,
    String? imageUrl,
    double? price,
    int? quantity,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
