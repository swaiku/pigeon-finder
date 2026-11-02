import 'package:pigeon_finder/features/map/data/datasources/location_data_source.dart';
import 'package:pigeon_finder/features/map/data/datasources/region_data_source.dart';
import 'package:pigeon_finder/features/map/data/repositories/fake_posts_repository.dart';
import 'package:pigeon_finder/features/map/data/repositories/location_repository_impl.dart';
import 'package:pigeon_finder/features/map/data/repositories/region_repository_impl.dart';
import 'package:pigeon_finder/features/map/domain/repositories/posts_repository.dart';
import 'package:pigeon_finder/features/map/presentation/bloc/map_bloc.dart';

import 'fake_location_data_source.dart';
import 'fake_region_data_source.dart';

/// A [MapBloc] wired to offline data; override the part a test cares about.
MapBloc testMapBloc({
  PostsRepository? posts,
  RegionDataSource regions = const FakeRegionDataSource(),
  LocationDataSource location = const FakeLocationDataSource(),
}) => MapBloc(
  posts: posts ?? FakePostsRepository(),
  location: LocationRepositoryImpl(location),
  regions: RegionRepositoryImpl(regions),
);
