import '../../domain/entity/place_suggestion.dart';

abstract class GeocodingDataSource {
  Future<List<PlaceSuggestion>> searchPlaces({
    required String query,
    double? biasLatitude,
    double? biasLongitude,
  });

  /// Returns a short human-readable name for the given coordinates (empty on failure).
  Future<String> reverseGeocode(double latitude, double longitude);
}
