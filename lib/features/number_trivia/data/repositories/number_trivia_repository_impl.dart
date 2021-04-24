import 'package:flutter/material.dart';
import 'package:resocoder_clean_arch/core/error/exceptions.dart';
import 'package:resocoder_clean_arch/core/network/network_info.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:resocoder_clean_arch/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:resocoder_clean_arch/features/number_trivia/domain/repositories/number_trivia_repository.dart';

typedef Future<NumberTrivia> _ConcreteOrRandomChooser();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDatasource remoteDatasource;
  final NumberTriviaLocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    @required this.remoteDatasource,
    @required this.localDatasource,
    @required this.networkInfo,
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
      int number) async {
    return await _getTrivia(
      () => remoteDatasource.getConcreteNumberTrivia(number),
    );
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return await _getTrivia(
      () => remoteDatasource.getRandomNumberTrivia(),
    );
  }

  Future<Either<Failure, NumberTrivia>> _getTrivia(
    _ConcreteOrRandomChooser getConcreteOrRandom,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia = await getConcreteOrRandom();
        localDatasource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    }

    try {
      final localTrivia = await localDatasource.getLastNumberTrivia();
      return Right(localTrivia);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
