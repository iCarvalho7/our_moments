class Result<T> {
  Result.loading()
      : type = ResultType.loading,
        data = null,
        exception = null;

  Result.success({this.data})
      : type = ResultType.success,
        exception = null;

  // ignore: tighten_type_of_initializing_formals
  Result.error(this.exception)
      : type = ResultType.error,
        data = null,
        assert(exception != null);

  final T? data;
  final dynamic exception;
  final ResultType type;

  bool get isLoading => type == ResultType.loading;
  bool get isSuccess => type == ResultType.success;
  bool get isError => type == ResultType.error;

  @override
  String toString() {
    if (isLoading) {
      return 'LOADING';
    }

    if (isSuccess) {
      return 'SUCCESS - ${data.toString()}';
    }

    return 'ERROR - ${exception.toString()}';
  }
}

enum ResultType {
  loading,
  success,
  error,
}
