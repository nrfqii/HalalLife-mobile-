// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../widgets/custom_widgets.dart';
import '../providers/theme_provider.dart';
import '../providers/quran_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final quranState = ref.watch(quranProvider);
    final currentQori = quranState.selectedQori;
    final qoriMap = ref.read(quranProvider.notifier).availableQori();
    final currentQoriName = qoriMap[currentQori] ?? 'Default';

    return SingleChildScrollView(
      child: Column(
        children: [
          // Menggantikan Header yang di-extend di Blade
          _buildMinimalHeader(context, 'Pengaturan'),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Info Card: Pengaturan Aplikasi
                InfoCard(
                  title: 'Pengaturan Aplikasi',
                  child: Column(
                    children: [
                      _buildSettingItem(
                        title: 'Notifikasi Sholat',
                        trailing: CustomSwitch(
                          value: true,
                          onChanged: (val) {
                            // Logika ubah state notifikasi
                          },
                        ),
                      ),
                      _buildSettingItem(
                        title: 'Mode Gelap',
                        trailing: CustomSwitch(
                          value: isDarkMode,
                          onChanged: (val) {
                            ref.read(themeProvider.notifier).toggleTheme();
                          },
                        ),
                      ),
                      _buildSettingItem(
                        title: 'Qori Tilawah',
                        trailing: Text(
                          currentQoriName,
                          style: const TextStyle(color: Color(0xFF666666)),
                        ),
                        onTap: () async {
                          final selected = await showModalBottomSheet<String?>(
                            context: context,
                            builder: (ctx) {
                              return ListView(
                                shrinkWrap: true,
                                children: qoriMap.entries
                                    .map(
                                      (e) => ListTile(
                                        title: Text(e.value),
                                        onTap: () => Navigator.of(ctx).pop(e.key),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          );

                          if (selected != null) {
                            ref.read(quranProvider.notifier).changeQori(selected);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Qori dipilih: ${qoriMap[selected]}')),
                            );
                          }
                        },
                      ),
                      _buildSettingItem(
                        title: 'Ganti Lokasi',
                        trailing: const Text(
                          'Ubah',
                          style: TextStyle(
                            color: kPrimaryColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Aksi Ganti Lokasi')),
                        ),
                      ),
                      _buildSettingItem(
                        title: 'Bahasa',
                        trailing: const Text(
                          'Indonesia',
                          style: TextStyle(color: Color(0xFF666666)),
                        ),
                      ),
                      _buildSettingItem(
                        title: 'Tentang Aplikasi',
                        trailing: const Text(
                          'Lihat',
                          style: TextStyle(
                            color: kPrimaryColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Aksi Lihat Tentang Aplikasi'),
                          ),
                        ),
                      ),
                      _buildSettingItem(
                        title: 'Beri Rating',
                        trailing: const Text(
                          '⭐ ⭐ ⭐ ⭐ ⭐',
                          style: TextStyle(
                            color: kPrimaryColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Aksi Beri Rating')),
                        ),
                      ),
                    ],
                  ),
                ),

                // Info Card: Akun
                InfoCard(
                  title: 'Akun',
                  child: Column(
                    children: [
                      _buildSettingItem(
                        title: 'Ganti Password',
                        trailing: const Text(
                          'Atur',
                          style: TextStyle(
                            color: kPrimaryColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Aksi Ganti Password')),
                        ),
                      ),
                      _buildSettingItem(
                        title: 'Keluar',
                        trailing: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Color(0xFFe74c3c),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Aksi Logout')),
                        ),
                      ),
                    ],
                  ),
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
    // Header minimalis untuk halaman non-beranda
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

  Widget _buildSettingItem({
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    // Mereplikasi .setting-item
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFEEEEEE),
              width: 1.0,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
