// lib/services/location_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

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
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // For city name, you might need reverse geocoding, but skipping for now
      final name = 'Lokasi Saat Ini';

      state = state.copyWith(
        locationName: name,
        latitude: position.latitude,
        longitude: position.longitude,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        locationName: e.toString().contains('Izin') ? 'Izin Lokasi Ditolak' : 'Gagal mendapatkan lokasi',
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});
