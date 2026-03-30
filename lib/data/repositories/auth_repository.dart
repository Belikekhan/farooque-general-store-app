import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../sources/local/hive_service.dart';

class AuthRepository {
  final HiveService _hiveService;
  final Uuid _uuid = const Uuid();

  AuthRepository(this._hiveService);

  Future<UserModel?> getLoggedInUser() async {
    final box = _hiveService.userBox;
    if (box.isNotEmpty) {
      return box.getAt(0); // We just keep one user session for the demo
    }
    return null;
  }

  Future<UserModel> login(String email, String password) async {
    // Demo implementation: always mock a successful login if fields exist
    // Or check if user exists in box
    final box = _hiveService.userBox;
    if (box.isNotEmpty) {
      final user = box.getAt(0);
      if (user != null && user.email == email && user.password == password) {
        return user;
      }
    }
    throw Exception('Invalid email or password');
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String address,
    required String city,
    required String pincode,
  }) async {
    final box = _hiveService.userBox;
    final newUser = UserModel(
      id: _uuid.v4(),
      name: name,
      email: email,
      phone: phone,
      password: password,
      address: address,
      city: city,
      pincode: pincode,
      createdAt: DateTime.now(),
    );
    await box.clear(); // Ensure only one active session
    await box.add(newUser);
    return newUser;
  }

  Future<void> logout() async {
    await _hiveService.clearAll(); // clears user session, cart, orders
  }
}
