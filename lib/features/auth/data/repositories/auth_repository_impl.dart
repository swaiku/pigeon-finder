import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';

class const AuthRepositoryImpl(final SupabaseAuthDataSource _dataSource)
    implements AuthRepository {
  @override
  bool get isSignedIn => _dataSource.isSignedIn;

  @override
  bool get hasProfile => _dataSource.hasProfile;

  @override
  Future<void> sendCode(String email) =>
      _guard(() => _dataSource.sendCode(email));

  @override
  Future<void> verifyCode({required String email, required String code}) =>
      _guard(() => _dataSource.verifyCode(email, code));

  @override
  Future<void> saveProfile({
    required String pseudo,
    required bool trainingConsent,
  }) => _guard(
    () => _dataSource.saveProfile(pseudo, trainingConsent: trainingConsent),
  );

  /// The message reads "...you can only request this after 13 seconds."
  Duration _retryAfter(String message) {
    final seconds = RegExp(r'(\d+) seconds').firstMatch(message)?.group(1);
    return Duration(seconds: int.tryParse(seconds ?? '') ?? 60);
  }

  Future<void> _guard(Future<void> Function() call) async {
    try {
      await call();
    } on AuthException catch (e) {
      if (e.statusCode == '429') {
        throw RateLimitFailure(e.message, _retryAfter(e.message));
      }
      throw AuthFailure(e.message);
    } on PostgrestException catch (e) {
      // unique_violation on the case-insensitive username index.
      if (e.code == '23505') throw UsernameTakenFailure(e.message);
      throw AuthFailure(e.message);
    }
  }
}
