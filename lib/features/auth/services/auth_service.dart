import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({this.webClientId});

  final String? webClientId;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _googleReady = false;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Future<void> warmUpGoogleSignIn() => _initGoogleSignIn();

  Future<void> _initGoogleSignIn() async {
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize(clientId: webClientId);
    _googleReady = true;
  }

  Future<UserCredential?> trySilentGoogleSignIn() async {
    await _initGoogleSignIn();
    try {
      final googleUser = await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (googleUser == null) return null;

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) return null;

      return _firebaseAuth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    } catch (_) {
      return null;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    await _initGoogleSignIn();
    final silent = await trySilentGoogleSignIn();
    if (silent != null) return silent;

    final googleUser = await GoogleSignIn.instance.authenticate();
    final idToken = googleUser.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    if (_googleReady) {
      await GoogleSignIn.instance.signOut();
    }
    await _firebaseAuth.signOut();
  }

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return user.getIdToken(forceRefresh);
  }
}
