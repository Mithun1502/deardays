import 'package:bloc/bloc.dart';
import 'package:dear_days/features/auth/data/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String? verificationIdStored;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginWithEmailEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.loginWithEmail(event.email, event.password);
        emit(AuthSuccess(FirebaseAuth.instance.currentUser));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SignUpWithEmailEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signUpWithEmail(event.email, event.password);
        emit(AuthSuccess(FirebaseAuth.instance.currentUser));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SignInWithGoogleEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signInWithGoogle();
        emit(AuthSuccess(FirebaseAuth.instance.currentUser));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SendOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.sendOtp(
          phoneNumber: event.phoneNumber,
          codeSent: (verificationId) {
            verificationIdStored = verificationId;
            emit(OtpSent(verificationId));
          },
          onFailed: (e) {
            emit(AuthFailure(e.message ?? "OTP Send Failed"));
          },
          onCompleted: (credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
            emit(AuthSuccess(FirebaseAuth.instance.currentUser));
          },
          onTimeout: (String verificationId) {
            verificationIdStored = verificationId;
            emit(OtpTimeout());
          },
        );
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.verifyOtp(event.verificationId, event.otp);
        emit(AuthSuccess(FirebaseAuth.instance.currentUser));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SignOutEvent>((event, emit) async {
      await authRepository.signOut();
      emit(AuthInitial());
    });

    on<AppStarted>((event, emit) async {
      final user = auth.currentUser;
      if (user != null) {
        emit(AuthSuccess(FirebaseAuth.instance.currentUser));
      } else {
        emit(AuthInitial());
      }
    });
  }
}
