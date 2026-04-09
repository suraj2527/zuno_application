import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInitialized = false;

  User? get currentUser => _auth.currentUser;

  Future<void> initGoogleSignIn() async {
    if (_googleInitialized) return;

    await _googleSignIn.initialize(
      serverClientId:
          '672092699296-90e2c2bcvmrgongatqstu2h81hddegt2.apps.googleusercontent.com',
    );

    _googleInitialized = true;
  }

  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    await _auth.currentUser?.reload();
  }

  /* ================= EMAIL & PASSWORD ================= */

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (_) {
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (_) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /* ================= GOOGLE SIGN IN ================= */

  Future<UserCredential> signInWithGoogle() async {
    try {
      await initGoogleSignIn();

      // optional: old account clear so chooser always opens
      await _googleSignIn.signOut();

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // accessToken: googleAuth.accessToken,
      );

      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      throw 'Google sign in failed: ${e.description ?? e.code.name}';
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Google sign in failed: $e';
    }
  }

  /* ================= SIGN OUT ================= */

  Future<void> signOut() async {
    await _auth.signOut();

    try {
      await initGoogleSignIn();
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  /* ================= ERROR HANDLER ================= */

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'account-exists-with-different-credential':
        return 'This email is already linked with another sign in method.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}