import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:resocoder_clean_arch/core/usecases/usecase.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  GetRandomNumberTrivia usecase;
  MockNumberTriviaRepository repository;

  setUp(() {
    repository = new MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(repository: repository);
  });

  final tNumberTrivia = NumberTrivia(number: 1, text: 'test');

  test('should get a random trivia from the repository', () async {
    when(repository.getRandomNumberTrivia())
        .thenAnswer((_) async => Right(tNumberTrivia));

    final result = await usecase(NoParams());

    expect(result, Right(tNumberTrivia));
    verify(repository.getRandomNumberTrivia()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
