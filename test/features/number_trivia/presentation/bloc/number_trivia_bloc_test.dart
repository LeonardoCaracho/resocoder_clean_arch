import 'package:bloc_test/bloc_test.dart';
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
      getConcreteNumberTrivia: getConcreteNumberTrivia,
      getRandomNumberTrivia: getRandomNumberTrivia,
      inputConverter: inputConverter,
    );
  });

  test('initialState should be Empty', () async {
    expect(bloc.state, Empty());
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

      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(inputConverter.stringToUnsignedInteger(tNumberString));

      verify(inputConverter.stringToUnsignedInteger(tNumberString));
    });

    blocTest(
      'should emit [Error] when the input is invalid',
      build: () {
        when(inputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));

        return NumberTriviaBloc(
          getConcreteNumberTrivia: getConcreteNumberTrivia,
          getRandomNumberTrivia: getRandomNumberTrivia,
          inputConverter: inputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [
        Error(message: INVALID_INPUT_MESSAGE),
      ],
    );

    blocTest(
      'should get data from the concrete usecase',
      build: () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();

        return NumberTriviaBloc(
          getConcreteNumberTrivia: getConcreteNumberTrivia,
          getRandomNumberTrivia: getRandomNumberTrivia,
          inputConverter: inputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      verify: (_) => getConcreteNumberTrivia(Params(number: tNumberParsed)),
    );

    blocTest(
      'should emit[Loading, Loaded] when data is gotten successfully',
      build: () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();

        return NumberTriviaBloc(
          getConcreteNumberTrivia: getConcreteNumberTrivia,
          getRandomNumberTrivia: getRandomNumberTrivia,
          inputConverter: inputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [Loading(), Loaded(trivia: tNumberTrivia)],
    );

    blocTest(
      'should emit[Loading, Error] when data is gotten unsuccessfully',
      build: () {
        setUpMockInputConverterSuccess();
        when(getConcreteNumberTrivia(Params(number: tNumberParsed)))
            .thenAnswer((_) async => Left(ServerFailure()));

        return NumberTriviaBloc(
          getConcreteNumberTrivia: getConcreteNumberTrivia,
          getRandomNumberTrivia: getRandomNumberTrivia,
          inputConverter: inputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [Loading(), Error(message: SERVER_FAILURE_MESSAGE)],
    );

    blocTest(
      'should emit[Loading, Error] with the proper error message',
      build: () {
        setUpMockInputConverterSuccess();
        when(getConcreteNumberTrivia(Params(number: tNumberParsed)))
            .thenAnswer((_) async => Left(CacheFailure()));

        return NumberTriviaBloc(
          getConcreteNumberTrivia: getConcreteNumberTrivia,
          getRandomNumberTrivia: getRandomNumberTrivia,
          inputConverter: inputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [Loading(), Error(message: CACHE_FAILURE_MESSAGE)],
    );
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(number: 42, text: 'test');

    void setUpMockGetRandomNumberTriviaSuccess() =>
        when(getRandomNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
    test('should get data from the random usecase', () async {
      setUpMockGetRandomNumberTriviaSuccess();

      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(getRandomNumberTrivia(any));

      verify(getRandomNumberTrivia(NoParams()));
    });

    blocTest(
      'should emit[Loading, Loaded] when data is gotten successfully',
      build: () {
        setUpMockGetRandomNumberTriviaSuccess();

        return NumberTriviaBloc(
          getConcreteNumberTrivia: getConcreteNumberTrivia,
          getRandomNumberTrivia: getRandomNumberTrivia,
          inputConverter: inputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => [Loading(), Loaded(trivia: tNumberTrivia)],
    );

    blocTest(
      'should emit[Loading, Error] when data is gotten unsuccessfully',
      build: () {
        setUpMockGetRandomNumberTriviaSuccess();
        when(getRandomNumberTrivia(NoParams()))
            .thenAnswer((_) async => Left(ServerFailure()));

        return NumberTriviaBloc(
          getConcreteNumberTrivia: getConcreteNumberTrivia,
          getRandomNumberTrivia: getRandomNumberTrivia,
          inputConverter: inputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => [Loading(), Error(message: SERVER_FAILURE_MESSAGE)],
    );

    blocTest(
      'should emit[Loading, Error] when data is gotten unsuccessfully',
      build: () {
        setUpMockGetRandomNumberTriviaSuccess();
        when(getRandomNumberTrivia(NoParams()))
            .thenAnswer((_) async => Left(CacheFailure()));

        return NumberTriviaBloc(
          getConcreteNumberTrivia: getConcreteNumberTrivia,
          getRandomNumberTrivia: getRandomNumberTrivia,
          inputConverter: inputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => [Loading(), Error(message: CACHE_FAILURE_MESSAGE)],
    );
  });
}
