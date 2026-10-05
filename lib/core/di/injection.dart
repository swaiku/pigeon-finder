import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  // sl.registerLazySingleton<MapRemoteDataSource>(
  //   () => MapRemoteDataSourceImpl(sl()),
  // );
  // sl.registerLazySingleton<MapRepository>(
  //   () => MapRepositoryImpl(sl()),
  // );
  // sl.registerLazySingleton(() => GetNearbyPostsUseCase(sl()));
  // sl.registerFactory(() => MapCubit(sl()));

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
