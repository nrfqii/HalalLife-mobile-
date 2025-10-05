// lib/widgets/home_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/prayer_time.dart';
import '../services/prayer_time_provider.dart';
import '../services/location_provider.dart';

// --- Header Widgets ---

class PrayerTimeHeader extends ConsumerWidget {
  const PrayerTimeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);

    // Header (Replikasi Div Header Laravel)
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kLightGreen, kMediumGreen], // Gradien Laravel Header
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lokasi Info
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                locationState.locationName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.9),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: TextStyle(fontSize: 16, color: Color(0xFF999999)),
                  ),
                ),
                Icon(Icons.search, color: Color(0xFF999999), size: 20),
                SizedBox(width: 10),
                Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF999999),
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Prayer Card
          const PrayerCard(),
        ],
      ),
    );
  }
}

class PrayerCard extends ConsumerWidget {
  const PrayerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerTimeProvider);

    String currentPrayerName = prayerState.currentPrayer?.name ?? "Memuat...";
    String currentTime = prayerState.currentPrayer?.time ?? "--:--";
    String nextPrayerInfo = prayerState.nextPrayer != null
        ? "Next Pray: ${prayerState.nextPrayer!.name}\n${prayerState.nextPrayer!.time} AM/PM"
        : "Memuat jadwal sholat...";

    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4a7c59), Color(0xFF2d5233)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          // Placeholder Mosque Silhouette (Custom Painter yang kompleks diabaikan)
          const Positioned(
            right: -20,
            bottom: -5,
            child: Icon(Icons.mosque, size: 80, color: Colors.black38),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentPrayerName,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
              Text(
                currentTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                nextPrayerInfo,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Content Widgets ---

class MenuGrid extends StatelessWidget {
  const MenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        _buildMenuItem(context, Icons.mosque, 'Masjid Terdekat'),
        _buildMenuItem(context, Icons.event_note, 'Info Kajian'),
        _buildMenuItem(context, Icons.shopping_basket, 'Makanan Halal'),
        _buildMenuItem(context, Icons.star, 'Zakat'),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String text) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Navigasi ke $text')));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kPrimaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class PrayerScheduleList extends ConsumerWidget {
  const PrayerScheduleList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerTimeProvider);
    final List<PrayerTime> prayers = (prayerState.times.isEmpty)
        ? PrayerTime.dummyList
        : prayerState.times;

    return Column(
      children: prayers
          .map(
            (p) => Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFf8fdf8),
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: kPrimaryColor, width: 4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Text(
                    p.time,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class ReminderCard extends StatelessWidget {
  const ReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6b9b7a), Color(0xFF4a7c5a)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            bottom: 10,
            child: Icon(
              Icons.check_circle,
              size: 40,
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          const Text(
            '"Sebaik-baik manusia adalah yang paling bermanfaat bagi orang lain."',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class DzikirContent extends StatelessWidget {
  const DzikirContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DzikirItem(
          arabic:
              'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
          latin: 'Subhanallaahi wa bihamdihi, Subhanallaahil ‘Azhim',
          meaning:
              'Maha Suci Allah dan segala puji bagi-Nya, Maha Suci Allah Yang Maha Agung',
        ),
        SizedBox(height: 15),
        DzikirItem(
          arabic:
              'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
          latin:
              'Allahumma a’inni ‘ala dzikrika wa syukrika wa husni ‘ibaadatika',
          meaning:
              'Ya Allah, tolonglah aku untuk mengingat-Mu, bersyukur kepada-Mu, dan beribadah kepada-Mu dengan baik',
        ),
      ],
    );
  }
}

class DzikirItem extends StatelessWidget {
  final String arabic;
  final String latin;
  final String meaning;

  const DzikirItem({
    super.key,
    required this.arabic,
    required this.latin,
    required this.meaning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fdf8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFe8f5e8), width: 1),
      ),
      child: Column(
        children: [
          Text(
            arabic,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
              fontFamily: 'Noto Naskh Arabic', // Asumsikan font sudah diatur
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            latin,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            meaning,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
          ),
        ],
      ),
    );
  }
}
