import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'hospital.dart';
import 'supabase_service.dart';
import 'hospital_detail_page.dart';
import 'main.dart'; // for scheduleDailyNotification

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Hospital>> _hospitalsFuture;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final List<String> _quickServices = [
    'General Surgery',
    'Maternity',
    'Pediatrics',
    'Dental',
    'Emergency'
  ];

  @override
  void initState() {
    super.initState();
    // Fetch all hospitals initially
    _hospitalsFuture = _supabaseService.getHospitals();

    // Schedule daily notification safely
    scheduleDailyNotification();
  }

  void _searchHospitals(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _hospitalsFuture = _supabaseService.getHospitals(searchQuery: query);
      });
    });
  }

  Future<void> _findNearbyHospitals() async {
    final location = Location();

    // Request service
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    // Request permission
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Get current location
    final userLocation = await location.getLocation();
    final lat = userLocation.latitude ?? 0.0;
    final lng = userLocation.longitude ?? 0.0;

    setState(() {
      _hospitalsFuture = _supabaseService.getNearbyHospitals(
        latitude: lat,
        longitude: lng,
        radiusInKm: 5.0,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text(
          'Find a Hospital in Entebbe',
          style: TextStyle(color: Colors.green),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade300, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Welcome to Wellness Finder',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your daily guide to health and nearby hospitals',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search Field
            TextField(
              controller: _searchController,
              onChanged: _searchHospitals,
              decoration: InputDecoration(
                hintText: 'Search by name, service, or profession...',
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Search Section
            const Text(
              'Quick Search',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _quickServices.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: ElevatedButton(
                      onPressed: () => _searchHospitals(_quickServices[index]),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[100],
                        foregroundColor: Colors.green[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 2,
                      ),
                      child: Text(
                        _quickServices[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Hospitals List
            Expanded(
              child: FutureBuilder<List<Hospital>>(
                future: _hospitalsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    );
                  } else if (snapshot.hasError) {
                    debugPrint("Error fetching hospitals: ${snapshot.error}");
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hospitals found.',
                        style: TextStyle(color: Colors.green),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final hospital = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            // Defensive logging
                            debugPrint(
                                "Navigating to hospital: ${hospital.name}, ${hospital.address}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HospitalDetailPage(hospital: hospital),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              leading: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.local_hospital,
                                  color: Colors.green,
                                ),
                              ),
                              title: Text(
                                hospital.name ?? 'Unknown Hospital',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  hospital.address ?? 'No address available'),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button for Nearby Hospitals
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _findNearbyHospitals,
        icon: const Icon(Icons.my_location),
        label: const Text('Nearby Hospitals'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
