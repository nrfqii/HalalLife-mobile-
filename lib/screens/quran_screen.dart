// screens/quran_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../widgets/custom_widgets.dart';
import '../providers/quran_provider.dart';
import '../models/surah.dart';

// Use shared Surah model from models/surah.dart
final List<Surah> dummySurahs = Surah.dummyList;

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  bool _isDetailView = false;
  // selected surah is managed by the provider
  String _searchQuery = '';

  // Audio Player state akan dikelola oleh Provider jika ini bukan demo

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trigger one-time fetch of surah list
      ref.read(quranProvider.notifier).fetchSurahList();
    });
  }

  void _openSurahDetail(Surah surah) {
    // meminta provider untuk mengambil detail surah
    ref.read(quranProvider.notifier).selectSurah(surah.number);
    setState(() {
      _isDetailView = true;
    });
  }

  void _backToList() {
    setState(() {
      _isDetailView = false;
    });
    // clear selected surah in provider
    ref.read(quranProvider.notifier).clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final quranState = ref.watch(quranProvider);
    final allSurahs = quranState.surahList.isEmpty
        ? dummySurahs
        : quranState.surahList;
    final filteredSurahs = allSurahs.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.nameLatin.toLowerCase().contains(q) ||
          s.translation.toLowerCase().contains(q) ||
          s.nameArabic.toLowerCase().contains(q) ||
          s.number.toString().contains(q);
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          // Header (Diambil dari Quran Blade, tanpa Prayer Card)
          _buildHeader(context, 'Kajen, Jawa Tengah'),

          if (_isDetailView)
            _buildStickyControls(), // Sticky Controls hanya di Detail View

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: InfoCard(
                  title: _isDetailView
                      ? 'Detail Surah'
                      : 'Daftar Surah Al-Quran',
                  child: quranState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _isDetailView
                      ? _buildSurahDetailContent()
                      : _buildSurahListContent(filteredSurahs),
                ),
              ),
            ),
          ),
        ],
      ),
      // Floating Audio Button
      floatingActionButton: _isDetailView
          ? FloatingActionButton(
              onPressed: () {
                // toggle play/pause via provider
                ref.read(quranProvider.notifier).togglePlayPause();
              },
              backgroundColor: kPrimaryColor,
              shape: const CircleBorder(),
              elevation: 6.0,
              child: Icon(
                quranState.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader(BuildContext context, String location) {
    // Replikasi Div Header dengan Search Bar
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
          colors: [kLightGreen, kMediumGreen],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
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
                  fontWeight: FontWeight.w500,
                ),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: 'Cari Surah',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF999999),
                    ),
                  ),
                ),
                const Icon(Icons.search, color: Color(0xFF999999), size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahListContent(List<Surah> surahs) {
    return Column(children: surahs.map((s) => _buildSurahItem(s)).toList());
  }

  Widget _buildSurahItem(Surah surah) {
    return InkWell(
      onTap: () => _openSurahDetail(surah),
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FDF8),
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(color: kPrimaryColor, width: 4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.nameLatin,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E8B57),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Indonesian name / translation and meta
                  Text(
                    '${surah.translation.isNotEmpty ? surah.translation : '-'} • ${surah.versesCount} ayat • ${surah.revelation}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              surah.nameArabic,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 22,
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahDetailContent() {
    final quranState = ref.watch(quranProvider);
    if (quranState.selectedSurah == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final Surah surah = quranState.selectedSurah!;
    final List<Verse> versesList = (surah.versesList.isNotEmpty)
        ? surah.versesList
        : Verse.dummyVerses(surah.number, surah.versesCount);
    final bool showBismillah = surah.number != 1 && surah.number != 9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${surah.nameLatin} (${surah.translation})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E8B57),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '${surah.revelation} • ${surah.versesCount} ayat',
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          textAlign: TextAlign.center,
        ),
        Text(
          surah.nameArabic,
          style: GoogleFonts.notoNaskhArabic(
            fontSize: 32,
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        if (showBismillah)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Text(
              'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E8B57),
              ),
            ),
          ),

        const Divider(color: Color(0xFFEEEEEE)),

        // Daftar Ayat
        ...versesList.map((v) => _buildVerseItem(v)).toList(),
      ],
    );
  }

  // Kontrol Tilawah di Detail Surah
  Widget _buildStickyControls() {
    final quranState = ref.watch(quranProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFf0fdf0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFd4ecd4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _backToList,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali ke Daftar Surah'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () async {
              // Panggil Modal Qori
              final qoriMap = ref.read(quranProvider.notifier).availableQori();
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
            icon: const Icon(Icons.person),
            label: const Text('Pilih Qori'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Play/pause via provider
                  ref.read(quranProvider.notifier).togglePlayPause();
                },
                icon: Icon(
                  quranState.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                label: const Text('Putar Tilawah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              // Tambahkan tombol Jeda jika audio sedang diputar
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerseItem(Verse verse) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fdf8),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${verse.inSurah}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            verse.arabic,
            textAlign: TextAlign.right,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 24,
              height: 1.8,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '(${verse.translation})',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Color(0xFF666666),
              fontSize: 14,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(
                Icons.play_circle_fill,
                color: kPrimaryColor,
                size: 36,
              ),
              onPressed: () {
                // Play per ayat via provider (verse.inSurah is 1-based)
                ref.read(quranProvider.notifier).playVerse(verse.inSurah - 1);
              },
            ),
          ),
        ],
      ),
    );
  }
}
