import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures.
abstract class const Failure(final String message)
    extends Equatable
    implements Exception {
  @override
  List<Object?> get props => [message];
}

class const NetworkFailure(super.message) extends Failure;

class const ServerFailure(super.message) extends Failure;

class const AuthFailure(super.message) extends Failure;

class const PermissionFailure(super.message) extends Failure;

class const LocationFailure(super.message) extends Failure;
