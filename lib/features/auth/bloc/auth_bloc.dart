import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>((event, emit) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        emit(Authenticated());
      } else {
        emit(Unauthenticated());
      }
    });

    on<LoginWithEmail>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.loginWithEmail(event.email, event.password);
        emit(Authenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(Unauthenticated());
      }
    });

    on<SignUpWithEmail>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signUpWithEmail(event.email, event.password);
        emit(Authenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(Unauthenticated());
      }
    });

    on<SignOut>((event, emit) async {
      await authRepository.signOut();
      emit(Unauthenticated());
    });

    on<LoginWithGoogle>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signInWithGoogle();
        emit(Authenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(Unauthenticated());
      }
    });
  }
}
