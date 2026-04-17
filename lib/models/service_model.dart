class Service {
  final String id;
  final String name;
  final String category; // 'hospital', 'pharmacy', 'specialist', 'emergency'
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String? email;
  final double rating;
  final int reviewCount;
  final String? imageUrl;
  final List<String> specialties;
  final bool isOpen;
  final String workingHours;
  final String? description;
  final List<String> services;
  final double distance; // en km

  Service({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.email,
    required this.rating,
    required this.reviewCount,
    this.imageUrl,
    required this.specialties,
    required this.isOpen,
    required this.workingHours,
    this.description,
    required this.services,
    required this.distance,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Service').toString(),
      category: (json['category'] ?? 'hospital').toString(),
      address: (json['address'] ?? '').toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      phone: (json['phone'] ?? '').toString(),
      email: json['email'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String?,
      specialties: json['specialties'] != null
          ? List<String>.from(json['specialties'] as List)
          : [],
      isOpen: json['isOpen'] as bool? ?? false,
      workingHours: (json['workingHours'] ?? '').toString(),
      description: json['description'] as String?,
      services: json['services'] != null
          ? List<String>.from(json['services'] as List)
          : [],
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'specialties': specialties,
      'isOpen': isOpen,
      'workingHours': workingHours,
      'description': description,
      'services': services,
      'distance': distance,
    };
  }

  String get categoryLabel {
    switch (category) {
      case 'hospital':
        return 'Hôpital';
      case 'pharmacy':
        return 'Pharmacie';
      case 'specialist':
        return 'Spécialiste';
      case 'emergency':
        return 'Urgences';
      case 'imaging':
        return 'Imagerie';
      default:
        return 'Service';
    }
  }

  Service copyWith({double? distance}) {
    return Service(
      id: id,
      name: name,
      category: category,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      email: email,
      rating: rating,
      reviewCount: reviewCount,
      imageUrl: imageUrl,
      specialties: specialties,
      isOpen: isOpen,
      workingHours: workingHours,
      description: description,
      services: services,
      distance: distance ?? this.distance,
    );
  }
}
