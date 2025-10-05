// lib/models/prayer_time.dart
class PrayerTime {
  final String name;
  final String time;

  PrayerTime({required this.name, required this.time});

  factory PrayerTime.fromJson(String name, String time) {
    // API may return times with extra characters like (IST) or spaces, keep basic HH:mm
    final cleaned = time.split(' ').first;
    return PrayerTime(name: name, time: cleaned);
  }

  static List<PrayerTime> get dummyList => [
    PrayerTime(name: 'Subuh', time: '04:30'),
    PrayerTime(name: 'Dzuhur', time: '12:00'),
    PrayerTime(name: 'Ashar', time: '15:15'),
    PrayerTime(name: 'Maghrib', time: '18:00'),
    PrayerTime(name: 'Isya', time: '19:15'),
  ];
}
