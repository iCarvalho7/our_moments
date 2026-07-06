import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';

import '../entity/place_suggestion.dart';
import '../repository/geocoding_repository.dart';

class SearchPlacesParams {
  const SearchPlacesParams({
    required this.query,
    this.biasLatitude,
    this.biasLongitude,
  });

  final String query;
  final double? biasLatitude;
  final double? biasLongitude;
}

@injectable
class SearchPlacesUseCase
    extends AsyncUseCase<List<PlaceSuggestion>, SearchPlacesParams> {
  const SearchPlacesUseCase(this._repository);

  final GeocodingRepository _repository;

  @override
  Future<List<PlaceSuggestion>> execute(SearchPlacesParams params) =>
      _repository.searchPlaces(
        query: params.query,
        biasLatitude: params.biasLatitude,
        biasLongitude: params.biasLongitude,
      );
}
