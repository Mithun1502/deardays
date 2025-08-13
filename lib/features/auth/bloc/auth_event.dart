part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class SignInWithGoogleEvent extends AuthEvent {
  const SignInWithGoogleEvent();
}

class SendOtpEvent extends AuthEvent {
  final String phoneNumber;
  const SendOtpEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyPhoneAuthCredentialEvent extends AuthEvent {
  final PhoneAuthCredential credential;
  const VerifyPhoneAuthCredentialEvent(this.credential);

  @override
  List<Object?> get props => [credential];
}

class OtpFailedEvent extends AuthEvent {
  final String error;
  const OtpFailedEvent(this.error);

  @override
  List<Object?> get props => [error];
}

class OtpCodeSentEvent extends AuthEvent {
  final String verificationId;
  const OtpCodeSentEvent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

class OtpTimeoutEvent extends AuthEvent {
  const OtpTimeoutEvent();
}

class VerifyOtpEvent extends AuthEvent {
  final String verificationId;
  final String otp;
  const VerifyOtpEvent(this.verificationId, this.otp);

  @override
  List<Object?> get props => [verificationId, otp];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}
