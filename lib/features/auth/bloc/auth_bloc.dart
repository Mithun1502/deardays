import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dear_days/features/auth/data/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final FirebaseAuth auth = FirebaseAuth.instance;

  StreamSubscription<User?>? _authSub;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AppStarted>((event, emit) async {
      emit(const AuthLoading());
      await _authSub?.cancel();
      _authSub = auth.authStateChanges().listen((user) async {
        if (user == null) {
          add(_AuthUserChanged(null));
        } else {
          await _saveProviderInfo(_detectPrimaryProvider(user));
          add(_AuthUserChanged(user));
        }
      });
    });

    on<_AuthUserChanged>((event, emit) {
      final user = event.user;
      if (user == null) {
        emit(const AuthUnauthenticated());
      } else {
        emit(AuthSuccess(user));
      }
    });

    on<SignInWithGoogleEvent>((event, emit) async {
      emit(const AuthLoading());
      try {
        final userCredential = await authRepository.signInWithGoogle();
        if (userCredential == null || userCredential.user == null) {
          emit(const AuthFailure("Google sign-in cancelled"));
          return;
        }
        await _saveProviderInfo("google");
        emit(AuthSuccess(userCredential.user!));
      } catch (e) {
        emit(AuthFailure(_prettyFirebaseError(e)));
      }
    });

    on<SendOtpEvent>((event, emit) async {
      emit(const AuthLoading());
      try {
        await auth.verifyPhoneNumber(
          phoneNumber: event.phoneNumber,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            add(VerifyPhoneAuthCredentialEvent(credential));
          },
          verificationFailed: (FirebaseAuthException e) {
            add(OtpFailedEvent(_prettyFirebaseError(e)));
          },
          codeSent: (String verificationId, int? resendToken) {
            add(OtpCodeSentEvent(verificationId));
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            add(const OtpTimeoutEvent());
          },
        );
      } catch (e) {
        emit(AuthFailure(_prettyFirebaseError(e)));
      }
    });

    on<VerifyPhoneAuthCredentialEvent>((event, emit) async {
      emit(const AuthLoading());
      try {
        await auth.signInWithCredential(event.credential);
        await _saveProviderInfo("phone");
        emit(AuthSuccess(auth.currentUser!));
      } catch (e) {
        emit(AuthFailure(_prettyFirebaseError(e)));
      }
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(const OtpVerifying());
      try {
        await authRepository.verifyOtp(event.verificationId, event.otp);
        await _saveProviderInfo("phone");
        emit(AuthSuccess(auth.currentUser!));
      } catch (e) {
        emit(AuthFailure(_prettyFirebaseError(e)));
      }
    });

    on<OtpFailedEvent>((event, emit) {
      emit(AuthFailure(event.error));
    });

    on<OtpCodeSentEvent>((event, emit) {
      emit(OtpSent(event.verificationId));
    });

    on<OtpTimeoutEvent>((event, emit) {
      emit(const OtpTimeout());
    });

    on<SignOutEvent>((event, emit) async {
      emit(const AuthLoading());
      try {
        await authRepository.signOut();
        emit(const AuthUnauthenticated());
      } catch (e) {
        emit(AuthFailure(_prettyFirebaseError(e)));
      }
    });
  }

  String _detectPrimaryProvider(User user) {
    if (user.providerData.isEmpty) return "unknown";
    return user.providerData.first.providerId;
  }

  Future<void> _saveProviderInfo(String provider) async {
    final user = auth.currentUser;
    if (user == null) return;

    final users = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final nowIso = DateTime.now().toIso8601String();

    await users.set({
      'uid': user.uid,
      'email': user.email,
      'phone': user.phoneNumber,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'lastLogin': nowIso,
      'providers': FieldValue.arrayUnion([provider]),
      'provider': provider,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _prettyFirebaseError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-disabled':
          return 'Your account is disabled. Contact support.';
        case 'network-request-failed':
          return 'Network issue. Please check your connection.';
        case 'invalid-verification-code':
          return 'Invalid OTP. Please try again.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait and try later.';
        case 'session-expired':
          return 'OTP session expired. Request a new code.';
      }
      return e.message ?? 'Authentication failed. Please try again.';
    }
    return e.toString();
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}

// Private event used internally in Bloc
class _AuthUserChanged extends AuthEvent {
  final User? user;
  const _AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user?.uid];
}
