class RequestResponseError {
  final dynamic exception;
  final String? resultCode;
  final String? resultDescription;

  RequestResponseError({
    this.resultCode,
    this.resultDescription,
    this.exception,
  });

  @override
  String toString() {
    return 'resultCode: $resultCode - resultDescription: $resultDescription - exception: $exception';
  }
}
