abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoginWithEmail extends AuthEvent {
  final String email;
  final String password;

  LoginWithEmail(this.email, this.password);
}

class GoogleSignInRequested extends AuthEvent {}

class SignUpWithEmail extends AuthEvent {
  final String email;
  final String password;

  SignUpWithEmail(this.email, this.password);
}

class SignOut extends AuthEvent {}

class LoginWithGoogle extends AuthEvent {}
