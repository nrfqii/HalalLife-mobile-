// lib/providers/prayer_time_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prayer_time.dart';
import '../services/prayer_api_service.dart';
import 'location_provider.dart';

class PrayerTimeState {
  final List<PrayerTime> times;
  final PrayerTime? currentPrayer;
  final PrayerTime? nextPrayer;
  final bool isLoading;
  final String? error;

  PrayerTimeState({
    this.times = const [],
    this.currentPrayer,
    this.nextPrayer,
    this.isLoading = true,
    this.error,
  });

  PrayerTimeState copyWith({
    List<PrayerTime>? times,
    PrayerTime? currentPrayer,
    PrayerTime? nextPrayer,
    bool? isLoading,
    String? error,
  }) {
    return PrayerTimeState(
      times: times ?? this.times,
      currentPrayer: currentPrayer ?? this.currentPrayer,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PrayerTimeNotifier extends StateNotifier<PrayerTimeState> {
  final PrayerApiService _service;
  final Ref _ref;

  PrayerTimeNotifier(this._service, this._ref) : super(PrayerTimeState()) {
    // Dengarkan perubahan lokasi
    _ref.listen<LocationState>(locationProvider, (previous, next) {
      if (!next.isLoading && next.error == null) {
        fetchTimes(next.latitude, next.longitude);
      }
    });
  }

  Future<void> fetchTimes(double lat, double lon) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final times = await _service.fetchPrayerTimes(lat, lon);
      
      // Logika penentuan waktu sholat berikutnya
      final now = DateTime.now();
      PrayerTime? nextP;
      PrayerTime? currentP;
      
      for (var time in times) {
        final [hour, minute] = time.time.split(':').map((e) => int.parse(e)).toList();
        final prayerTime = DateTime(now.year, now.month, now.day, hour, minute);
        
        if (prayerTime.isAfter(now) && nextP == null) {
          nextP = time;
          // Asumsi sholat saat ini adalah sholat sebelumnya (atau sholat terakhir jika ini sholat pertama hari itu)
          final index = times.indexOf(time);
          currentP = index > 0 ? times[index - 1] : times.last; 
        }
      }
      
      if (nextP == null) {
        // Jika semua sholat hari ini sudah berlalu, sholat berikutnya adalah sholat Subuh esok hari
        nextP = times.first;
        currentP = times.last;
      }

      state = state.copyWith(
        times: times,
        currentPrayer: currentP,
        nextPrayer: nextP,
        isLoading: false,
      );

    } catch (e) {
      state = state.copyWith(
        times: PrayerTime.dummyList,
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final prayerTimeProvider = StateNotifierProvider<PrayerTimeNotifier, PrayerTimeState>((ref) {
  return PrayerTimeNotifier(PrayerApiService(), ref);
});