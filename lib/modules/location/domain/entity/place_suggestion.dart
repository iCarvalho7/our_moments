class PlaceSuggestion {
  const PlaceSuggestion({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.primaryType = '',
  });

  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String primaryType;
}
