import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String address;
  final String city;
  final String pincode;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.address,
    required this.city,
    required this.pincode,
  });

  @override
  List<Object> get props => [name, email, phone, password, address, city, pincode];
}

class AuthLogoutRequested extends AuthEvent {}
