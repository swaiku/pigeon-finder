import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/map/data/datasources/geocoding_region_data_source.dart';
import '../../features/map/data/datasources/geolocator_location_data_source.dart';
import '../../features/map/data/datasources/location_data_source.dart';
import '../../features/map/data/datasources/region_data_source.dart';
import '../../features/map/data/repositories/fake_posts_repository.dart';
import '../../features/map/data/repositories/location_repository_impl.dart';
import '../../features/map/data/repositories/region_repository_impl.dart';
import '../../features/map/domain/repositories/location_repository.dart';
import '../../features/map/domain/repositories/posts_repository.dart';
import '../../features/map/domain/repositories/region_repository.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';

final sl = GetIt.instance;

/// Registers all app-wide and feature-level dependencies.
///
/// Feature dependencies should be registered in the following order:
/// datasource -> repository -> use cases -> bloc.
Future<void> initDependencies() async {
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // --- auth ---
  // sl.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(sl()),
  // );
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(sl()),
  // );
  // sl.registerLazySingleton(() => SignInUseCase(sl()));
  // sl.registerFactory(() => AuthCubit(sl()));

  // --- map ---
  // TODO(map): replace the fake with a Supabase-backed PostsRepository once
  // its data source exists.
  sl.registerLazySingleton<RegionDataSource>(GeocodingRegionDataSource.new);
  sl.registerLazySingleton<LocationDataSource>(
    () => const GeolocatorLocationDataSource(),
  );
  sl.registerLazySingleton<PostsRepository>(FakePostsRepository.new);
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<RegionRepository>(() => RegionRepositoryImpl(sl()));
  sl.registerFactory(() => MapBloc(posts: sl(), location: sl(), regions: sl()));

  // --- post ---
  // sl.registerLazySingleton<PostRemoteDataSource>(
  //   () => PostRemoteDataSourceImpl(sl()),
  // );
  // sl.registerLazySingleton<PostRepository>(
  //   () => PostRepositoryImpl(sl()),
  // );
  // sl.registerLazySingleton(() => CreatePostUseCase(sl()));
  // sl.registerFactory(() => PostCubit(sl()));

  // --- post_detail ---
  // sl.registerLazySingleton<PostDetailRemoteDataSource>(
  //   () => PostDetailRemoteDataSourceImpl(sl()),
  // );
  // sl.registerLazySingleton<PostDetailRepository>(
  //   () => PostDetailRepositoryImpl(sl()),
  // );
  // sl.registerLazySingleton(() => LikePostUseCase(sl()));
  // sl.registerFactory(() => PostDetailCubit(sl()));

  // --- pigeondex ---
  // sl.registerLazySingleton<PigeondexRemoteDataSource>(
  //   () => PigeondexRemoteDataSourceImpl(sl()),
  // );
  // sl.registerLazySingleton<PigeondexRepository>(
  //   () => PigeondexRepositoryImpl(sl()),
  // );
  // sl.registerLazySingleton(() => GetPigeondexUseCase(sl()));
  // sl.registerFactory(() => PigeondexCubit(sl()));

  // --- profile ---
  // sl.registerLazySingleton<ProfileRemoteDataSource>(
  //   () => ProfileRemoteDataSourceImpl(sl()),
  // );
  // sl.registerLazySingleton<ProfileRepository>(
  //   () => ProfileRepositoryImpl(sl()),
  // );
  // sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  // sl.registerFactory(() => ProfileCubit(sl()));
}
