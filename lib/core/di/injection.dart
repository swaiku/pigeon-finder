import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/datasources/auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/onboarding_cubit.dart';
import '../../features/detection/data/datasources/release_store.dart';
import '../../features/detection/data/repositories/litert_detection_repository.dart';
import '../../features/detection/domain/repositories/detection_repository.dart';
import '../../features/map/data/datasources/geocoding_region_data_source.dart';
import '../../features/map/data/datasources/geolocator_location_data_source.dart';
import '../../features/map/data/datasources/location_data_source.dart';
import '../../features/map/data/datasources/posts_remote_data_source.dart';
import '../../features/map/data/datasources/region_data_source.dart';
import '../../features/map/data/repositories/location_repository_impl.dart';
import '../../features/map/data/repositories/region_repository_impl.dart';
import '../../features/map/data/repositories/supabase_posts_repository.dart';
import '../../features/map/domain/repositories/location_repository.dart';
import '../../features/map/domain/repositories/posts_repository.dart';
import '../../features/map/domain/repositories/region_repository.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';
import '../../features/pigeondex/presentation/bloc/pigeondex_cubit.dart';
import '../../features/post/data/datasources/post_remote_data_source.dart';
import '../../features/post/data/repositories/post_repository_impl.dart';
import '../../features/post/domain/repositories/post_repository.dart';
import '../../features/post/presentation/bloc/post_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/supabase_profile_repository.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_cubit.dart';
import '../../features/ranking/data/datasources/ranking_remote_data_source.dart';
import '../../features/ranking/data/repositories/supabase_ranking_repository.dart';
import '../../features/ranking/domain/repositories/ranking_repository.dart';
import '../../features/ranking/presentation/bloc/ranking_cubit.dart';
import '../config/env.dart';
import '../events/posts_changes.dart';

final sl = GetIt.instance;

/// Registers all app-wide and feature-level dependencies.
///
/// Feature dependencies should be registered in the following order:
/// datasource -> repository -> use cases -> bloc.
Future<void> initDependencies() async {
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton(PostsChanges.new);

  // --- auth ---
  sl.registerLazySingleton(() => SupabaseAuthDataSource(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerFactory(() => OnboardingCubit(auth: sl(), location: sl()));

  // --- map ---
  sl.registerLazySingleton<RegionDataSource>(GeocodingRegionDataSource.new);
  sl.registerLazySingleton<LocationDataSource>(
    () => const GeolocatorLocationDataSource(),
  );
  sl.registerLazySingleton<PostsRemoteDataSource>(
    () => SupabasePostsDataSource(sl()),
  );
  sl.registerLazySingleton<PostsRepository>(
    () => SupabasePostsRepository(sl()),
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<RegionRepository>(() => RegionRepositoryImpl(sl()));
  sl.registerFactory(
    () => MapBloc(posts: sl(), location: sl(), regions: sl(), changes: sl()),
  );

  // --- post ---
  sl.registerLazySingleton(() => SupabasePostDataSource(sl()));
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerFactory(
    () => PostCubit(posts: sl(), location: sl(), detection: sl()),
  );

  // --- detection ---
  sl.registerLazySingleton<DetectionRepository>(
    () => LiteRtDetectionRepository(
      releases: ReleaseStore(
        apiUrl: Env.piafApiUrl,
        appVersion: () async => (await PackageInfo.fromPlatform()).version,
        directory: () async =>
            Directory('${(await getApplicationSupportDirectory()).path}/models')
              ..createSync(recursive: true),
      ),
    ),
  );

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
  // Reads through the map's PostsRepository to share its signed-URL cache.
  sl.registerFactory(() => PigeondexCubit(posts: sl(), changes: sl()));

  // --- ranking ---
  sl.registerLazySingleton<RankingRemoteDataSource>(
    () => SupabaseRankingDataSource(sl()),
  );
  sl.registerLazySingleton<RankingRepository>(
    () => SupabaseRankingRepository(sl()),
  );
  sl.registerFactory(
    () => RankingCubit(
      ranking: sl(),
      location: sl(),
      regions: sl(),
      changes: sl(),
    ),
  );

  // --- profile ---
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => SupabaseProfileDataSource(sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => SupabaseProfileRepository(sl()),
  );
  sl.registerFactory(
    () => ProfileCubit(profile: sl(), posts: sl(), changes: sl()),
  );
}
