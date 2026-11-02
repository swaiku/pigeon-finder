/// Passwordless sign-in: a one-time code sent by email. Implementations throw
/// an `AuthFailure` when a call is rejected.
abstract interface class AuthRepository {
  bool get isSignedIn;

  /// Whether the user already picked a pseudo.
  bool get hasProfile;

  /// Emails a 6-digit code, creating the account on first use.
  Future<void> sendCode(String email);

  Future<void> verifyCode({required String email, required String code});

  /// [trainingConsent]: the user lets their photos train the AI.
  Future<void> saveProfile({
    required String pseudo,
    required bool trainingConsent,
  });
}
