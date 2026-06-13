import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'hospital.dart';

/// Wrapper widget that shows Google Maps on mobile, FlutterMap on web.
class HospitalMap extends StatelessWidget {
  final Hospital hospital;

  const HospitalMap({super.key, required this.hospital});

  @override
  Widget build(BuildContext context) {
    final double lat = hospital.latitude != 0.0 ? hospital.latitude : 0.3476;
    final double lng = hospital.longitude != 0.0 ? hospital.longitude : 32.5825;

    if (kIsWeb) {
      // Web: use flutter_map + OpenStreetMap
      import 'package:flutter_map/flutter_map.dart';
      import 'package:latlong2/latlong.dart' as latlng;

      return SizedBox(
        height: 280,
        child: FlutterMap(
          options: MapOptions(
            center: latlng.LatLng(lat, lng),
            zoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.hospitalfinder',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 40,
                  height: 40,
                  point: latlng.LatLng(lat, lng),
                  builder: (ctx) => const Icon(Icons.local_hospital,
                      color: Colors.red, size: 30),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Mobile: use Google Maps
      import 'package:google_maps_flutter/google_maps_flutter.dart';

      return SizedBox(
        height: 280,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(lat, lng),
            zoom: 14,
          ),
          markers: {
            Marker(
              markerId: MarkerId(hospital.id.isNotEmpty
                  ? hospital.id
                  : 'hospital_marker'),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: hospital.name.isNotEmpty
                    ? hospital.name
                    : 'Unknown Hospital',
                snippet: hospital.address.isNotEmpty
                    ? hospital.address
                    : 'No address available',
              ),
            ),
          },
          zoomControlsEnabled: false,
        ),
      );
    }
  }
}
