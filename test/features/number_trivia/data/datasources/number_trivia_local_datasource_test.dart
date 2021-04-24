import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:resocoder_clean_arch/core/error/exceptions.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/datasources/datasources.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDatasourceImpl datasource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    datasource = NumberTriviaLocalDatasourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    test(
        'should return NumberTrivia from SharedPreferences when there is one in the cache',
        () async {
      when(mockSharedPreferences.getString(any))
          .thenReturn(fixture('trivia_cached.json'));

      final result = await datasource.getLastNumberTrivia();

      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, tNumberTriviaModel);
    });

    test('should throw a cache exception when there is not a cached value',
        () async {
      when(mockSharedPreferences.getString(any)).thenReturn(null);

      final call = datasource.getLastNumberTrivia;

      expect(() => call(), throwsA(isInstanceOf<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'test');
    test('should call SharedPreferences to cache the data', () async {
      datasource.cacheNumberTrivia(tNumberTriviaModel);

      final expectJsonString = json.encode(tNumberTriviaModel.toJson());

      verify(mockSharedPreferences.setString(
        CACHED_NUMBER_TRIVIA,
        expectJsonString,
      ));
    });
  });
}
