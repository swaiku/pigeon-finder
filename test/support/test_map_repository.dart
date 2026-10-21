import 'package:pigeon_finder/features/map/data/datasources/location_data_source.dart';
import 'package:pigeon_finder/features/map/data/datasources/region_data_source.dart';
import 'package:pigeon_finder/features/map/data/repositories/fake_map_repository.dart';

import 'fake_location_data_source.dart';
import 'fake_region_data_source.dart';

/// A [FakeMapRepository] wired to offline data sources; override the one a
/// test cares about.
FakeMapRepository testMapRepository({
  RegionDataSource regions = const FakeRegionDataSource(),
  LocationDataSource location = const FakeLocationDataSource(),
}) => FakeMapRepository(regions: regions, location: location);
