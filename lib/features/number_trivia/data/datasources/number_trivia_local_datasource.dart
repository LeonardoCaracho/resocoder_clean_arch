import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:resocoder_clean_arch/core/error/exceptions.dart';
import 'package:resocoder_clean_arch/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const CACHED_NUMBER_TRIVIA = 'CACHED_NUMBER_TRIVIA';

abstract class NumberTriviaLocalDatasource {
  /// Gets the cached [NumberTriviaModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<NumberTriviaModel> getLastNumberTrivia();
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}

class NumberTriviaLocalDatasourceImpl implements NumberTriviaLocalDatasource {
  final SharedPreferences sharedPreferences;

  NumberTriviaLocalDatasourceImpl({@required this.sharedPreferences});

  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache) {
    final jsonString = json.encode(triviaToCache.toJson());
    return sharedPreferences.setString(CACHED_NUMBER_TRIVIA, jsonString);
  }

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() {
    final jsonString = sharedPreferences.getString(CACHED_NUMBER_TRIVIA);

    if (jsonString == null) {
      throw CacheException();
    }

    return Future.value(NumberTriviaModel.fromJson(json.decode(jsonString)));
  }
}
