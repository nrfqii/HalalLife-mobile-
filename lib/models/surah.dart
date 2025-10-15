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

    // Generic placeholder names for other surahs - add Arabic names
    final arabicNames = {
      4: ['An-Nisa', 'النساء'],
      5: ['Al-Ma\'idah', 'المائدة'],
      6: ['Al-An\'am', 'الأنعام'],
      7: ['Al-A\'raf', 'الأعراف'],
      8: ['Al-Anfal', 'الأنفال'],
      9: ['At-Taubah', 'التوبة'],
      10: ['Yunus', 'يونس'],
      11: ['Hud', 'هود'],
      12: ['Yusuf', 'يوسف'],
      13: ['Ar-Ra\'d', 'الرعد'],
      14: ['Ibrahim', 'إبراهيم'],
      15: ['Al-Hijr', 'الحجر'],
      16: ['An-Nahl', 'النحل'],
      17: ['Al-Isra', 'الإسراء'],
      18: ['Al-Kahf', 'الكهف'],
      19: ['Maryam', 'مريم'],
      20: ['Ta-Ha', 'طه'],
      21: ['Al-Anbiya', 'الأنبياء'],
      22: ['Al-Hajj', 'الحج'],
      23: ['Al-Mu\'minun', 'المؤمنون'],
      24: ['An-Nur', 'النور'],
      25: ['Al-Furqan', 'الفرقان'],
      26: ['Ash-Shu\'ara', 'الشعراء'],
      27: ['An-Naml', 'النمل'],
      28: ['Al-Qasas', 'القصص'],
      29: ['Al-\'Ankabut', 'العنكبوت'],
      30: ['Ar-Rum', 'الروم'],
      31: ['Luqman', 'لقمان'],
      32: ['As-Sajdah', 'السجدة'],
      33: ['Al-Ahzab', 'الأحزاب'],
      34: ['Saba', 'سبإ'],
      35: ['Fatir', 'فاطر'],
      36: ['Ya-Sin', 'يس'],
      37: ['As-Saffat', 'الصافات'],
      38: ['Sad', 'ص'],
      39: ['Az-Zumar', 'الزمر'],
      40: ['Ghafir', 'غافر'],
      41: ['Fussilat', 'فصلت'],
      42: ['Ash-Shura', 'الشورى'],
      43: ['Az-Zukhruf', 'الزخرف'],
      44: ['Ad-Dukhan', 'الدخان'],
      45: ['Al-Jathiyah', 'الجاثية'],
      46: ['Al-Ahqaf', 'الأحقاف'],
      47: ['Muhammad', 'محمد'],
      48: ['Al-Fath', 'الفتح'],
      49: ['Al-Hujurat', 'الحجرات'],
      50: ['Qaf', 'ق'],
      51: ['Adh-Dhariyat', 'الذاريات'],
      52: ['At-Tur', 'الطور'],
      53: ['An-Najm', 'النجم'],
      54: ['Al-Qamar', 'القمر'],
      55: ['Ar-Rahman', 'الرحمن'],
      56: ['Al-Waqi\'ah', 'الواقعة'],
      57: ['Al-Hadid', 'الحديد'],
      58: ['Al-Mujadilah', 'المجادلة'],
      59: ['Al-Hashr', 'الحشر'],
      60: ['Al-Mumtahanah', 'الممتحنة'],
      61: ['As-Saff', 'الصف'],
      62: ['Al-Jumu\'ah', 'الجمعة'],
      63: ['Al-Munafiqun', 'المنافقون'],
      64: ['At-Taghabun', 'التغابن'],
      65: ['At-Talaq', 'الطلاق'],
      66: ['At-Tahrim', 'التحريم'],
      67: ['Al-Mulk', 'الملك'],
      68: ['Al-Qalam', 'القلم'],
      69: ['Al-Haqqah', 'الحاقة'],
      70: ['Al-Ma\'arij', 'المعارج'],
      71: ['Nuh', 'نوح'],
      72: ['Al-Jinn', 'الجن'],
      73: ['Al-Muzzammil', 'المزمل'],
      74: ['Al-Muddaththir', 'المدثر'],
      75: ['Al-Qiyamah', 'القيامة'],
      76: ['Al-Insan', 'الإنسان'],
      77: ['Al-Mursalat', 'المرسلات'],
      78: ['An-Naba', 'النبإ'],
      79: ['An-Nazi\'at', 'النازعات'],
      80: ['\'Abasa', 'عبس'],
      81: ['At-Takwir', 'التكوير'],
      82: ['Al-Infitar', 'الإنفطار'],
      83: ['Al-Mutaffifin', 'المطففين'],
      84: ['Al-Inshiqaq', 'الإنشقاق'],
      85: ['Al-Buruj', 'البروج'],
      86: ['At-Tariq', 'الطارق'],
      87: ['Al-A\'la', 'الأعلى'],
      88: ['Al-Ghashiyah', 'الغاشية'],
      89: ['Al-Fajr', 'الفجر'],
      90: ['Al-Balad', 'البلد'],
      91: ['Ash-Shams', 'الشمس'],
      92: ['Al-Layl', 'الليل'],
      93: ['Ad-Duha', 'الضحى'],
      94: ['Ash-Sharh', 'الشرح'],
      95: ['At-Tin', 'التين'],
      96: ['Al-\'Alaq', 'العلق'],
      97: ['Al-Qadr', 'القدر'],
      98: ['Al-Bayyinah', 'البينة'],
      99: ['Az-Zalzalah', 'الزلزلة'],
      100: ['Al-\'Adiyat', 'العاديات'],
      101: ['Al-Qari\'ah', 'القارعة'],
      102: ['At-Takathur', 'التكاثر'],
      103: ['Al-\'Asr', 'العصر'],
      104: ['Al-Humazah', 'الهمزة'],
      105: ['Al-Fil', 'الفيل'],
      106: ['Quraysh', 'قريش'],
      107: ['Al-Ma\'un', 'الماعون'],
      108: ['Al-Kawthar', 'الكوثر'],
      109: ['Al-Kafirun', 'الكافرون'],
      110: ['An-Nasr', 'النصر'],
      111: ['Al-Masad', 'المسد'],
      112: ['Al-Ikhlas', 'الإخلاص'],
      113: ['Al-Falaq', 'الفلق'],
    };

    if (arabicNames.containsKey(num)) {
      final v = arabicNames[num]!;
      return Surah(
        number: num,
        nameLatin: v[0] as String,
        nameArabic: v[1] as String,
        translation: 'Terjemahan Surah $num',
        versesCount: 5 + (num % 10),
        revelation: num % 2 == 0 ? 'Madinah' : 'Mekah',
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
