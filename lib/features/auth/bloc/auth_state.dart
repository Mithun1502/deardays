part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user.uid];
}

class AuthFailure extends AuthState {
  final String error;
  const AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class OtpSent extends AuthState {
  final String verificationId;
  const OtpSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

class OtpTimeout extends AuthState {
  const OtpTimeout();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class OtpVerifying extends AuthState {
  const OtpVerifying();
}
