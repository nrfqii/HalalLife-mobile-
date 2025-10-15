// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../widgets/custom_widgets.dart';
import '../services/prayer_time_provider.dart';
import '../services/location_provider.dart';
import 'tasbih_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Get location when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final location = locationState.locationName.isNotEmpty
        ? locationState.locationName
        : 'Mendapatkan lokasi...';

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context, location),
          
          const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                SizedBox(height: 15),
                _MenuGrid(),
                SizedBox(height: 30),
                
                _ReminderCard(),
                SizedBox(height: 20),
                
                InfoCard(
                  title: 'Jadwal Sholat Hari Ini', 
                  child: _PrayerScheduleList(),
                ),
                
                // InfoCard(
                //   title: 'Amalan Harian',
                //   child: _AmalanHarianContent(),
                // ),
                
                InfoCard(
                  title: 'Dzikir Pagi & Petang', 
                  child: _DzikirContent(),
                ),
                
                InfoCard(
                  title: 'Kajian Rutin', 
                  child: _KajianList(),
                ),
                
                InfoCard(
                  title: 'Doa Pilihan',
                  child: _DoaPilihanContent(),
                ),
                
                InfoCard(
                  title: 'Tips Ibadah', 
                  child: _TipsContent(),
                ),
                
                _HaditsCard(),
                
                InfoCard(
                  title: 'Artikel Islami',
                  child: _ArtikelIslamiContent(),
                ),
                
                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String location) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kLightGreen, kMediumGreen],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20), 
          bottomRight: Radius.circular(20)
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20, 
              left: 20, 
              right: 20
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      location, 
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w500
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 15),

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
                      Icon(Icons.camera_alt_outlined, color: Color(0xFF999999), size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _PrayerCard(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ============== PRAYER CARD ==============

class _PrayerCard extends ConsumerStatefulWidget {
  const _PrayerCard();

  @override
  ConsumerState<_PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends ConsumerState<_PrayerCard> {
  String _currentTime = '';
  Duration _timeRemaining = const Duration(hours: 0);

  @override
  void initState() {
    super.initState();
    _updateTime();
    _updateCountdown();
    // Update time and countdown every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _updateTime();
        _updateCountdown();
      }
      return mounted;
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  void _updateCountdown() {
    final prayerState = ref.read(prayerTimeProvider);
    if (prayerState.nextPrayer != null) {
      final now = DateTime.now();
      final [hour, minute] = prayerState.nextPrayer!.time.split(':').map(int.parse).toList();
      final nextPrayerTime = DateTime(now.year, now.month, now.day, hour, minute);

      // If next prayer time has passed today, calculate for tomorrow
      final adjustedNextPrayerTime = nextPrayerTime.isAfter(now)
          ? nextPrayerTime
          : nextPrayerTime.add(const Duration(days: 1));

      setState(() {
        _timeRemaining = adjustedNextPrayerTime.difference(now);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use prayer times from provider
    final prayerState = ref.watch(prayerTimeProvider);
    final currentPrayer = prayerState.currentPrayer?.name ?? 'Dzuhur';
    final nextPrayer = prayerState.nextPrayer?.name ?? 'Ashar';
    final nextTime = prayerState.nextPrayer?.time ?? '15:18';

    // Use real-time countdown from state
    final timeRemaining = _timeRemaining;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2d5233), Color(0xFF1a3d24)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Opacity(
              opacity: 0.15,
              child: Icon(
                Icons.mosque,
                size: 120,
                color: Colors.white,
              ),
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Waktu Sekarang',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentPrayer,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      _currentTime,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.schedule,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sholat Berikutnya',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            nextPrayer,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            nextTime,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${timeRemaining.inHours}j ${timeRemaining.inMinutes % 60}m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============== MENU GRID ==============

class _MenuGrid extends StatelessWidget {
  const _MenuGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        _buildMenuItem(context, Icons.mosque, 'Masjid\nTerdekat', '/masjid-terdekat'),
        _buildMenuItem(context, Icons.event_note, 'Info\nKajian', '/info-kajian'),
        _buildMenuItem(context, Icons.shopping_basket, 'Makanan\nHalal', '/makanan-halal'),
        _buildMenuItem(context, Icons.radio_button_checked, 'Tasbih\nDigital', '/tasbih-digital', onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const TasbihDigitalScreen())
          );
        }),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String text, String route, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {
        Navigator.pushNamed(context, route);
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
              fontWeight: FontWeight.w500
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ============== REMINDER CARD ==============

class _ReminderCard extends StatelessWidget {
  const _ReminderCard();

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
              color: Colors.black.withOpacity(0.3)
            ),
          ),
          const Text(
            '"Sebaik-baik manusia adalah yang paling bermanfaat bagi orang lain."',
            style: TextStyle(
              color: Colors.white, 
              fontSize: 14, 
              height: 1.4
            ),
          ),
        ],
      ),
    );
  }
}

// ============== PRAYER SCHEDULE LIST ==============

class _PrayerScheduleList extends ConsumerWidget {
  const _PrayerScheduleList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerTimeProvider);

    if (prayerState.times.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: prayerState.times.map((prayer) => Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFf8fdf8),
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(color: kPrimaryColor, width: 4)
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              prayer.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333)
              )
            ),
            Text(
              prayer.time,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: kPrimaryColor
              )
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// ============== AMALAN HARIAN CONTENT ==============

// class _AmalanHarianContent extends StatelessWidget {
//   const _AmalanHarianContent();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildAmalanItem('✅', 'Sholat Subuh Berjamaah', true),
//         _buildAmalanItem('✅', 'Membaca Al-Quran', true),
//         _buildAmalanItem('⏳', 'Sholat Dhuha', false),
//         _buildAmalanItem('⏳', 'Sedekah', false),
//       ],
//     );
//   }

//   Widget _buildAmalanItem(String icon, String title, bool isDone) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: isDone ? const Color(0xFFE8F5E8) : const Color(0xFFf8fdf8),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: isDone ? kPrimaryColor.withOpacity(0.3) : const Color(0xFFe8f5e8),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Text(icon, style: const TextStyle(fontSize: 20)),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: isDone ? kPrimaryColor : const Color(0xFF666666),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ============== DZIKIR CONTENT ==============

class _DzikirContent extends StatelessWidget {
  const _DzikirContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DzikirItem(
          arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
          latin: 'Subhanallaahi wa bihamdihi, Subhanallaahil Azhim',
          meaning: 'Maha Suci Allah dan segala puji bagi-Nya, Maha Suci Allah Yang Maha Agung',
        ),
        SizedBox(height: 15),
        _DzikirItem(
          arabic: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
          latin: 'Allahumma ainni ala dzikrika wa syukrika wa husni' 'ibaadatika',
          meaning: 'Ya Allah, tolonglah aku untuk mengingat-Mu, bersyukur kepada-Mu, dan beribadah kepada-Mu dengan baik',
        ),
      ],
    );
  }
}

class _DzikirItem extends StatelessWidget {
  final String arabic;
  final String latin;
  final String meaning;

  const _DzikirItem({
    required this.arabic, 
    required this.latin, 
    required this.meaning
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
              fontFamily: 'Noto Naskh Arabic',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            latin,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontStyle: FontStyle.italic, 
              color: Color(0xFF666666)
            ),
          ),
          const SizedBox(height: 5),
          Text(
            meaning,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14, 
              color: Color(0xFF333333)
            ),
          ),
        ],
      ),
    );
  }
}

// ============== DOA PILIHAN CONTENT ==============

class _DoaPilihanContent extends StatelessWidget {
  const _DoaPilihanContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _DoaItem(
          title: 'Doa Sebelum Tidur',
          arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
          latin: 'Bismika Allahumma amuutu wa ahyaa',
          meaning: 'Dengan nama-Mu ya Allah aku mati dan aku hidup',
        ),
        SizedBox(height: 12),
        _DoaItem(
          title: 'Doa Bangun Tidur',
          arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
          latin: 'Alhamdulillahil-ladzi ahyana ba\'da ma amatana wa ilaihin nusyur',
          meaning: 'Segala puji bagi Allah yang telah menghidupkan kami setelah mematikan kami dan kepada-Nya kami akan kembali',
        ),
      ],
    );
  }
}

class _DoaItem extends StatelessWidget {
  final String title;
  final String arabic;
  final String latin;
  final String meaning;

  const _DoaItem({
    required this.title,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            arabic,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              fontFamily: 'Noto Naskh Arabic',
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            latin,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Color(0xFF666666),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            meaning,
            style: const TextStyle(
              fontSize: 13, 
              color: Color(0xFF333333)
            ),
          ),
        ],
      ),
    );
  }
}

// ============== KAJIAN LIST ==============

class _KajianList extends StatelessWidget {
  const _KajianList();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> kajian = [
      {
        'title': 'Kajian Rutin Hari Senin', 
        'ustadz': 'Ustadz Ridwan Abu Ubaidillah', 
        'time': 'Setiap Senin, Ba\'da Maghrib 18:10 WIB', 
        'location': 'Masjid Imam Asy-Syafi\'i, Pekalongan'
      },
      {
        'title': 'Kajian Rutin Hari Selasa', 
        'ustadz': 'Ustadz Adam Daud, LC.', 
        'time': 'Setiap Selasa, Ba\'da Maghrib 18:10 WIB', 
        'location': 'Masjid \'Aisyah, Pekalongan'
      },
      {
        'title': 'Kajian Rutin Hari Kamis', 
        'ustadz': 'Ustadz Faiz Abdillah, Lc, M.E', 
        'time': 'Setiap Kamis, Ba\'da Maghrib 18:10 WIB', 
        'location': 'Masjid At-Taqwa Pekajangan'
      },
    ];
    
    return Column(
      children: kajian.map((k) => Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFf8fdf8),
          borderRadius: BorderRadius.circular(10),
          border: const Border(
            left: BorderSide(color: kPrimaryColor, width: 4)
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              k['title']!, 
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                color: Color(0xFF333333), 
                fontSize: 16
              )
            ),
            const SizedBox(height: 5),
            Text(
              k['ustadz']!, 
              style: const TextStyle(
                color: kPrimaryColor, 
                fontWeight: FontWeight.w600, 
                fontSize: 14
              )
            ),
            const SizedBox(height: 3),
            Text(
              k['time']!, 
              style: const TextStyle(
                color: Color(0xFF666666), 
                fontSize: 14
              )
            ),
            Text(
              k['location']!, 
              style: const TextStyle(
                color: Color(0xFF999999), 
                fontSize: 13
              )
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// ============== TIPS CONTENT ==============

class _TipsContent extends StatelessWidget {
  const _TipsContent();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tips = [
      {
        'icon': '📿', 
        'title': 'Jangan Lupa Dzikir', 
        'desc': 'Perbanyak dzikir setelah sholat untuk mendekatkan diri kepada Allah'
      },
      {
        'icon': '🤲', 
        'title': 'Doa Sebelum Tidur', 
        'desc': 'Membaca doa sebelum tidur akan mendapat perlindungan Allah'
      },
      {
        'icon': '📖', 
        'title': 'Baca Al-Quran', 
        'desc': 'Minimal 1 halaman setiap hari untuk menjaga hubungan dengan Allah'
      },
      {
        'icon': '🕌', 
        'title': 'Sholat Berjamaah', 
        'desc': 'Sholat berjamaah memiliki pahala 27 derajat lebih utama'
      },
    ];
    
    return Column(
      children: tips.map((t) => Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFf8fdf8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFe8f5e8), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t['icon']!, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['title']!, 
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: kPrimaryColor, 
                      fontSize: 14
                    )
                  ),
                  const SizedBox(height: 5),
                  Text(
                    t['desc']!, 
                    style: const TextStyle(
                      color: Color(0xFF333333), 
                      fontSize: 14, 
                      height: 1.4
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// ============== HADITS CARD ==============

class _HaditsCard extends StatelessWidget {
  const _HaditsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFf8fdf8), Color(0xFFe8f5e8)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        children: [
          Text(
            '"Barangsiapa yang beriman kepada Allah dan hari akhir, hendaklah ia berkata baik atau diam."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16, 
              fontStyle: FontStyle.italic, 
              color: Color(0xFF333333), 
              height: 1.6
            ),
          ),
          SizedBox(height: 15),
          Text(
            'HR. Bukhari & Muslim',
            style: TextStyle(
              fontSize: 12, 
              color: kPrimaryColor, 
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }
}

// ============== ARTIKEL ISLAMI CONTENT ==============

class _ArtikelIslamiContent extends StatelessWidget {
  const _ArtikelIslamiContent();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> articles = [
      {
        'title': 'Keutamaan Membaca Al-Quran',
        'desc': 'Pahala dan manfaat membaca Al-Quran dalam kehidupan sehari-hari',
        'date': '5 Okt 2025'
      },
      {
        'title': 'Adab Berdoa dalam Islam',
        'desc': 'Tata cara dan waktu-waktu mustajab untuk berdoa',
        'date': '4 Okt 2025'
      },
      {
        'title': 'Hikmah Puasa Sunnah',
        'desc': 'Manfaat spiritual dan kesehatan dari puasa sunnah',
        'date': '3 Okt 2025'
      },
    ];

    return Column(
      children: articles.map((article) => Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFf8fdf8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFe8f5e8), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              article['desc']!,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 12, color: Color(0xFF999999)),
                const SizedBox(width: 5),
                Text(
                  article['date']!,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }
}


