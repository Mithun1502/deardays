part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User? user;

  AuthSuccess([this.user]);

  @override
  List<Object?> get props => [user ?? ''];
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class OtpSent extends AuthState {
  final String verificationId;

  OtpSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

class OtpTimeout extends AuthState {}
