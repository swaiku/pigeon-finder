import 'package:latlong2/latlong.dart';

import '../../domain/repositories/location_repository.dart';
import '../datasources/location_data_source.dart';

class const LocationRepositoryImpl(final LocationDataSource _dataSource)
    implements LocationRepository {
  @override
  Future<LatLng> getUserPosition() => _dataSource.getCurrentPosition();

  @override
  Stream<LatLng> watchUserPosition() => _dataSource.watchPosition();
}
