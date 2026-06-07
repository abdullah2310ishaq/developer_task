import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:developer_task/features/auth/models/app_user.dart';
import 'package:developer_task/features/auth/services/auth_service.dart';
import 'package:developer_task/features/auth/services/auth_user_service.dart';
import 'package:developer_task/features/auth/services/session_token_storage.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(
    this._authService,
    this._authUserService,
    this._sessionStorage,
  );

  final AuthService _authService;
  final AuthUserService _authUserService;
  final SessionTokenStorage _sessionStorage;

  bool isLoading = false;
  bool isSigningOut = false;
  String? errorMessage;
  AppUser? currentUser;
  StoredSession? activeSession;

  bool get isLoggedIn => currentUser != null;

  bool get needsProfileSetup => currentUser?.needsProfileSetup ?? false;

  Duration? get sessionTimeRemaining {
    final session = activeSession;
    if (session == null || session.isExpired) return null;
    return session.timeRemaining;
  }

  void _notify() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle || phase == SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }

  Future<void> restoreSession() async {
    isLoading = true;
    errorMessage = null;
    _notify();

    try {
      final session = await _sessionStorage.readSession();
      if (session == null || session.isExpired) {
        final expired = session?.isExpired == true;
        await _clearSession();
        if (expired) errorMessage = 'Session expired. Please login again.';
        return;
      }

      final firebaseUser = _authService.currentFirebaseUser;
      if (firebaseUser == null || firebaseUser.uid != session.uid) {
        await _clearSession();
        errorMessage = 'Session expired. Please login again.';
        return;
      }

      activeSession = session;
      currentUser = await _authUserService.fetchUser(session.uid);
      if (currentUser == null) {
        await _clearSession();
      }
    } catch (e) {
      errorMessage = 'Could not restore session';
      await _clearSession();
    } finally {
      isLoading = false;
      _notify();
    }
  }

  Future<void> warmUpGoogleSignIn() => _authService.warmUpGoogleSignIn();

  Future<User?> waitForAuthReady() => _authService.waitForAuthReady();

  Future<bool> validateSession() async {
    final session = await _sessionStorage.readSession();
    if (session == null || session.isExpired) {
      final expired = session?.isExpired == true;
      await _clearSession();
      if (expired) errorMessage = 'Session expired. Please login again.';
      _notify();
      return false;
    }

    activeSession = session;
    currentUser ??= await _authUserService.fetchUser(session.uid);
    _notify();
    return currentUser != null;
  }

  Future<bool> tryResumeCustomerSession() async {
    try {
      final session = await _sessionStorage.readSession();
      if (session == null || session.isExpired) return false;

      var firebaseUser = _authService.currentFirebaseUser;
      if (firebaseUser == null || firebaseUser.uid != session.uid) {
        final silent = await _authService.trySilentGoogleSignIn();
        firebaseUser = silent?.user;
        if (firebaseUser == null || firebaseUser.uid != session.uid) return false;
      }

      activeSession = session;
      currentUser ??= await _authUserService.fetchUser(session.uid);
      if (currentUser == null || currentUser!.role.isAdmin) return false;

      _notify();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    _notify();

    try {
      final credential = await _authService.signInWithGoogle();
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        errorMessage = 'Google sign-in failed';
        return false;
      }

      final appUser = await _authUserService.ensureGoogleUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
      );

      if (appUser.role.isAdmin) {
        await _clearSession();
        errorMessage = 'Use admin login for this account';
        return false;
      }

      await _persistSession(firebaseUser.uid);
      currentUser = appUser;
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'Google sign-in failed';
      return false;
    } catch (e) {
      errorMessage = 'Google sign-in failed';
      return false;
    } finally {
      isLoading = false;
      _notify();
    }
  }

  Future<bool> signInAsAdmin({
    required String username,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    _notify();

    try {
      final email = _normalizeAdminEmail(username);
      final credential = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        errorMessage = 'Login failed';
        return false;
      }

      final appUser = await _authUserService.fetchUser(firebaseUser.uid);
      if (appUser == null || !appUser.role.isAdmin) {
        await _clearSession();
        errorMessage = 'Not an admin account';
        return false;
      }

      await _persistSession(firebaseUser.uid);
      currentUser = appUser;
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapAuthError(e);
      return false;
    } catch (e) {
      errorMessage = 'Login failed';
      return false;
    } finally {
      isLoading = false;
      _notify();
    }
  }

  Future<bool> saveProfile({
    required String displayName,
    required String phone,
    required String address,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) return false;

    isLoading = true;
    errorMessage = null;
    _notify();

    try {
      currentUser = await _authUserService.saveProfile(
        uid: uid,
        displayName: displayName,
        phone: phone,
        address: address,
      );
      return true;
    } catch (e) {
      errorMessage = 'Could not save profile';
      return false;
    } finally {
      isLoading = false;
      _notify();
    }
  }

  void beginSignOut() {
    isSigningOut = true;
    _notify();
  }

  Future<void> executeSignOut() async {
    try {
      await _clearSession();
    } finally {
      isSigningOut = false;
      _notify();
    }
  }

  Future<void> signOut() async {
    beginSignOut();
    await executeSignOut();
  }

  Future<void> _persistSession(String uid) async {
    // Fresh sign-in already has a valid token — forceRefresh adds a slow network round-trip.
    final token = await _authService.getIdToken(forceRefresh: false);
    if (token == null) return;
    activeSession = await _sessionStorage.saveSession(token: token, uid: uid);
  }

  Future<void> _clearSession() async {
    await _sessionStorage.clear();
    await _authService.signOut();
    activeSession = null;
    currentUser = null;
    errorMessage = null;
  }

  String _normalizeAdminEmail(String username) {
    final trimmed = username.trim();
    if (trimmed.contains('@')) return trimmed;
    return '$trimmed@fooddelivery.app';
  }

  String _mapAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' || 'wrong-password' || 'invalid-credential' =>
        'Wrong username or password',
      'invalid-email' => 'Invalid email format',
      _ => e.message ?? 'Login failed',
    };
  }
}
