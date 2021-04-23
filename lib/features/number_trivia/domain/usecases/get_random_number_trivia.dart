import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:resocoder_clean_arch/core/error/failures.dart';
import 'package:resocoder_clean_arch/core/usecases/usecase.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/repositories/number_trivia_repository.dart';

class GetRandomNumberTrivia implements Usecase<NumberTrivia, NoParams> {
  final NumberTriviaRepository repository;

  GetRandomNumberTrivia({@required this.repository});

  @override
  Future<Either<Failure, NumberTrivia>> call(NoParams params) async {
    return await this.repository.getRandomNumberTrivia();
  }
}
