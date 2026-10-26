import 'package:latlong2/latlong.dart';

import '../../domain/entities/region_level.dart';
import '../../domain/repositories/region_repository.dart';
import '../datasources/region_data_source.dart';

class RegionRepositoryImpl implements RegionRepository {
  const RegionRepositoryImpl(this._dataSource);

  final RegionDataSource _dataSource;

  @override
  Future<String> getRegionName(LatLng position, RegionLevel level) =>
      _dataSource.getRegionName(position, level);
}
