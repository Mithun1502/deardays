part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  LoginWithEmailEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class SignUpWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  SignUpWithEmailEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class SignInWithGoogleEvent extends AuthEvent {}

class SendOtpEvent extends AuthEvent {
  final String phoneNumber;

  SendOtpEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyPhoneAuthCredentialEvent extends AuthEvent {
  final PhoneAuthCredential credential;
  VerifyPhoneAuthCredentialEvent(this.credential);
}

class OtpFailedEvent extends AuthEvent {
  final String error;
  OtpFailedEvent(this.error);
}

class OtpCodeSentEvent extends AuthEvent {
  final String verificationId;
  OtpCodeSentEvent(this.verificationId);
}

class OtpTimeoutEvent extends AuthEvent {}

class VerifyOtpEvent extends AuthEvent {
  final String verificationId;
  final String otp;

  VerifyOtpEvent(this.verificationId, this.otp);

  @override
  List<Object?> get props => [verificationId, otp];
}

class SignOutEvent extends AuthEvent {}
