import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Domain-level exception with user-facing message.
class AppException implements Exception {
  final String message;
  final String? code;
  final Object? cause;

  const AppException(this.message, {this.code, this.cause});

  @override
  String toString() => 'AppException($code): $message';
}

/// Maps Firebase / platform errors to safe user messages.
class ErrorMapper {
  ErrorMapper._();

  static AppException map(Object error, {StackTrace? stack}) {
    if (kDebugMode) {
      debugPrint('ErrorMapper: $error');
      if (stack != null) debugPrint('$stack');
    }

    if (error is AppException) return error;

    if (error is FirebaseAuthException) {
      return AppException(_authMessage(error), code: error.code, cause: error);
    }

    final text = error.toString().toLowerCase();

    if (text.contains('permission-denied') || text.contains('permission_denied')) {
      return AppException(
        'You do not have permission to perform this action.',
        code: 'permission-denied',
        cause: error,
      );
    }
    if (text.contains('unavailable') || text.contains('network')) {
      return AppException(
        'Network unavailable. Please check your connection and try again.',
        code: 'unavailable',
        cause: error,
      );
    }
    if (text.contains('not-found') || text.contains('not_found')) {
      return AppException(
        'The requested data was not found.',
        code: 'not-found',
        cause: error,
      );
    }
    if (text.contains('already-exists') || text.contains('already_exists')) {
      return AppException(
        'This record already exists.',
        code: 'already-exists',
        cause: error,
      );
    }
    if (text.contains('failed-precondition')) {
      return AppException(
        'This action cannot be completed in the current state.',
        code: 'failed-precondition',
        cause: error,
      );
    }

    return AppException(
      'Something went wrong. Please try again.',
      code: 'unknown',
      cause: error,
    );
  }

  static String _authMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters).';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
