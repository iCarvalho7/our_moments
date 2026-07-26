import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entity/place_suggestion.dart';
import 'place_suggestion_codec.dart';

const String _kFavoritePlacesKey = 'location_favorite_places';
const int _kMaxFavorites = 50;

/// Persists locally the places the user starred as favorites, including custom
/// places they authored by hand (name + a spot on the map).
abstract class FavoritePlacesStore {
  Future<List<PlaceSuggestion>> favorites();
  Future<void> add(PlaceSuggestion suggestion);
  Future<void> remove(PlaceSuggestion suggestion);
  Future<bool> contains(PlaceSuggestion suggestion);
  Future<void> clear();
}

@Injectable(as: FavoritePlacesStore)
class SharedPrefsFavoritePlacesStore extends FavoritePlacesStore {
  @override
  Future<List<PlaceSuggestion>> favorites() async {
    final prefs = await SharedPreferences.getInstance();
    return decodePlaceSuggestions(prefs.getStringList(_kFavoritePlacesKey) ?? const []);
  }

  @override
  Future<void> add(PlaceSuggestion suggestion) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await favorites();
    // Most-recent-first, dedup by name + coordinates, capped.
    final next = [
      suggestion,
      ...current.where((s) => !samePlace(s, suggestion)),
    ].take(_kMaxFavorites).toList();
    await prefs.setStringList(_kFavoritePlacesKey, next.map((s) => s.encode()).toList());
  }

  @override
  Future<void> remove(PlaceSuggestion suggestion) async {
    final prefs = await SharedPreferences.getInstance();
    final next = (await favorites())
        .where((s) => !samePlace(s, suggestion))
        .map((s) => s.encode())
        .toList();
    await prefs.setStringList(_kFavoritePlacesKey, next);
  }

  @override
  Future<bool> contains(PlaceSuggestion suggestion) async =>
      (await favorites()).any((s) => samePlace(s, suggestion));

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kFavoritePlacesKey);
  }
}

