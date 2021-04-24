import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:resocoder_clean_arch/core/error/exceptions.dart';
import 'package:resocoder_clean_arch/core/error/failures.dart';
import 'package:resocoder_clean_arch/core/platform/network_info.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDatasource extends Mock
    implements NumberTriviaRemoteDatasource {}

class MockLocalDatasource extends Mock implements NumberTriviaLocalDatasource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDatasource mockRemoteDatasource;
  MockLocalDatasource mockLocalDatasource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDatasource = MockRemoteDatasource();
    mockLocalDatasource = MockLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDatasource: mockRemoteDatasource,
      localDatasource: mockLocalDatasource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(number: tNumber, text: 'test');
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test('should check if the device is online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      repository.getConcreteNumberTrivia(tNumber);

      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
          'should return remote data when the call to remote datasource is succesfull',
          () async {
        when(mockRemoteDatasource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);

        final result = await repository.getConcreteNumberTrivia(tNumber);

        verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
        expect(result, Right(tNumberTrivia));
      });

      test(
          'should cache the data locally when the call to remote datasource is succesfull',
          () async {
        when(mockRemoteDatasource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);

        await repository.getConcreteNumberTrivia(tNumber);

        verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDatasource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test(
          'should return a server failure when the call to remote datasource is unsuccesfull',
          () async {
        when(mockRemoteDatasource.getConcreteNumberTrivia(any))
            .thenThrow(ServerException());

        final result = await repository.getConcreteNumberTrivia(tNumber);

        verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDatasource);
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return locally cached data when the cached data is present',
          () async {
        when(mockLocalDatasource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        final result = await repository.getConcreteNumberTrivia(tNumber);

        verifyZeroInteractions(mockRemoteDatasource);
        verify(mockLocalDatasource.getLastNumberTrivia());
        expect(result, Right(tNumberTrivia));
      });

      test('should return cache failure when there is no cached data present',
          () async {
        when(mockLocalDatasource.getLastNumberTrivia())
            .thenThrow(CacheException());

        final result = await repository.getConcreteNumberTrivia(tNumber);

        verifyZeroInteractions(mockRemoteDatasource);
        verify(mockLocalDatasource.getLastNumberTrivia());
        expect(result, Left(CacheFailure()));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(number: 123, text: 'test');
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test('should check if the device is online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      repository.getRandomNumberTrivia();

      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
          'should return remote data when the call to remote datasource is succesfull',
          () async {
        when(mockRemoteDatasource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        final result = await repository.getRandomNumberTrivia();

        verify(mockRemoteDatasource.getRandomNumberTrivia());
        expect(result, Right(tNumberTrivia));
      });

      test(
          'should cache the data locally when the call to remote datasource is succesfull',
          () async {
        when(mockRemoteDatasource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        await repository.getRandomNumberTrivia();

        verify(mockRemoteDatasource.getRandomNumberTrivia());
        verify(mockLocalDatasource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test(
          'should return a server failure when the call to remote datasource is unsuccesfull',
          () async {
        when(mockRemoteDatasource.getRandomNumberTrivia())
            .thenThrow(ServerException());

        final result = await repository.getRandomNumberTrivia();

        verify(mockRemoteDatasource.getRandomNumberTrivia());
        verifyZeroInteractions(mockLocalDatasource);
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return locally cached data when the cached data is present',
          () async {
        when(mockLocalDatasource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        final result = await repository.getRandomNumberTrivia();

        verifyZeroInteractions(mockRemoteDatasource);
        verify(mockLocalDatasource.getLastNumberTrivia());
        expect(result, Right(tNumberTrivia));
      });

      test('should return cache failure when there is no cached data present',
          () async {
        when(mockLocalDatasource.getLastNumberTrivia())
            .thenThrow(CacheException());

        final result = await repository.getRandomNumberTrivia();

        verifyZeroInteractions(mockRemoteDatasource);
        verify(mockLocalDatasource.getLastNumberTrivia());
        expect(result, Left(CacheFailure()));
      });
    });
  });
}
