import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/datasources/datasources.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/usecases/usecases.dart';
import 'package:resocoder_clean_arch/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'core/network/network_info.dart';
import 'core/util/input_converter.dart';
import 'features/number_trivia/domain/repositories/number_trivia_repository.dart';

final sl = GetIt.instance;

init() async {
  //! Features - NumberTrivia
  // Bloc
  sl.registerFactory(
    () => NumberTriviaBloc(
      concrete: sl(),
      random: sl(),
      inputConverter: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetConcreteNumberTrivia(repository: sl()));
  sl.registerLazySingleton(() => GetRandomNumberTrivia(repository: sl()));

  //repository
  sl.registerLazySingleton<NumberTriviaRepository>(
    () => NumberTriviaRepositoryImpl(
      remoteDatasource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  //Datasources
  sl.registerLazySingleton<NumberTriviaRemoteDatasource>(
    () => NumberTriviaRemoteDatasourceImpl(
      client: sl(),
    ),
  );

  sl.registerLazySingleton<NumberTriviaLocalDatasource>(
    () => NumberTriviaLocalDatasourceImpl(
      sharedPreferences: sl(),
    ),
  );

  //! Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => DataConnectionChecker());
}
