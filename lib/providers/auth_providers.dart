import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_config.dart';
import '../data/models/enums.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import 'repository_providers.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return createAuthService(useFirebase: AppConfig.kFirebaseEnabled);
});

final currentUserProvider = StateProvider<UserModel?>((ref) => null);
final authLoadingProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<String?>((ref) => null);
final authRoleProvider = StateProvider<UserRole?>((ref) => null);

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  AuthController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  AuthService get _auth => _ref.read(authServiceProvider);

  Future<UserModel?> _hydrateProfile(AuthResult result) async {
    var user = result.user;
    var role = result.role ?? UserRole.guest;

    if (AppConfig.useFirebaseDataEffective && user != null) {
      try {
        final userRepo = _ref.read(userRepositoryProvider);
        final existing = await userRepo.getById(user.id);
        if (existing != null) {
          user = existing;
          role = existing.role;
        } else {
          final profile = user.copyWith(role: UserRole.guest);
          await userRepo.create(profile);
          user = profile;
          role = UserRole.guest;
        }
      } catch (_) {
        role = UserRole.guest;
      }
    }

    _ref.read(currentUserProvider.notifier).state = user;
    _ref.read(authRoleProvider.notifier).state = role;
    return user;
  }

  Future<AuthResult> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    _ref.read(authErrorProvider.notifier).state = null;
    final result = await _auth.signInWithEmail(email, password);
    if (result.success) {
      final user = await _hydrateProfile(result);
      state = AsyncValue.data(user);
      return AuthResult.ok(user: user, role: _ref.read(authRoleProvider));
    }
    _ref.read(authErrorProvider.notifier).state = result.errorMessage;
    state = AsyncValue.error(
      result.errorMessage ?? 'Login failed',
      StackTrace.current,
    );
    return result;
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    _ref.read(authErrorProvider.notifier).state = null;
    final result = await _auth.registerWithEmail(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );
    if (result.success) {
      final guest = result.user?.copyWith(role: UserRole.guest);
      if (guest != null && AppConfig.useFirebaseDataEffective) {
        try {
          await _ref.read(userRepositoryProvider).create(guest);
        } catch (_) {}
      }
      _ref.read(currentUserProvider.notifier).state = guest;
      _ref.read(authRoleProvider.notifier).state = UserRole.guest;
      state = AsyncValue.data(guest);
      return AuthResult.ok(user: guest, role: UserRole.guest);
    }
    _ref.read(authErrorProvider.notifier).state = result.errorMessage;
    state = AsyncValue.error(
      result.errorMessage ?? 'Registration failed',
      StackTrace.current,
    );
    return result;
  }

  Future<AuthResult> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await _auth.signInWithGoogle();
    if (result.success) {
      final user = await _hydrateProfile(result);
      state = AsyncValue.data(user);
      return AuthResult.ok(user: user, role: _ref.read(authRoleProvider));
    }
    _ref.read(authErrorProvider.notifier).state = result.errorMessage;
    state = AsyncValue.error(
      result.errorMessage ?? 'Google sign-in failed',
      StackTrace.current,
    );
    return result;
  }

  Future<AuthResult> resetPassword(String email) =>
      _auth.sendPasswordReset(email);

  Future<void> signOut() async {
    await _auth.signOut();
    _ref.read(currentUserProvider.notifier).state = null;
    _ref.read(authRoleProvider.notifier).state = null;
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  return AuthController(ref);
});

final isStaffProvider = Provider<bool>((ref) {
  final role = ref.watch(authRoleProvider);
  return role != null && role != UserRole.guest;
});

final canManageOperationsProvider = Provider<bool>((ref) {
  final role = ref.watch(authRoleProvider);
  return role == UserRole.admin ||
      role == UserRole.manager ||
      role == UserRole.receptionist;
});
