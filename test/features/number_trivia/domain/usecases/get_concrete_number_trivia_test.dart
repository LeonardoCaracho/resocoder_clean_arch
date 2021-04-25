import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  GetConcreteNumberTrivia usecase;
  MockNumberTriviaRepository repository;

  setUp(() {
    repository = new MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(repository: repository);
  });

  final tNumber = 1;
  final tNumberTrivia = NumberTrivia(number: 1, text: 'test');

  test('should get trivia for the number from the repository', () async {
    when(repository.getConcreteNumberTrivia(any))
        .thenAnswer((_) async => Right(tNumberTrivia));

    final result = await usecase(Params(number: tNumber));

    expect(result, Right(tNumberTrivia));
    verify(repository.getConcreteNumberTrivia(tNumber)).called(1);
    verifyNoMoreInteractions(repository);
  });
}
