part of 'onboarding_cubit.dart';

enum OnboardingStatus { idle, loading, failure, usernameTaken, rateLimited }

final class const OnboardingState({
  final String email = '',
  final OnboardingStatus status = OnboardingStatus.idle,
  final DateTime? retryUntil,
}) extends Equatable {
  bool get isLoading => status == OnboardingStatus.loading;

  OnboardingState copyWith({
    String? email,
    OnboardingStatus? status,
    DateTime? retryUntil,
  }) => OnboardingState(
    email: email ?? this.email,
    status: status ?? this.status,
    retryUntil: retryUntil ?? this.retryUntil,
  );

  @override
  List<Object?> get props => [email, status, retryUntil];
}
