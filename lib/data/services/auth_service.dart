import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/enums.dart';
import '../models/user_model.dart';

/// Result wrapper for auth operations
class AuthResult {
  final bool success;
  final String? errorMessage;
  final UserModel? user;
  final UserRole? role;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
    this.role,
  });

  factory AuthResult.ok({UserModel? user, UserRole? role}) =>
      AuthResult(success: true, user: user, role: role);

  factory AuthResult.fail(String message) =>
      AuthResult(success: false, errorMessage: message);
}

/// Abstract auth service – UI depends only on this
abstract class AuthService {
  Stream<User?> get authStateChanges;
  User? get currentFirebaseUser;
  Future<AuthResult> signInWithEmail(String email, String password);
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  });
  Future<AuthResult> signInWithGoogle();
  Future<AuthResult> sendPasswordReset(String email);
  Future<void> signOut();
  Future<UserRole> resolveRole(String uid, String email);
}

/// Demo / offline auth that works without Firebase config
class DemoAuthService implements AuthService {
  UserRole? _role;
  String? _email;

  @override
  Stream<User?> get authStateChanges => Stream.value(null);

  @override
  User? get currentFirebaseUser => null;

  @override
  Future<AuthResult> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (password.length < 6) {
      return AuthResult.fail('Password must be at least 6 characters');
    }
    final lower = email.trim().toLowerCase();
    UserRole role = UserRole.guest;
    if (lower.contains('admin')) {
      role = UserRole.admin;
    } else if (lower.contains('manager')) {
      role = UserRole.manager;
    } else if (lower.contains('reception')) {
      role = UserRole.receptionist;
    } else if (lower.contains('house')) {
      role = UserRole.housekeeping;
    } else if (lower.contains('restaurant') || lower.contains('kitchen')) {
      role = UserRole.restaurantStaff;
    } else if (lower.contains('maint')) {
      role = UserRole.maintenance;
    }
    _role = role;
    _email = lower;
    return AuthResult.ok(
      role: role,
      user: UserModel(
        id: 'demo_${role.name}',
        email: lower,
        firstName: role.displayName,
        lastName: 'User',
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (password.length < 6) {
      return AuthResult.fail('Password must be at least 6 characters');
    }
    if (!email.contains('@')) {
      return AuthResult.fail('Invalid email address');
    }
    _role = UserRole.guest;
    _email = email.trim().toLowerCase();
    return AuthResult.ok(
      role: UserRole.guest,
      user: UserModel(
        id: 'demo_guest_${DateTime.now().millisecondsSinceEpoch}',
        email: _email!,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        role: UserRole.guest,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Demo Google sign-in maps to guest
    _role = UserRole.guest;
    _email = 'google.user@example.com';
    return AuthResult.ok(
      role: UserRole.guest,
      user: UserModel(
        id: 'demo_google',
        email: _email!,
        firstName: 'Google',
        lastName: 'User',
        role: UserRole.guest,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<AuthResult> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!email.contains('@')) {
      return AuthResult.fail('Invalid email address');
    }
    return AuthResult.ok();
  }

  @override
  Future<void> signOut() async {
    _role = null;
    _email = null;
  }

  @override
  Future<UserRole> resolveRole(String uid, String email) async {
    return _role ?? UserRole.guest;
  }
}

/// Firebase-backed auth service
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentFirebaseUser => _auth.currentUser;

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak (min 6 characters)';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return e.message ?? 'Authentication failed';
    }
  }

  @override
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) return AuthResult.fail('Sign in failed');
      final role = await resolveRole(user.uid, user.email ?? email);
      return AuthResult.ok(
        role: role,
        user: UserModel(
          id: user.uid,
          email: user.email ?? email,
          firstName: user.displayName?.split(' ').first ?? 'User',
          lastName: user.displayName?.split(' ').skip(1).join(' ') ?? '',
          role: role,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.fail(e.toString());
    }
  }

  @override
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) return AuthResult.fail('Registration failed');
      await user.updateDisplayName('$firstName $lastName');
      // In production: write user doc to Firestore with role=guest
      return AuthResult.ok(
        role: UserRole.guest,
        user: UserModel(
          id: user.uid,
          email: email.trim(),
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          role: UserRole.guest,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.fail(e.toString());
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.fail('Google sign-in cancelled');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      final user = cred.user;
      if (user == null) return AuthResult.fail('Google sign-in failed');
      final role = await resolveRole(user.uid, user.email ?? '');
      return AuthResult.ok(
        role: role,
        user: UserModel(
          id: user.uid,
          email: user.email ?? '',
          firstName: user.displayName?.split(' ').first ?? 'User',
          lastName: user.displayName?.split(' ').skip(1).join(' ') ?? '',
          role: role,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.fail(e.toString());
    }
  }

  @override
  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.ok();
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.fail(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  @override
  Future<UserRole> resolveRole(String uid, String email) async {
    // Firebase mode: role is loaded from Firestore users/{uid} by the caller
    // (AuthController + FirebaseUserRepository). Never elevate from email.
    // Returning guest here is the safe default if profile is missing.
    return UserRole.guest;
  }
}

/// Factory: use Firebase when available, otherwise Demo
AuthService createAuthService({bool useFirebase = false}) {
  if (useFirebase) {
    try {
      return FirebaseAuthService();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase Auth unavailable, using DemoAuthService: $e');
      }
    }
  }
  return DemoAuthService();
}
