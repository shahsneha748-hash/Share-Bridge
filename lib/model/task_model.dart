class GeoPointLocation {
  final double lat;
  final double lng;
  final String address;

  const GeoPointLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  Map<String, dynamic> toMap() => {
    'lat': lat,
    'lng': lng,
    'address': address,
  };
}