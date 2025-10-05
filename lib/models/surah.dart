// lib/models/surah.dart

class Surah {
  final int number;
  final String nameLatin;
  final String nameArabic;
  final String translation;
  final int versesCount;
  final String revelation;
  final List<Verse> versesList;

  Surah({
    required this.number,
    required this.nameLatin,
    required this.nameArabic,
    required this.translation,
    required this.versesCount,
    required this.revelation,
    this.versesList = const [],
  });

  // Data dummy untuk daftar surah (generate 114 entries)
  static List<Surah> dummyList = List.generate(114, (index) {
    final num = index + 1;
    // Minimal set of known names for the first few and last
    final names = {
      1: ['Al-Fatihah', 'الفاتحة', 'Pembukaan', 7, 'Mekah'],
      2: ['Al-Baqarah', 'البقرة', 'Sapi Betina', 286, 'Madinah'],
      3: ['Ali \"Imran', 'آل عمران', 'Keluarga Imran', 200, 'Madinah'],
      114: ['An-Nas', 'الناس', 'Manusia', 6, 'Mekah'],
    };

    if (names.containsKey(num)) {
      final v = names[num]!;
      return Surah(
        number: num,
        nameLatin: v[0] as String,
        nameArabic: v[1] as String,
        translation: v[2] as String,
        versesCount: v[3] as int,
        revelation: v[4] as String,
      );
    }

    // Generic placeholder names for other surahs
    return Surah(
      number: num,
      nameLatin: 'Surah $num',
      nameArabic: '',
      translation: 'Terjemahan Surah $num',
      versesCount: 5 + (num % 10),
      revelation: num % 2 == 0 ? 'Madinah' : 'Mekah',
    );
  });
}

class Verse {
  final int inSurah;
  final String arabic;
  final String translation;
  final String audioUrl; // URL audio qori utama
  final String qoriPrimary;
  final String qoriSecondary;

  Verse({
    required this.inSurah,
    required this.arabic,
    required this.translation,
    required this.audioUrl,
    required this.qoriPrimary,
    required this.qoriSecondary,
  });

  // Data dummy untuk ayat
  static List<Verse> dummyVerses(int surahNumber, int versesCount) {
    return List.generate(
      versesCount,
      (index) => Verse(
        inSurah: index + 1,
        arabic: 'نَصٌّ عَرَبِيٌّ لِلآيَةِ ${index + 1}',
        translation: 'Terjemahan ayat ke ${index + 1} dalam bahasa Indonesia.',
        audioUrl:
            'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${surahNumber * 1000 + index}',
        qoriPrimary: 'Mishary Rashid Alafasy',
        qoriSecondary: 'Abdul Basit Abdus Samad (Coming Soon)',
      ),
    );
  }
}
