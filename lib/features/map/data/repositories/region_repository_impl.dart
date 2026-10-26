import 'package:latlong2/latlong.dart';

import '../../domain/entities/region_level.dart';
import '../../domain/repositories/region_repository.dart';
import '../datasources/region_data_source.dart';

class const RegionRepositoryImpl(final RegionDataSource _dataSource)
    implements RegionRepository {
  @override
  Future<String> getRegionName(LatLng position, RegionLevel level) =>
      _dataSource.getRegionName(position, level);
}
