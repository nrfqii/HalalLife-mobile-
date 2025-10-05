// main.dart - UPDATE untuk modal kiblat
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/qibla_screen.dart'; // Import screen kiblat baru
import 'services/location_provider.dart';
import 'services/prayer_time_provider.dart';

// Definisi Warna Global
const Color kPrimaryColor = Color(0xFF4a7c59);
const Color kLightGreen = Color(0xFFA8D5A8);
const Color kMediumGreen = Color(0xFF7CB97C);
const Color kBackgroundColor = Color(0xFFf5f5f5);

void main() {
  runApp(
    const ProviderScope(child: HalalLifeApp()),
  );
}

class HalalLifeApp extends StatelessWidget {
  const HalalLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halal Life',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        useMaterial3: false,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainLayout(),
        '/quran': (context) => const QuranScreen(),
        '/qibla': (context) => const QiblaScreen(), // Route untuk kiblat
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref.read(locationProvider.notifier).getCurrentLocation();
        ref.read(prayerTimeProvider.notifier).fetchTimes(0.0, 0.0);
      } catch (_) {}
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const QuranScreen(),
    Container(color: Colors.white), // Placeholder untuk Kiblat
    const SettingsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _showWelcomeModal(context);
              },
              backgroundColor: kPrimaryColor,
              shape: const CircleBorder(),
              elevation: 6.0,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      height: 85,
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.home, 'Beranda', '/'),
          _navItem(1, Icons.menu_book, 'Al-Quran', '/quran'),
          _navItem(2, Icons.explore, 'Kiblat', '/qibla', isQibla: true),
          _navItem(3, Icons.settings, 'Pengaturan', '/settings'),
          _navItem(4, Icons.person, 'Profil', '/profile'),
        ],
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    String text,
    String? route, {
    bool isQibla = false,
  }) {
    final bool isActive = _currentIndex == index;
    final Color color = isActive ? kPrimaryColor : const Color(0xFF666666);

    return InkWell(
      onTap: () {
        if (isQibla) {
          // Navigasi langsung ke halaman kiblat
          Navigator.pushNamed(context, '/qibla');
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 5),
          Text(text, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  void _showWelcomeModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4a7c59), Color(0xFF2d5233)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.7),
                      size: 24,
                    ),
                  ),
                ),
                Icon(
                  Icons.mosque,
                  size: 40,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Assalamualaikum',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Divider(
                  color: Colors.white.withOpacity(0.2),
                  thickness: 2,
                  height: 20,
                ),
                const Text(
                  'Pengguna Halal Life, Jangan lupa baca Al-Quran hari ini!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}