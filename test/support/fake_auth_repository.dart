import 'package:pigeon_finder/core/error/failures.dart';
import 'package:pigeon_finder/features/auth/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.isSignedIn = true, this.hasProfile = true});

  @override
  bool isSignedIn;

  @override
  bool hasProfile;

  /// Code [verifyCode] accepts.
  static const validCode = '123456';

  /// Pseudo [saveProfile] refuses as already taken.
  static const takenPseudo = 'taken';

  bool rateLimited = false;

  String? savedPseudo;
  bool? savedConsent;

  @override
  Future<void> sendCode(String email) async {
    if (rateLimited) {
      throw const RateLimitFailure('slow down', Duration(seconds: 13));
    }
  }

  @override
  Future<void> verifyCode({required String email, required String code}) async {
    if (code != validCode) throw const AuthFailure('bad code');
    isSignedIn = true;
  }

  @override
  Future<void> saveProfile({
    required String pseudo,
    required bool trainingConsent,
  }) async {
    if (pseudo == takenPseudo) throw const UsernameTakenFailure('taken');
    savedPseudo = pseudo;
    savedConsent = trainingConsent;
    hasProfile = true;
  }
}
