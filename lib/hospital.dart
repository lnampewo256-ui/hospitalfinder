// lib/hospital.dart
import 'package:collection/collection.dart';

class Hospital {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final List<String> services;
  final List<String> diseases;
  final List<String> professions;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    required this.services,
    required this.diseases,
    required this.professions,
  });

  /// Factory constructor to build a Hospital object from a Map (e.g. Supabase row).
  factory Hospital.fromMap(Map<String, dynamic> map) {
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is String && value.isNotEmpty) {
        return value.split(',').map((e) => e.trim()).toList();
      }
      if (value is List) {
        return value.map((e) => e.toString().trim()).toList();
      }
      return [];
    }

    return Hospital(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown Hospital',
      address: map['address']?.toString() ?? 'No address available',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      phoneNumber: map['phone_number']?.toString(),
      services: parseStringList(map['services']),
      diseases: parseStringList(map['diseases']),
      professions: parseStringList(map['professions']),
    );
  }

  /// Convert Hospital object back to a Map (useful for saving to DB).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'services': services.join(','),
      'diseases': diseases.join(','),
      'professions': professions.join(','),
    };
  }

  /// Convert Hospital object to JSON (API‑friendly).
  Map<String, dynamic> toJson() => toMap();

  /// Create a copy with modified fields.
  Hospital copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    List<String>? services,
    List<String>? diseases,
    List<String>? professions,
  }) {
    return Hospital(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      services: services ?? this.services,
      diseases: diseases ?? this.diseases,
      professions: professions ?? this.professions,
    );
  }

  @override
  String toString() {
    return 'Hospital(id: $id, name: $name, address: $address, '
        'lat: $latitude, lng: $longitude, phone: $phoneNumber, '
        'services: $services, diseases: $diseases, professions: $professions)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Hospital &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.phoneNumber == phoneNumber &&
        const ListEquality().equals(other.services, services) &&
        const ListEquality().equals(other.diseases, diseases) &&
        const ListEquality().equals(other.professions, professions);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        address.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        phoneNumber.hashCode ^
        const ListEquality().hash(services) ^
        const ListEquality().hash(diseases) ^
        const ListEquality().hash(professions);
  }
}
