import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../domain/entity/place_suggestion.dart';
import '../../infra/data_source/geocoding_data_source.dart';

@Injectable(as: GeocodingDataSource)
class GooglePlacesDataSource implements GeocodingDataSource {
  static const _apiKey = String.fromEnvironment('GOOGLE_PLACES_API_KEY');

  static const _endpoint = 'https://places.googleapis.com/v1/places:searchText';

  static const _fieldMask = 'places.displayName,places.formattedAddress,places.location,places.primaryType';

  static const _geocodeEndpoint = 'https://maps.googleapis.com/maps/api/geocode/json';

  @override
  Future<String> reverseGeocode(double latitude, double longitude) async {
    try {
      final uri = Uri.parse(
        '$_geocodeEndpoint?latlng=$latitude,$longitude&key=$_apiKey&language=pt-BR',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return '';
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if ((data['status'] as String?) != 'OK') return '';
      final results = (data['results'] as List<dynamic>?) ?? const [];
      if (results.isEmpty) return '';
      final address = (results.first as Map<String, dynamic>)['formatted_address'] as String? ?? '';
      return address.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).take(2).join(', ');
    } catch (_) {
      return '';
    }
  }

  @override
  Future<List<PlaceSuggestion>> searchPlaces({
    required String query,
    double? biasLatitude,
    double? biasLongitude,
  }) async {
    final body = <String, dynamic>{'textQuery': query, 'languageCode': 'pt-BR', 'maxResultCount': 8};

    if (biasLatitude != null && biasLongitude != null) {
      body['locationBias'] = {
        'circle': {
          'center': {'latitude': biasLatitude, 'longitude': biasLongitude},
          'radius': 50000.0,
        },
      };
    }

    if (kDebugMode && _apiKey.isEmpty) {
      debugPrint(
        '[GooglePlaces] API key is empty — pass --dart-define=GOOGLE_PLACES_API_KEY=<key> and do a full restart.',
      );
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json', 'X-Goog-Api-Key': _apiKey, 'X-Goog-FieldMask': _fieldMask},
      body: jsonEncode(body),
    );

    if (kDebugMode) {
      debugPrint('[GooglePlaces] status=${response.statusCode} body=${response.body}');
    }

    if (response.statusCode != 200) return const [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final places = (data['places'] as List<dynamic>?) ?? const [];

    return places.map((p) {
      final map = p as Map<String, dynamic>;
      final displayName = map['displayName'] as Map<String, dynamic>?;
      final location = map['location'] as Map<String, dynamic>?;
      return PlaceSuggestion(
        name: (displayName?['text'] as String?) ?? '',
        address: (map['formattedAddress'] as String?) ?? '',
        latitude: (location?['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (location?['longitude'] as num?)?.toDouble() ?? 0,
        primaryType: (map['primaryType'] as String?) ?? '',
      );
    }).toList();
  }
}
