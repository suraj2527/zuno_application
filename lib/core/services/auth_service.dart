import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;

User? get currentUser => _auth.currentUser;

Future<void> updateDisplayName(String name) async {
  await _auth.currentUser?.updateDisplayName(name);
}
  /* ================= PHONE AUTH ================= */

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String) codeSent,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e.message ?? "Verification Failed";
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      throw "Verification ID not found";
    }

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    await _auth.signInWithCredential(credential);
  }

  /* ================= GOOGLE SIGN IN ================= */

  Future<UserCredential> signInWithGoogle() async {
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  await googleSignIn.initialize();

  final GoogleSignInAccount googleUser =
      await googleSignIn.authenticate();

  final GoogleSignInAuthentication googleAuth =
      googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    idToken: googleAuth.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}

  /* ================= LOGOUT ================= */

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
