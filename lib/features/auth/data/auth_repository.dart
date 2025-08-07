import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // ✅ Login with email
  Future<UserCredential> loginWithEmail(String email, String password) async {
    await _firebaseAuth.signOut(); // ❗Important to avoid merging
    return await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  // ✅ Signup with email
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    await _firebaseAuth.signOut();
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // ✅ Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    await _firebaseAuth.signOut();
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  // ✅ Send OTP for phone login
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

  // ✅ Verify OTP and login
  Future<UserCredential> verifyOtp(String verificationId, String otp) async {
    await _firebaseAuth.signOut();
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otp);
    return await _firebaseAuth.signInWithCredential(credential);
  }

  // ✅ Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut();
  }

  // ✅ Get current login provider
  String? getLoginProvider() {
    final user = _firebaseAuth.currentUser;
    if (user != null && user.providerData.isNotEmpty) {
      return user.providerData.first
          .providerId; // eg: 'google.com', 'password', 'phone'
    }
    return null;
  }

  // ✅ Get current UID (optional)
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  // ✅ Check if user is logged in
  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }
}
