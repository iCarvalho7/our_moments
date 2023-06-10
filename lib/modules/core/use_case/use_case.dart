import 'package:flutter/foundation.dart';

import '../entity/result.dart';

abstract class UseCase<TResult, TParams> {
  const UseCase();

  @nonVirtual
  Result<TResult> call(TParams params) {
    try {
      final result = execute(params);
      return Result.success(data: result);
    } catch (exception) {
      return Result.error(exception);
    }
  }

  TResult execute(TParams params);
}

abstract class AsyncUseCase<TResult, TParams> {
  const AsyncUseCase();

  @nonVirtual
  Future<Result<TResult>> call(TParams params) async {
    try {
      final result = await execute(params);
      return Result.success(data: result);
    } catch (exception) {
      return Result.error(exception);
    }
  }

  @protected
  Future<TResult> execute(TParams params);
}

class NoParams {
  const NoParams._();

  static NoParams instance = const NoParams._();
}
