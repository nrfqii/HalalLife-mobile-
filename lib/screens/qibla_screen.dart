import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/qibla_service.dart';
import '../main.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _qiblaDirection;
  double? _currentHeading;
  double? _distanceToKaaba;
  StreamSubscription<double>? _compassSubscription;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeQibla();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeQibla() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Ensure location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permission denied';
          _isLoading = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permission permanently denied';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Calculate Qibla direction and distance
      _qiblaDirection = QiblaService.calculateQiblaDirection(
        pos.latitude,
        pos.longitude,
      );
      _distanceToKaaba = QiblaService.calculateDistanceToKaaba(
        pos.latitude,
        pos.longitude,
      );

      // Subscribe to compass heading stream
      _compassSubscription?.cancel();
      _compassSubscription = QiblaService.getCompassHeading()?.listen(
        (heading) {
          setState(() {
            _currentHeading = heading;
          });
        },
        onError: (error) {
          setState(() {
            _errorMessage = 'Compass not available: $error';
          });
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing Qibla: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arah Kiblat'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? _buildErrorView()
          : _buildCompassView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializeQibla,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassView() {
    // angle between device heading and qibla is computed on the fly when needed

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Compass background
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Cardinal directions
                      ..._buildCardinalDirections(),
                      // Degree markings
                      ..._buildDegreeMarkings(),
                    ],
                  ),
                ),

                // Rotating compass
                Transform.rotate(
                  angle: (_currentHeading ?? 0) * (math.pi / 180),
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // North indicator
                        Positioned(
                          top: 20,
                          child: Container(
                            width: 4,
                            height: 20,
                            color: Colors.red,
                          ),
                        ),
                        // Compass needle
                        Container(width: 4, height: 120, color: Colors.red),
                      ],
                    ),
                  ),
                ),

                // Qibla needle (fixed)
                Transform.rotate(
                  angle: (_qiblaDirection ?? 0) * (math.pi / 180),
                  child: Container(width: 4, height: 140, color: kPrimaryColor),
                ),

                // Center dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Info panel
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    'Arah Kiblat',
                    '${(_qiblaDirection ?? 0).toStringAsFixed(1)}°',
                  ),
                  _buildInfoItem(
                    'Heading',
                    '${(_currentHeading ?? 0).toStringAsFixed(1)}°',
                  ),
                  _buildInfoItem(
                    'Jarak',
                    '${(_distanceToKaaba ?? 0).toStringAsFixed(0)} km',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Arahkan perangkat hingga jarum hijau menunjuk ke utara',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCardinalDirections() {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return List.generate(8, (index) {
      final angle = index * 45.0;
      return Positioned(
        left: 150 + 120 * math.cos(angle * math.pi / 180) - 10,
        top: 150 + 120 * math.sin(angle * math.pi / 180) - 10,
        child: Text(
          directions[index],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
    });
  }

  List<Widget> _buildDegreeMarkings() {
    return List.generate(36, (index) {
      final angle = index * 10.0;
      final isMain = index % 9 == 0;
      return Positioned(
        left: 150 + 130 * math.cos(angle * math.pi / 180) - (isMain ? 1 : 0.5),
        top: 150 + 130 * math.sin(angle * math.pi / 180) - (isMain ? 1 : 0.5),
        child: Container(
          width: isMain ? 2 : 1,
          height: isMain ? 20 : 10,
          color: Colors.black,
        ),
      );
    });
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
