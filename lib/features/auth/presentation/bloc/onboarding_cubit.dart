import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../map/domain/repositories/location_repository.dart';
import '../../domain/repositories/auth_repository.dart';

part 'onboarding_state.dart';

/// Sign-up / login flow: email, code, pseudo, location. The page navigates
/// on the `true` returned by each action; a failure shows up in the state.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({required this._auth, required this._location})
    : super(const OnboardingState());

  /// Supabase's minimum delay between two codes for the same address.
  static const _resendCooldown = Duration(seconds: 60);

  final AuthRepository _auth;
  final LocationRepository _location;

  /// Also used to resend the code.
  Future<bool> sendCode(String email) =>
      _run(() => _auth.sendCode(email), email: email, startCooldown: true);

  Future<bool> verifyCode(String code) =>
      _run(() => _auth.verifyCode(email: state.email, code: code));

  Future<bool> saveProfile({
    required String pseudo,
    required bool trainingConsent,
  }) => _run(
    () => _auth.saveProfile(pseudo: pseudo, trainingConsent: trainingConsent),
  );

  /// Asks for the location permission; the answer does not matter here, the
  /// map falls back on a default view when it is refused.
  Future<void> requestLocation() => _location.requestPermission();

  /// Whether a returning user can skip the pseudo step.
  bool get hasProfile => _auth.hasProfile;

  Future<bool> _run(
    Future<void> Function() call, {
    String? email,
    bool startCooldown = false,
  }) async {
    emit(state.copyWith(email: email, status: OnboardingStatus.loading));
    try {
      await call();
      emit(
        state.copyWith(
          status: OnboardingStatus.idle,
          retryUntil: startCooldown
              ? DateTime.now().add(_resendCooldown)
              : null,
        ),
      );
      return true;
    } on RateLimitFailure catch (e) {
      emit(
        state.copyWith(
          status: OnboardingStatus.rateLimited,
          retryUntil: DateTime.now().add(e.retryAfter),
        ),
      );
      return false;
    } on UsernameTakenFailure {
      emit(state.copyWith(status: OnboardingStatus.usernameTaken));
      return false;
    } on Failure catch (e) {
      debugPrint('Onboarding failed: ${e.message}');
      emit(state.copyWith(status: OnboardingStatus.failure));
      return false;
    }
  }
}
