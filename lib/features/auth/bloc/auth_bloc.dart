import 'package:bloc/bloc.dart';
import 'package:dear_days/features/auth/data/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final FirebaseAuth auth = FirebaseAuth.instance;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      final user = auth.currentUser;
      if (emit.isDone) return;
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthFailure("No user logged in"));
      }
    });

    on<LoginWithEmailEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.loginWithEmail(event.email, event.password);
        if (emit.isDone) return;
        emit(AuthSuccess(auth.currentUser));
      } catch (e) {
        if (emit.isDone) return;
        emit(AuthFailure(e.toString()));
      }
    });
    on<SignUpWithEmailEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signUpWithEmail(event.email, event.password);
        if (emit.isDone) return;
        emit(AuthSuccess(auth.currentUser));
      } catch (e) {
        if (emit.isDone) return;
        emit(AuthFailure(e.toString()));
      }
    });

    on<SignInWithGoogleEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signInWithGoogle();
        if (emit.isDone) return;
        emit(AuthSuccess(auth.currentUser));
      } catch (e) {
        if (emit.isDone) return;
        emit(AuthFailure(e.toString()));
      }
    });

    on<SendOtpEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        await auth.verifyPhoneNumber(
          phoneNumber: event.phoneNumber,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) {
            add(VerifyPhoneAuthCredentialEvent(credential));
          },
          verificationFailed: (FirebaseAuthException e) {
            add(OtpFailedEvent(e.message ?? "OTP verification failed"));
          },
          codeSent: (String verificationId, int? resendToken) {
            add(OtpCodeSentEvent(verificationId));
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            add(OtpTimeoutEvent());
          },
        );
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
    on<VerifyPhoneAuthCredentialEvent>((event, emit) async {
      try {
        await auth.signInWithCredential(event.credential);
        emit(AuthSuccess(auth.currentUser));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<OtpFailedEvent>((event, emit) {
      emit(AuthFailure(event.error));
    });

    on<OtpCodeSentEvent>((event, emit) {
      emit(OtpSent(event.verificationId));
    });

    on<OtpTimeoutEvent>((event, emit) {
      emit(OtpTimeout());
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.verifyOtp(event.verificationId, event.otp);
        if (emit.isDone) return;
        emit(AuthSuccess(auth.currentUser));
      } catch (e) {
        if (emit.isDone) return;
        emit(AuthFailure(e.toString()));
      }
    });
    on<SignOutEvent>((event, emit) async {
      await authRepository.signOut();
      if (emit.isDone) return;
      emit(AuthFailure("Logged out"));
    });
  }
}
