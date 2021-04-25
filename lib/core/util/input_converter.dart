import 'package:dartz/dartz.dart';
import 'package:resocoder_clean_arch/core/error/failures.dart';

class InputConverter {
  Either<InvalidInputFailure, int> stringToUnsignedInteger(String str) {
    try {
      final integer = int.parse(str);
      if (integer < 0) {
        throw FormatException();
      }
      return Right(int.parse(str));
    } on FormatException {
      return Left(InvalidInputFailure());
    }
  }
}

class InvalidInputFailure extends Failure {}
