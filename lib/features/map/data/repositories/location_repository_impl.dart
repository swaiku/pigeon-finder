import 'package:latlong2/latlong.dart';

import '../../domain/repositories/location_repository.dart';
import '../datasources/location_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._dataSource);

  final LocationDataSource _dataSource;

  @override
  Future<LatLng> getUserPosition() => _dataSource.getCurrentPosition();

  @override
  Stream<LatLng> watchUserPosition() => _dataSource.watchPosition();
}
