// lib/screens/masjid_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class MasjidScreen extends StatefulWidget {
  const MasjidScreen({super.key});

  @override
  State<MasjidScreen> createState() => _MasjidScreenState();
}

class _MasjidScreenState extends State<MasjidScreen> {
  List<Map<String, dynamic>> _masjids = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchNearbyMasjids();
  }

  Future<void> _fetchNearbyMasjids() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Overpass API query for mosques within 5km radius
      const radius = 5000; // 5km in meters
      final query = '''
        [out:json][timeout:25];
        (
          node["amenity"="place_of_worship"]["religion"="muslim"](around:${radius},${position.latitude},${position.longitude});
          way["amenity"="place_of_worship"]["religion"="muslim"](around:${radius},${position.latitude},${position.longitude});
          relation["amenity"="place_of_worship"]["religion"="muslim"](around:${radius},${position.latitude},${position.longitude});
        );
        out center meta;
      ''';

      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: {'data': query},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        List<Map<String, dynamic>> masjids = [];
        for (var element in elements) {
          final lat = element['lat'] ?? element['center']?['lat'];
          final lon = element['lon'] ?? element['center']?['lon'];
          final name = element['tags']?['name'] ?? 'Masjid Tanpa Nama';
          final address = element['tags']?['addr:full'] ??
                         element['tags']?['addr:street'] ??
                         'Alamat tidak tersedia';

          if (lat != null && lon != null) {
            // Calculate distance
            final distance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              lat,
              lon,
            );

            masjids.add({
              'name': name,
              'address': address,
              'lat': lat,
              'lon': lon,
              'distance': distance,
            });
          }
        }

        // Sort by distance
        masjids.sort((a, b) => a['distance'].compareTo(b['distance']));

        setState(() {
          _masjids = masjids.take(10).toList(); // Limit to 10 results
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load mosques');
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data masjid: $e';
        _isLoading = false;
        // Use dummy data as fallback
        _masjids = [
          {
            'name': 'Masjid Al-Falah',
            'address': 'Jl. Veteran No.10',
            'distance': 500.0,
          },
          {
            'name': 'Masjid Al-Hidayah',
            'address': 'Jl. Merdeka No.5',
            'distance': 800.0,
          },
          {
            'name': 'Masjid Nurul Iman',
            'address': 'Jl. Pemuda No.8',
            'distance': 1200.0,
          },
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masjid Terdekat'),
        backgroundColor: const Color(0xFF4a7c59),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchNearbyMasjids,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _masjids.length,
                  itemBuilder: (context, index) {
                    final masjid = _masjids[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.mosque, color: Color(0xFF4a7c59), size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    masjid['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              masjid['address'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Color(0xFF999999)),
                                const SizedBox(width: 4),
                                Text(
                                  '${(masjid['distance'] / 1000).toStringAsFixed(1)} km',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    // Print to console as requested
                                    print('Lihat di Peta: ${masjid['name']}');
                                  },
                                  child: const Text(
                                    'Lihat di Peta',
                                    style: TextStyle(color: Color(0xFF4a7c59)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}