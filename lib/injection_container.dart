import 'package:get_it/get_it.dart';
import 'data/sources/local/hive_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/order_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/cart/cart_bloc.dart';
import 'presentation/blocs/order/order_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton<HiveService>(() => HiveService());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(sl()));
  sl.registerLazySingleton<ProductRepository>(() => ProductRepository(sl()));
  sl.registerLazySingleton<CartRepository>(() => CartRepository(sl()));
  sl.registerLazySingleton<OrderRepository>(() => OrderRepository(sl()));

  // BLoCs
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => CartBloc(cartRepository: sl()));
  sl.registerFactory(() => OrderBloc(orderRepository: sl()));
}
