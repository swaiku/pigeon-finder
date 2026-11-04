import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// A photo about to be published.
class const NewPost({
  /// Path of the JPEG on the device.
  required final String photoPath,
  required final LatLng position,
  final String? description,

  /// Always 1 until the on-device AI counts the pigeons.
  final int pigeonCount = 1,
}) extends Equatable {
  /// Same limit as the `posts.description` check constraint.
  static const maxDescriptionLength = 280;

  @override
  List<Object?> get props => [photoPath, position, description, pigeonCount];
}
