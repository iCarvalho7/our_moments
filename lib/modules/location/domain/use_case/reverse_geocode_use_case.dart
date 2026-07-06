import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';

import '../repository/geocoding_repository.dart';

class ReverseGeocodeParams {
  const ReverseGeocodeParams({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

@injectable
class ReverseGeocodeUseCase extends AsyncUseCase<String, ReverseGeocodeParams> {
  const ReverseGeocodeUseCase(this._repository);

  final GeocodingRepository _repository;

  @override
  Future<String> execute(ReverseGeocodeParams params) =>
      _repository.reverseGeocode(params.latitude, params.longitude);
}
