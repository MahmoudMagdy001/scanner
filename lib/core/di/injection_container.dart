import 'package:get_it/get_it.dart';

import '../dioHelper/dio_helper.dart';
// Card Type Feature
import '../../features/card_type/data/datasources/card_type_remote_datasource.dart';
import '../../features/card_type/data/repositories/card_type_repository_impl.dart';
import '../../features/card_type/domain/repositories/card_type_repository.dart';
import '../../features/card_type/domain/usecases/clear_data_usecase.dart';
import '../../features/card_type/domain/usecases/get_categories_usecase.dart';
import '../../features/card_type/presentation/cubit/card_type_cubit.dart';
// Extract Image Feature
import '../../features/extract_image/data/datasources/extract_image_remote_datasource.dart';
import '../../features/extract_image/data/repositories/extract_image_repository_impl.dart';
import '../../features/extract_image/domain/repositories/extract_image_repository.dart';
import '../../features/extract_image/domain/usecases/get_history_count_usecase.dart';
import '../../features/extract_image/domain/usecases/process_image_usecase.dart';
import '../../features/extract_image/domain/usecases/submit_scan_usecase.dart';
import '../../features/extract_image/presentation/cubit/extract_image_cubit.dart';
// Login Feature
import '../../features/login/data/datasources/login_remote_datasource.dart';
import '../../features/login/data/repositories/login_repository_impl.dart';
import '../../features/login/domain/repositories/login_repository.dart';
import '../../features/login/domain/usecases/login_usecase.dart';
import '../../features/login/presentation/cubit/login_cubit.dart';
// Saved Data Feature
import '../../features/saved_data/data/datasources/saved_data_remote_datasource.dart';
import '../../features/saved_data/data/repositories/saved_data_repository_impl.dart';
import '../../features/saved_data/domain/repositories/saved_data_repository.dart';
import '../../features/saved_data/domain/usecases/get_saved_scans_usecase.dart';
import '../../features/saved_data/presentation/cubit/saved_data_cubit.dart';
// Settings Feature
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings_usecase.dart';
import '../../features/settings/domain/usecases/get_wifi_ip_usecase.dart';
import '../../features/settings/domain/usecases/save_settings_usecase.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';

/// Global service locator instance
final getIt = GetIt.instance;

/// Initializes all dependencies
/// Call this in main.dart before runApp
Future<void> initDependencies() async {
  // Initialize core dependencies
  _initCore();

  // Initialize feature dependencies
  _initExtractImageFeature();
  _initLoginFeature();
  _initCardTypeFeature();
  _initSavedDataFeature();
  _initSettingsFeature();
}

/// Initialize core layer dependencies
void _initCore() {
  // External
  getIt.registerLazySingleton(() => DioHelper);
}

/// Initialize extract_image feature dependencies
void _initExtractImageFeature() {
  // Data Sources
  getIt
    ..registerLazySingleton<ExtractImageRemoteDataSource>(
      ExtractImageRemoteDataSourceImpl.new,
    )
    // Repositories
    ..registerLazySingleton<ExtractImageRepository>(
      () => ExtractImageRepositoryImpl(remoteDataSource: getIt()),
    )
    // Use Cases
    ..registerLazySingleton(() => ProcessImageUseCase(repository: getIt()))
    ..registerLazySingleton(() => SubmitScanUseCase(repository: getIt()))
    ..registerLazySingleton(() => GetHistoryCountUseCase(repository: getIt()))
    // Cubit - Factory because each screen needs its own instance
    ..registerFactory(
      () => ExtractImageCubit(
        processImageUseCase: getIt(),
        submitScanUseCase: getIt(),
        getHistoryCountUseCase: getIt(),
      ),
    );
}

/// Initialize login feature dependencies
void _initLoginFeature() {
  // Data Sources
  getIt
    ..registerLazySingleton<LoginRemoteDataSource>(
      LoginRemoteDataSourceImpl.new,
    )
    // Repositories
    ..registerLazySingleton<LoginRepository>(
      () => LoginRepositoryImpl(remoteDataSource: getIt()),
    )
    // Use Cases
    ..registerLazySingleton(() => LoginUseCase(repository: getIt()))
    // Cubit - Factory because each screen needs its own instance
    ..registerFactory(() => LoginCubit(loginUseCase: getIt()));
}

/// Initialize card_type feature dependencies
void _initCardTypeFeature() {
  // Data Sources
  getIt
    ..registerLazySingleton<CardTypeRemoteDataSource>(
      CardTypeRemoteDataSourceImpl.new,
    )
    // Repositories
    ..registerLazySingleton<CardTypeRepository>(
      () => CardTypeRepositoryImpl(remoteDataSource: getIt()),
    )
    // Use Cases
    ..registerLazySingleton(() => GetCategoriesUseCase(repository: getIt()))
    ..registerLazySingleton(() => ClearDataUseCase(repository: getIt()))
    // Cubit - Factory because each screen needs its own instance
    ..registerFactory(
      () => CardTypeCubit(
        getCategoriesUseCase: getIt(),
        clearDataUseCase: getIt(),
      ),
    );
}

/// Initialize saved_data feature dependencies
void _initSavedDataFeature() {
  // Data Sources
  getIt
    ..registerLazySingleton<SavedDataRemoteDataSource>(
      SavedDataRemoteDataSourceImpl.new,
    )
    // Repositories
    ..registerLazySingleton<SavedDataRepository>(
      () => SavedDataRepositoryImpl(remoteDataSource: getIt()),
    )
    // Use Cases
    ..registerLazySingleton(() => GetSavedScansUseCase(repository: getIt()))
    // Cubit - Factory because each screen needs its own instance
    ..registerFactory(() => SavedDataCubit(getSavedScansUseCase: getIt()));
}

/// Initialize settings feature dependencies
void _initSettingsFeature() {
  // Data Sources
  getIt
    ..registerLazySingleton<SettingsLocalDataSource>(
      SettingsLocalDataSourceImpl.new,
    )
    // Repositories
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(localDataSource: getIt()),
    )
    // Use Cases
    ..registerLazySingleton(() => GetSettingsUseCase(repository: getIt()))
    ..registerLazySingleton(() => SaveSettingsUseCase(repository: getIt()))
    ..registerLazySingleton(() => GetWifiIpUseCase(repository: getIt()))
    // Cubit - Factory because each screen needs its own instance
    ..registerFactory(
      () => SettingsCubit(
        getSettingsUseCase: getIt(),
        saveSettingsUseCase: getIt(),
        getWifiIpUseCase: getIt(),
      ),
    );
}
