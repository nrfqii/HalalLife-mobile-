// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../widgets/custom_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMinimalHeader(context, 'Profil Pengguna'),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Info Card: Profil Saya
                InfoCard(
                  title: 'Profil Saya',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileHeader(context),
                      const Divider(color: Color(0xFFEEEEEE), height: 40),
                      ElevatedButton(
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Aksi Edit Profil')),
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Edit Profil',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                // Info Card: Aktivitas Terbaru
                const InfoCard(
                  title: 'Aktivitas Terbaru',
                  child: _ActivityList(),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalHeader(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        // Profile Icon Wrapper
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E8),
            shape: BoxShape.circle,
            border: Border.all(color: kPrimaryColor, width: 3),
          ),
          child: const Icon(Icons.person, size: 70, color: kPrimaryColor),
        ),
        const SizedBox(height: 20),

        // Profile Detail
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDetailItem('Nama', 'Fulan bin Fulan'),
            _buildDetailItem('Email', 'Fulan@example.com'),
            _buildDetailItem('Lokasi', 'Pekalongan, Jawa Tengah'),
            _buildDetailItem('Bergabung Sejak', '16 Juli 2025'),
          ],
        ),
      ],
    );
  }

  static Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(width: 5),
          Text(value, style: const TextStyle(color: Color(0xFF555555))),
        ],
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList();

  @override
  Widget build(BuildContext context) {
    final List<String> activities = [
      'Mencatat dzikir pagi.',
      'Menyelesaikan bacaan Al-Quran juz 2.',
      'Melihat jadwal kajian Ustadz Faiz.',
    ];

    return Column(
      children: activities
          .map(
            (activity) => Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: activities.last != activity
                    ? const Border(
                        bottom: BorderSide(
                          color: Color(0xFFEEEEEE),
                          width: 1.0,
                          style: BorderStyle.solid,
                        ),
                      )
                    : null,
              ),
              child: Text(
                activity,
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
            ),
          )
          .toList(),
    );
  }
}
