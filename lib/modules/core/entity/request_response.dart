import 'request_response_error.dart';

class RequestResponse<T> {
  RequestResponse.success(this.data)
      : type = RequestResponseType.success,
        error = null;

  // ignore: tighten_type_of_initializing_formals
  RequestResponse.error(this.error)
      : type = RequestResponseType.error,
        data = null,
        assert(error != null);

  final T? data;
  final RequestResponseError? error;
  final RequestResponseType type;

  bool get isSuccess => type == RequestResponseType.success;
  bool get isError => type == RequestResponseType.error;

  @override
  String toString() {
    if (isSuccess) {
      return 'SUCCESS - ${data.toString()}';
    }

    return 'ERROR - ${error.toString()}';
  }
}

enum RequestResponseType {
  success,
  error,
}
