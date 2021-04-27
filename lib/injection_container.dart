import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/datasources/datasources.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/usecases/usecases.dart';
import 'package:resocoder_clean_arch/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'core/network/network_info.dart';
import 'core/util/input_converter.dart';
import 'features/number_trivia/domain/repositories/number_trivia_repository.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  //! Features - NumberTrivia
  // Bloc
  getIt.registerFactory(
    () => NumberTriviaBloc(
      getConcreteNumberTrivia: getIt(),
      getRandomNumberTrivia: getIt(),
      inputConverter: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(
      () => GetConcreteNumberTrivia(repository: getIt()));
  getIt.registerLazySingleton(() => GetRandomNumberTrivia(repository: getIt()));

  //repository
  getIt.registerLazySingleton<NumberTriviaRepository>(
    () => NumberTriviaRepositoryImpl(
      remoteDatasource: getIt(),
      localDatasource: getIt(),
      networkInfo: getIt(),
    ),
  );

  //Datasources
  getIt.registerLazySingleton<NumberTriviaRemoteDatasource>(
    () => NumberTriviaRemoteDatasourceImpl(
      client: getIt(),
    ),
  );

  getIt.registerLazySingleton<NumberTriviaLocalDatasource>(
    () => NumberTriviaLocalDatasourceImpl(
      sharedPreferences: getIt(),
    ),
  );

  //! Core
  getIt.registerLazySingleton(() => InputConverter());
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt()),
  );

  //! External
  getIt.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker());
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
}
