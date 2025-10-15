// lib/screens/kajian_screen.dart
import 'package:flutter/material.dart';

class KajianScreen extends StatelessWidget {
  const KajianScreen({super.key});

  final List<Map<String, String>> kajianData = const [
    {
      "judul": "Makna Tawakal",
      "ustadz": "Ust. Ahmad Fauzi",
      "waktu": "Minggu, 20 Okt 2025 - 09:00",
      "lokasi": "Masjid Al-Falah"
    },
    {
      "judul": "Tafsir Surah Al-Mulk",
      "ustadz": "Ust. Fulan",
      "waktu": "Sabtu, 19 Okt 2025 - 19:00",
      "lokasi": "Masjid Al-Hidayah"
    },
    {
      "judul": "Fiqih Muamalah Modern",
      "ustadz": "Ust. Budi Santoso",
      "waktu": "Jumat, 18 Okt 2025 - 19:30",
      "lokasi": "Masjid Nurul Iman"
    },
    {
      "judul": "Kewajiban Puasa Ramadhan",
      "ustadz": "Ust. Rian Abdullah",
      "waktu": "Kamis, 17 Okt 2025 - 20:00",
      "lokasi": "Masjid Al-Ikhlas"
    },
    {
      "judul": "Hadits tentang Sabar",
      "ustadz": "Ust. Hasan Basri",
      "waktu": "Rabu, 16 Okt 2025 - 19:15",
      "lokasi": "Masjid Al-Muhajirin"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Kajian'),
        backgroundColor: const Color(0xFF4a7c59),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kajianData.length,
        itemBuilder: (context, index) {
          final kajian = kajianData[index];
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
                      const Icon(Icons.menu_book, color: Color(0xFF4a7c59), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          kajian['judul']!,
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
                    kajian['ustadz']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4a7c59),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Color(0xFF999999)),
                      const SizedBox(width: 4),
                      Text(
                        kajian['waktu']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFF999999)),
                      const SizedBox(width: 4),
                      Text(
                        kajian['lokasi']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // No functionality as requested
                      },
                      child: const Text(
                        'Detail',
                        style: TextStyle(color: Color(0xFF4a7c59)),
                      ),
                    ),
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