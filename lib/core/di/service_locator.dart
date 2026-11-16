import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../../features/products/data/datasources/product_local_datasource.dart';
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';

import '../../features/cart/presentation/bloc/cart_bloc.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/notifications/services/fcm_service.dart';
import '../../features/settings/presentation/bloc/theme_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // 1. External & Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(client: sl<http.Client>()));

  // 2. Notifications & Firebase Services
  final fcmService = FCMNotificationService();
  await fcmService.initialize();
  sl.registerLazySingleton<FCMNotificationService>(() => fcmService);

  // 3. Data Sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // 4. Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl<ProductRemoteDataSource>(),
      localDataSource: sl<ProductLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // 5. Use Cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(() => GetProductsByCategoryUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl<ProductRepository>()));

  // 6. Blocs (Factory registrations so fresh instances can be supplied if needed)
  sl.registerFactory(
    () => ProductBloc(
      getProductsUseCase: sl<GetProductsUseCase>(),
      getCategoriesUseCase: sl<GetCategoriesUseCase>(),
    ),
  );
  sl.registerLazySingleton(() => CartBloc());
  sl.registerFactory(() => AuthBloc(authRepository: sl<AuthRepository>()));
  sl.registerLazySingleton(() => ThemeBloc(sharedPreferences: sl<SharedPreferences>()));
}
