// lib/screens/makanan_screen.dart
import 'package:flutter/material.dart';

class MakananScreen extends StatelessWidget {
  const MakananScreen({super.key});

  final List<Map<String, dynamic>> makananData = const [
    {
      "nama": "Warung Halal Nusantara",
      "alamat": "Jl. Veteran No.10",
      "sertifikasi": true,
      "rating": 4.8,
    },
    {
      "nama": "Ayam Geprek Barokah",
      "alamat": "Jl. Merdeka No.5",
      "sertifikasi": true,
      "rating": 4.5,
    },
    {
      "nama": "Resto Padang Minang Halal",
      "alamat": "Jl. Pemuda No.8",
      "sertifikasi": true,
      "rating": 4.7,
    },
    {
      "nama": "Nasi Gudeg Jogja Halal",
      "alamat": "Jl. Malioboro No.15",
      "sertifikasi": true,
      "rating": 4.6,
    },
    {
      "nama": "Bakso Halal Pak Min",
      "alamat": "Jl. Sudirman No.22",
      "sertifikasi": false,
      "rating": 4.2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Makanan Halal'),
        backgroundColor: const Color(0xFF4a7c59),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: makananData.length,
        itemBuilder: (context, index) {
          final makanan = makananData[index];
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
                      const Icon(Icons.restaurant, color: Color(0xFF4a7c59), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          makanan['nama'],
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
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFF999999)),
                      const SizedBox(width: 4),
                      Text(
                        makanan['alamat'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: makanan['sertifikasi'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          makanan['sertifikasi'] ? '✅ Bersertifikat' : '❌ Tidak Bersertifikat',
                          style: TextStyle(
                            fontSize: 12,
                            color: makanan['sertifikasi'] ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            makanan['rating'].toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
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
                        'Lihat Detail',
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