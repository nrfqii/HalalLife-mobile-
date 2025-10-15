// lib/services/location_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationState {
  final String locationName;
  final double latitude;
  final double longitude;
  final bool isLoading;
  final String? error;

  LocationState({
    required this.locationName,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.isLoading = true,
    this.error,
  });

  LocationState copyWith({
    String? locationName,
    double? latitude,
    double? longitude,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier()
    : super(LocationState(locationName: 'Mendapatkan lokasi...'));

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get place name from coordinates using reverse geocoding
      String locationName = 'Lokasi Tidak Diketahui';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        bool filled = false;
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;

          // Collect candidate fields in preference order
          final List<String?> candidates = [
            place.locality,
            place.subLocality,
            place.subAdministrativeArea,
            place.administrativeArea,
            place.name,
            place.country,
          ];

          // Filter non-empty trimmed values
          final List<String> parts = candidates
              .where((c) => c != null && c.trim().isNotEmpty)
              .map((c) => c!.trim())
              .toList();

          if (parts.isNotEmpty) {
            if (parts.length >= 2) {
              final first = parts[0];
              String second = parts[1];
              if (second.toLowerCase() == first.toLowerCase() &&
                  parts.length >= 3) {
                second = parts[2];
              }
              locationName = '$first, $second';
            } else {
              locationName = parts.first;
            }
            filled = true;
          }
        }

        // If not filled (common on web), try HTTP reverse geocoding (Nominatim)
        if (!filled) {
          try {
            final uri = Uri.parse(
              'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}&accept-language=id',
            );
            final response = await http.get(
              uri,
              headers: {'User-Agent': 'HalalLifeApp/1.0'},
            );
            if (response.statusCode == 200) {
              final data = jsonDecode(response.body) as Map<String, dynamic>;
              final address = data['address'] as Map<String, dynamic>?;
              if (address != null) {
                final String? city =
                    address['city'] as String? ??
                    address['town'] as String? ??
                    address['village'] as String? ??
                    address['municipality'] as String? ??
                    address['county'] as String?;
                final String? state =
                    address['state'] as String? ?? address['region'] as String?;
                if (city != null && state != null) {
                  locationName = '${city.trim()}, ${state.trim()}';
                  filled = true;
                } else if (city != null) {
                  locationName = city.trim();
                  filled = true;
                } else if (state != null) {
                  locationName = state.trim();
                  filled = true;
                }
              }
            }
          } catch (_) {
            // ignore nominatim errors, keep friendly message
          }
        }

        if (!filled) {
          locationName = 'Lokasi Tidak Diketahui';
        }
      } catch (e) {
        // Reverse geocoding failed; try HTTP fallback then keep friendly message
        try {
          final uri = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}&accept-language=id',
          );
          final response = await http.get(
            uri,
            headers: {'User-Agent': 'HalalLifeApp/1.0'},
          );
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            final address = data['address'] as Map<String, dynamic>?;
            if (address != null) {
              final String? city =
                  address['city'] as String? ??
                  address['town'] as String? ??
                  address['village'] as String? ??
                  address['municipality'] as String? ??
                  address['county'] as String?;
              final String? state =
                  address['state'] as String? ?? address['region'] as String?;
              if (city != null && state != null) {
                locationName = '${city.trim()}, ${state.trim()}';
              } else if (city != null) {
                locationName = city.trim();
              } else if (state != null) {
                locationName = state.trim();
              } else {
                locationName = 'Lokasi Tidak Diketahui';
              }
            }
          }
        } catch (_) {
          locationName = 'Lokasi Tidak Diketahui';
        }
      }

      state = state.copyWith(
        locationName: locationName,
        latitude: position.latitude,
        longitude: position.longitude,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        locationName: e.toString().contains('denied')
            ? 'Izin Lokasi Ditolak'
            : 'Gagal mendapatkan lokasi',
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) {
    return LocationNotifier();
  },
);
