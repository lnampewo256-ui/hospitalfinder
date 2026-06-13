import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'hospital.dart';

// FlutterMap imports
import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as latlng;

class HospitalDetailPage extends StatefulWidget {
  final Hospital hospital;

  const HospitalDetailPage({super.key, required this.hospital});

  @override
  State<HospitalDetailPage> createState() => _HospitalDetailPageState();
}

class _HospitalDetailPageState extends State<HospitalDetailPage> {
  @override
  Widget build(BuildContext context) {
    // Defensive defaults for latitude/longitude
    final double lat = (widget.hospital.latitude != 0.0)
        ? widget.hospital.latitude
        : 0.3476; // fallback to Entebbe
    final double lng = (widget.hospital.longitude != 0.0)
        ? widget.hospital.longitude
        : 32.5825; // fallback to Kampala

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hospital.name.isNotEmpty
            ? widget.hospital.name
            : 'Hospital'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map widget (FlutterMap everywhere)
            Container(
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: fmap.FlutterMap(
                  options: fmap.MapOptions(
                    initialCenter: latlng.LatLng(lat, lng),
                    initialZoom: 14,
                  ),
                  children: [
                    fmap.TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.hospitalfinder',
                    ),
                    fmap.MarkerLayer(
                      markers: [
                        fmap.Marker(
                          point: latlng.LatLng(lat, lng),
                          child: const Icon(
                            Icons.local_hospital,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Address
            _buildInfoCard(
              'Address',
              widget.hospital.address.isNotEmpty
                  ? widget.hospital.address
                  : 'No address available',
              Icons.location_on,
            ),

            // Phone number
            if (widget.hospital.phoneNumber != null &&
                widget.hospital.phoneNumber!.isNotEmpty)
              _buildInfoCard(
                'Contact',
                widget.hospital.phoneNumber!,
                Icons.phone,
                onTap: () => _launchUrl('tel:${widget.hospital.phoneNumber}'),
              ),

            const SizedBox(height: 16),

            // Services
            _buildSectionTitle('Services Offered'),
            _buildChipWrap(widget.hospital.services, Colors.teal[100]),

            const SizedBox(height: 16),

            // Diseases
            _buildSectionTitle('Diseases Treated'),
            _buildChipWrap(widget.hospital.diseases, Colors.blue[100]),

            const SizedBox(height: 16),

            // Professions
            _buildSectionTitle('Available Professions'),
            _buildChipWrap(widget.hospital.professions, Colors.purple[100]),

            const SizedBox(height: 24),

            // Directions button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(
                  'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
                ),
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button with quick actions
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.hospital.phoneNumber != null &&
              widget.hospital.phoneNumber!.isNotEmpty)
            FloatingActionButton.extended(
              heroTag: 'callBtn',
              onPressed: () =>
                  _launchUrl('tel:${widget.hospital.phoneNumber}'),
              icon: const Icon(Icons.phone),
              label: const Text('Call'),
              backgroundColor: Colors.teal,
            ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'directionsBtn',
            onPressed: () => _launchUrl(
              'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
            ),
            icon: const Icon(Icons.directions),
            label: const Text('Directions'),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon,
      {VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildChipWrap(List<String> items, Color? color) {
    if (items.isEmpty) {
      return const Text('No data available');
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: items
          .map((item) => Chip(
                label: Text(item),
                backgroundColor: color,
              ))
          .toList(),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $uri');
    }
  }
}
