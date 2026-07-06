import 'package:injectable/injectable.dart';

import '../../domain/entity/place_suggestion.dart';
import '../../domain/repository/geocoding_repository.dart';
import '../data_source/geocoding_data_source.dart';

@Injectable(as: GeocodingRepository)
class GeocodingRepositoryImpl implements GeocodingRepository {
  const GeocodingRepositoryImpl(this._dataSource);

  final GeocodingDataSource _dataSource;

  @override
  Future<List<PlaceSuggestion>> searchPlaces({
    required String query,
    double? biasLatitude,
    double? biasLongitude,
  }) =>
      _dataSource.searchPlaces(
        query: query,
        biasLatitude: biasLatitude,
        biasLongitude: biasLongitude,
      );

  @override
  Future<String> reverseGeocode(double latitude, double longitude) =>
      _dataSource.reverseGeocode(latitude, longitude);
}
