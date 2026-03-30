import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class HiveService {
  static const String userBoxName = 'userBox';
  static const String productBoxName = 'productBox';
  static const String cartBoxName = 'cartBox';
  static const String orderBoxName = 'orderBox';
  static const String recentSearchesBoxName = 'recentSearchesBox';

  Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ProductModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(CartItemModelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(OrderModelAdapter());

    // Open Boxes
    await Hive.openBox<UserModel>(userBoxName);
    await Hive.openBox<ProductModel>(productBoxName);
    await Hive.openBox<CartItemModel>(cartBoxName);
    await Hive.openBox<OrderModel>(orderBoxName);
    await Hive.openBox<String>(recentSearchesBoxName);
  }

  Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);
  Box<ProductModel> get productBox => Hive.box<ProductModel>(productBoxName);
  Box<CartItemModel> get cartBox => Hive.box<CartItemModel>(cartBoxName);
  Box<OrderModel> get orderBox => Hive.box<OrderModel>(orderBoxName);
  Box<String> get recentSearchesBox => Hive.box<String>(recentSearchesBoxName);
  
  Future<void> clearAll() async {
    await userBox.clear();
    await cartBox.clear();
    await orderBox.clear();
    await recentSearchesBox.clear();
  }
}
