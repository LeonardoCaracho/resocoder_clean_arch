import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:resocoder_clean_arch/core/error/exceptions.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/datasources/datasources.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/models/models.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  MockHttpClient httpClient;
  NumberTriviaRemoteDatasourceImpl datasource;

  setUp(() {
    httpClient = MockHttpClient();
    datasource = NumberTriviaRemoteDatasourceImpl(
      client: httpClient,
    );
  });

  void setUpMockHttpClientSuccess() {
    when(httpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure() {
    when(httpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 42;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test('''should perform a GET request on a URL with number 
           being the endpoint and with application/json header''', () async {
      setUpMockHttpClientSuccess();

      await datasource.getConcreteNumberTrivia(tNumber);

      verify(
        httpClient.get(
          Uri.parse('http://numbersapi.com/$tNumber'),
          headers: {'Content-Type': 'application/json'},
        ),
      );
    });
    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      setUpMockHttpClientSuccess();

      final result = await datasource.getConcreteNumberTrivia(tNumber);

      expect(result, tNumberTriviaModel);
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      setUpMockHttpClientFailure();

      final call = datasource.getConcreteNumberTrivia;

      expect(() => call(tNumber), throwsA(isInstanceOf<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test('''should perform a GET request on a URL with random 
           being the endpoint and with application/json header''', () async {
      setUpMockHttpClientSuccess();

      await datasource.getRandomNumberTrivia();

      verify(
        httpClient.get(
          Uri.parse('http://numbersapi.com/random'),
          headers: {'Content-Type': 'application/json'},
        ),
      );
    });
    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      setUpMockHttpClientSuccess();

      final result = await datasource.getRandomNumberTrivia();

      expect(result, tNumberTriviaModel);
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      setUpMockHttpClientFailure();

      final call = datasource.getRandomNumberTrivia;

      expect(() => call(), throwsA(isInstanceOf<ServerException>()));
    });
  });
}
