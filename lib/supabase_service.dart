import 'package:supabase_flutter/supabase_flutter.dart';
import 'hospital.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Fetch all hospitals, optionally filtered by search query.
  Future<List<Hospital>> getHospitals({String? searchQuery}) async {
    try {
      var query = supabase.from('hospitals').select();

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim();
        query = query.or(
          'name.ilike.%$q%,services.ilike.%$q%,diseases.ilike.%$q%,professions.ilike.%$q%',
        );
      }

      final response = await query;
      if (response is List) {
        return response.map((e) => Hospital.fromMap(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load hospitals: $e');
    }
  }

  /// Fetch a single hospital by ID.
  Future<Hospital> getHospitalById(String id) async {
    try {
      final response = await supabase
          .from('hospitals')
          .select()
          .eq('id', id)
          .maybeSingle(); // safer than .single()
      if (response == null) {
        throw Exception('Hospital not found');
      }
      return Hospital.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load hospital details: $e');
    }
  }

  /// Add a new hospital.
  Future<Hospital> addHospital({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String userId,
    String? services,
    String? diseases,
    String? professions,
    String? phoneNumber,
  }) async {
    try {
      final response = await supabase.from('hospitals').insert({
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'user_id': userId,
        'phone_number': phoneNumber ?? '',
        'services': services ?? '',
        'diseases': diseases ?? '',
        'professions': professions ?? '',
      }).select().maybeSingle();

      if (response == null) {
        throw Exception('Failed to insert hospital');
      }
      return Hospital.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to add hospital: $e');
    }
  }

  /// Update an existing hospital.
  Future<Hospital> updateHospital(String id, Map<String, dynamic> updates) async {
    try {
      final response = await supabase
          .from('hospitals')
          .update(updates)
          .eq('id', id)
          .select()
          .maybeSingle();
      if (response == null) {
        throw Exception('Hospital not found for update');
      }
      return Hospital.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update hospital: $e');
    }
  }

  /// Delete a hospital by ID.
  Future<void> deleteHospital(String id) async {
    try {
      await supabase.from('hospitals').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete hospital: $e');
    }
  }

  /// Fetch hospitals near a given location within a radius (km).
  Future<List<Hospital>> getNearbyHospitals({
    required double latitude,
    required double longitude,
    double radiusInKm = 5.0,
  }) async {
    try {
      // Approximate conversion: 1° ~ 111 km
      final double degreeRadius = radiusInKm / 111.0;

      final response = await supabase
          .from('hospitals')
          .select()
          .gte('latitude', latitude - degreeRadius)
          .lte('latitude', latitude + degreeRadius)
          .gte('longitude', longitude - degreeRadius)
          .lte('longitude', longitude + degreeRadius);

      if (response is List) {
        return response.map((e) => Hospital.fromMap(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load nearby hospitals: $e');
    }
  }
}
