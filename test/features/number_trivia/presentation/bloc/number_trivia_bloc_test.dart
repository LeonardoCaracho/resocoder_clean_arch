import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:resocoder_clean_arch/core/error/failures.dart';
import 'package:resocoder_clean_arch/core/usecases/usecase.dart';
import 'package:resocoder_clean_arch/core/util/input_converter.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/usecases/usecases.dart';
import 'package:resocoder_clean_arch/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

main() {
  MockGetConcreteNumberTrivia getConcreteNumberTrivia;
  MockGetRandomNumberTrivia getRandomNumberTrivia;
  MockInputConverter inputConverter;
  NumberTriviaBloc bloc;

  setUp(() {
    getConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    getRandomNumberTrivia = MockGetRandomNumberTrivia();
    inputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      concrete: getConcreteNumberTrivia,
      random: getRandomNumberTrivia,
      inputConverter: inputConverter,
    );
  });

  test('initialState should be Empty', () async {
    expect(bloc.initialState, Empty());
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '42';
    final tNumberParsed = 42;
    final tNumberTrivia = NumberTrivia(number: 42, text: 'test');

    void setUpMockInputConverterSuccess() =>
        when(inputConverter.stringToUnsignedInteger(any))
            .thenReturn(Right(tNumberParsed));

    void setUpMockGetConcreteNumberTriviaSuccess() =>
        when(getConcreteNumberTrivia(Params(number: tNumberParsed)))
            .thenAnswer((_) async => Right(tNumberTrivia));

    test(
        'should call the InputConverter to validate e convert the string to an unsigned integer',
        () async {
      setUpMockInputConverterSuccess();

      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(inputConverter.stringToUnsignedInteger(tNumberString));

      verify(inputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [Error] when the input is invalid', () async {
      when(inputConverter.stringToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure()));

      final expected = [
        Empty(),
        Error(message: INVALID_INPUT_MESSAGE),
      ];
      expectLater(bloc.state, emitsInOrder(expected));

      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get data from the concrete usecase', () async {
      setUpMockInputConverterSuccess();
      setUpMockGetConcreteNumberTriviaSuccess();

      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(getConcreteNumberTrivia(any));

      verify(getConcreteNumberTrivia(Params(number: tNumberParsed)));
    });

    test('should emit[Loading, Loaded] when data is gotten successfully',
        () async {
      setUpMockInputConverterSuccess();
      setUpMockGetConcreteNumberTriviaSuccess();

      final expected = [
        Empty(),
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.state, emitsInOrder(expected));

      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit[Loading, Error] when data is gotten unsuccessfully',
        () async {
      setUpMockInputConverterSuccess();
      when(getConcreteNumberTrivia(Params(number: tNumberParsed)))
          .thenAnswer((_) async => Left(ServerFailure()));

      final expected = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emitsInOrder(expected));

      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit[Loading, Error] with the proper error message', () async {
      setUpMockInputConverterSuccess();
      when(getConcreteNumberTrivia(Params(number: tNumberParsed)))
          .thenAnswer((_) async => Left(CacheFailure()));

      final expected = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emitsInOrder(expected));

      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(number: 42, text: 'test');

    void setUpMockGetRandomNumberTriviaSuccess() =>
        when(getRandomNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
    test('should get data from the random usecase', () async {
      setUpMockGetRandomNumberTriviaSuccess();

      bloc.dispatch(GetTriviaForRandomNumber());
      await untilCalled(getRandomNumberTrivia(any));

      verify(getRandomNumberTrivia(NoParams()));
    });

    test('should emit[Loading, Loaded] when data is gotten successfully',
        () async {
      setUpMockGetRandomNumberTriviaSuccess();

      final expected = [
        Empty(),
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.state, emitsInOrder(expected));

      bloc.dispatch(GetTriviaForRandomNumber());
    });

    test('should emit[Loading, Error] when data is gotten unsuccessfully',
        () async {
      setUpMockGetRandomNumberTriviaSuccess();
      when(getRandomNumberTrivia(NoParams()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final expected = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emitsInOrder(expected));

      bloc.dispatch(GetTriviaForRandomNumber());
    });

    test('should emit[Loading, Error] with the proper error message', () async {
      setUpMockGetRandomNumberTriviaSuccess();
      when(getRandomNumberTrivia(NoParams()))
          .thenAnswer((_) async => Left(CacheFailure()));

      final expected = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emitsInOrder(expected));

      bloc.dispatch(GetTriviaForRandomNumber());
    });
  });
}
