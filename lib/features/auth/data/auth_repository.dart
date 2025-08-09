import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  Future<UserCredential> loginWithEmail(String email, String password) async {
    await _clearSessions();
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    await _clearSessions();
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    await _clearSessions();

    // Force account picker by signing out Google completely before sign-in
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User cancelled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String) codeSent,
    required Function(FirebaseAuthException) onFailed,
    required Function(PhoneAuthCredential) onCompleted,
    required Function(String) onTimeout,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onCompleted,
      verificationFailed: onFailed,
      codeSent: (verificationId, _) => codeSent(verificationId),
      codeAutoRetrievalTimeout: onTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  Future<UserCredential> verifyOtp(String verificationId, String otp) async {
    await _clearSessions();
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _clearSessions();
  }

  String? getLoginProvider() {
    final user = _firebaseAuth.currentUser;
    if (user != null && user.providerData.isNotEmpty) {
      return user.providerData.first.providerId;
    }
    return null;
  }

  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  Future<void> _clearSessions() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (_) {}
  }
}
