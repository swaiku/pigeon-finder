import 'package:flutter_test/flutter_test.dart';
import 'package:pigeon_finder/features/auth/presentation/bloc/onboarding_cubit.dart';
import 'package:pigeon_finder/features/map/data/repositories/location_repository_impl.dart';

import '../../support/fake_auth_repository.dart';
import '../../support/fake_location_data_source.dart';

void main() {
  late FakeAuthRepository auth;

  OnboardingCubit build() => OnboardingCubit(
    auth: auth,
    location: const LocationRepositoryImpl(FakeLocationDataSource()),
  );

  setUp(() => auth = FakeAuthRepository(isSignedIn: false, hasProfile: false));

  test('sendCode remembers the email', () async {
    final cubit = build();
    expect(await cubit.sendCode('a@b.fr'), isTrue);
    expect(cubit.state.email, 'a@b.fr');
  });

  test(
    'verifyCode fails on a wrong code and succeeds on the right one',
    () async {
      final cubit = build();
      await cubit.sendCode('a@b.fr');

      expect(await cubit.verifyCode('000000'), isFalse);
      expect(cubit.state.status, OnboardingStatus.failure);

      expect(await cubit.verifyCode(FakeAuthRepository.validCode), isTrue);
      expect(cubit.state.status, OnboardingStatus.idle);
      expect(auth.isSignedIn, isTrue);
    },
  );

  test('saveProfile passes the training consent through', () async {
    final cubit = build();
    expect(
      await cubit.saveProfile(pseudo: 'coo', trainingConsent: true),
      isTrue,
    );
    expect(auth.savedPseudo, 'coo');
    expect(auth.savedConsent, isTrue);
    expect(cubit.hasProfile, isTrue);
  });

  test('saveProfile reports a pseudo that is already taken', () async {
    final cubit = build();
    expect(
      await cubit.saveProfile(
        pseudo: FakeAuthRepository.takenPseudo,
        trainingConsent: false,
      ),
      isFalse,
    );
    expect(cubit.state.status, OnboardingStatus.usernameTaken);
  });

  test(
    'sendCode starts a cooldown, or reports the one Supabase imposes',
    () async {
      final cubit = build();
      await cubit.sendCode('a@b.fr');
      expect(cubit.state.retryUntil!.isAfter(DateTime.now()), isTrue);

      auth.rateLimited = true;
      expect(await cubit.sendCode('a@b.fr'), isFalse);
      expect(cubit.state.status, OnboardingStatus.rateLimited);
      final left = cubit.state.retryUntil!.difference(DateTime.now());
      expect(left, lessThanOrEqualTo(const Duration(seconds: 13)));
    },
  );
}
