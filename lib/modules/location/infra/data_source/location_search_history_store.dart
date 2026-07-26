import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entity/place_suggestion.dart';
import 'place_suggestion_codec.dart';

const String _kSearchHistoryKey = 'location_search_history';
const int _kMaxHistoryEntries = 8;

/// Persists locally the places the user previously picked (from search or by
/// dragging the map pin), so they can be offered again without hitting the
/// network.
abstract class LocationSearchHistoryStore {
  Future<List<PlaceSuggestion>> recent();
  Future<void> add(PlaceSuggestion suggestion);
  Future<void> remove(PlaceSuggestion suggestion);
  Future<void> clear();
}

@Injectable(as: LocationSearchHistoryStore)
class SharedPrefsLocationSearchHistoryStore
    extends LocationSearchHistoryStore {
  @override
  Future<List<PlaceSuggestion>> recent() async {
    final prefs = await SharedPreferences.getInstance();
    return decodePlaceSuggestions(prefs.getStringList(_kSearchHistoryKey) ?? const []);
  }

  @override
  Future<void> add(PlaceSuggestion suggestion) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await recent();
    // Most-recent-first, dedup by name + coordinates, capped.
    final next = [
      suggestion,
      ...current.where((s) => !samePlace(s, suggestion)),
    ].take(_kMaxHistoryEntries).toList();
    await prefs.setStringList(_kSearchHistoryKey, next.map((s) => s.encode()).toList());
  }

  @override
  Future<void> remove(PlaceSuggestion suggestion) async {
    final prefs = await SharedPreferences.getInstance();
    final next = (await recent())
        .where((s) => !samePlace(s, suggestion))
        .map((s) => s.encode())
        .toList();
    await prefs.setStringList(_kSearchHistoryKey, next);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSearchHistoryKey);
  }
}
