import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Auth calls. Throws `AuthException` when a call is rejected.
class const SupabaseAuthDataSource(final SupabaseClient _client) {
  // Marks the user as past the pseudo step; the pseudo itself lives in the
  // `profiles` table, created by a trigger on sign-up with a generated name.
  static const onboardedKey = 'onboarded';

  bool get isSignedIn => _client.auth.currentSession != null;

  bool get hasProfile =>
      _client.auth.currentUser?.userMetadata?[onboardedKey] == true;

  Future<void> sendCode(String email) =>
      _client.auth.signInWithOtp(email: email);

  Future<void> verifyCode(String email, String code) =>
      _client.auth.verifyOTP(email: email, token: code, type: OtpType.email);

  /// Throws `PostgrestException` (code 23505) when the pseudo is taken.
  Future<void> saveProfile(
    String pseudo, {
    required bool trainingConsent,
  }) async {
    await _client
        .from('profiles')
        .update({
          'username': pseudo,
          // shortcut: device clock, move to a server default if it matters.
          if (trainingConsent)
            'training_consent_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', _client.auth.currentUser!.id);
    await _client.auth.updateUser(UserAttributes(data: {onboardedKey: true}));
  }
}
