import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/datasources/auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/onboarding_cubit.dart';
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
import '../../features/post/data/datasources/post_remote_data_source.dart';
import '../../features/post/data/repositories/post_repository_impl.dart';
import '../../features/post/domain/repositories/post_repository.dart';
import '../../features/post/presentation/bloc/post_cubit.dart';
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
  sl.registerFactory(() => PostCubit(posts: sl(), location: sl()));

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
