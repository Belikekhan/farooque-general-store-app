import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'product_model.g.dart';

@HiveType(typeId: 1)
class ProductModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final double price;

  @HiveField(6)
  final double originalPrice;

  @HiveField(7)
  final double rating;

  @HiveField(8)
  final int reviewCount;

  @HiveField(9)
  final bool inStock;

  @HiveField(10)
  final bool isOnOffer;

  @HiveField(11)
  final int discountPercent;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.inStock,
    required this.isOnOffer,
    required this.discountPercent,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        imageUrl,
        description,
        price,
        originalPrice,
        rating,
        reviewCount,
        inStock,
        isOnOffer,
        discountPercent,
      ];
}
