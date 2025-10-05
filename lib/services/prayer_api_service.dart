// lib/services/prayer_api_service.dart
import 'package:dio/dio.dart';
import '../models/prayer_time.dart';

class PrayerApiService {
  final Dio _dio = Dio();
  // Menggunakan API Aladhan
  static const String baseUrl = 'https://api.aladhan.com/v1';

  Future<List<PrayerTime>> fetchPrayerTimes(double lat, double lon) async {
    // API ini memerlukan lat, lon, dan tanggal (atau bulan/tahun untuk kalender)
    final date = DateTime.now();
    final url = '$baseUrl/calendar/${date.year}/${date.month}';

    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'method': 2, // Kemenag, Indonesia
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> todayData =
            response.data['data'][date.day - 1]['timings'];

        // Memfilter dan memetakan data ke model PrayerTime
        return [
          PrayerTime.fromJson('Subuh', todayData['Fajr']),
          PrayerTime.fromJson('Dzuhur', todayData['Dhuhr']),
          PrayerTime.fromJson('Ashar', todayData['Asr']),
          PrayerTime.fromJson('Maghrib', todayData['Maghrib']),
          PrayerTime.fromJson('Isya', todayData['Isha']),
        ];
      }
      return Future.error('Gagal mengambil jadwal sholat dari API.');
    } catch (e) {
      // Jika error, gunakan data dummy
      return Future.value(PrayerTime.dummyList);
    }
  }
}
