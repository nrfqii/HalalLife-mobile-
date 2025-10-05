// lib/services/qibla_service.dart
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class QiblaService {
  // Koordinat Ka'bah
  static const double kaabaLat = 21.4225;
  static const double kaabaLon = 39.8262;

  /// Menghitung arah kiblat dari posisi user ke Ka'bah
  /// Menggunakan formula Spherical Law of Cosines
  static double calculateQiblaDirection(double userLat, double userLon) {
    // Konversi ke radian
    final double lat1 = _toRadians(userLat);
    final double lon1 = _toRadians(userLon);
    final double lat2 = _toRadians(kaabaLat);
    final double lon2 = _toRadians(kaabaLon);

    // Menghitung bearing (sudut) menggunakan formula
    final double dLon = lon2 - lon1;
    
    final double y = math.sin(dLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    
    double bearing = math.atan2(y, x);
    
    // Konversi dari radian ke derajat
    bearing = _toDegrees(bearing);
    
    // Normalisasi ke 0-360
    bearing = (bearing + 360) % 360;
    
    return bearing;
  }

  /// Menghitung jarak ke Ka'bah (dalam kilometer)
  static double calculateDistanceToKaaba(double userLat, double userLon) {
    return Geolocator.distanceBetween(
      userLat,
      userLon,
      kaabaLat,
      kaabaLon,
    ) / 1000; // Konversi meter ke kilometer
  }

  /// Stream untuk mendapatkan heading kompas device
  static Stream<double>? getCompassHeading() {
    return FlutterCompass.events?.map((event) => event.heading ?? 0.0);
  }

  /// Konversi derajat ke radian
  static double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Konversi radian ke derajat
  static double _toDegrees(double radians) {
    return radians * 180 / math.pi;
  }

  /// Mendapatkan arah kompas dalam bentuk string (N, NE, E, dst)
  static String getCompassDirection(double heading) {
    if (heading >= 337.5 || heading < 22.5) return 'N';
    if (heading >= 22.5 && heading < 67.5) return 'NE';
    if (heading >= 67.5 && heading < 112.5) return 'E';
    if (heading >= 112.5 && heading < 157.5) return 'SE';
    if (heading >= 157.5 && heading < 202.5) return 'S';
    if (heading >= 202.5 && heading < 247.5) return 'SW';
    if (heading >= 247.5 && heading < 292.5) return 'W';
    if (heading >= 292.5 && heading < 337.5) return 'NW';
    return 'N';
  }
}