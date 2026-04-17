class Location {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String country;
  final double accuracy;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
    required this.accuracy,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      accuracy: json['accuracy'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'country': country,
      'accuracy': accuracy,
    };
  }
}
