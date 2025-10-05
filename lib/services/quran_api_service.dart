// lib/services/quran_api_service.dart
import 'package:dio/dio.dart';
import '../models/surah.dart';

class QuranApiService {
  final Dio _dio = Dio();
  static const String baseUrl = 'https://api.quran.gading.dev';

  // Helper: turn possible nested structures into a reasonable string
  String _pickString(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is Map) {
      // common keys
      for (final k in ['id', 'en', 'arab', 'ar', 'text']) {
        if (v[k] != null && v[k].toString().trim().isNotEmpty)
          return v[k].toString();
      }
      // some APIs use nested objects like {transliteration: {en:..., id:...}}
      if (v.containsKey('short')) return _pickString(v['short']);
      if (v.containsKey('long')) return _pickString(v['long']);
      // otherwise return first string value
      for (final entry in v.entries) {
        if (entry.value is String && entry.value.toString().trim().isNotEmpty)
          return entry.value.toString();
      }
    }
    return v.toString();
  }

  Future<List<Surah>> fetchSurahList() async {
    try {
      final response = await _dio.get('$baseUrl/surah');
      if (response.statusCode == 200) {
        final respData = response.data;
        List<dynamic> listData = [];
        if (respData is Map &&
            respData['data'] != null &&
            respData['data'] is List) {
          listData = respData['data'];
        } else if (respData is List) {
          listData = respData;
        }

        if (listData.isNotEmpty) {
          final list = listData.map<Surah>((s) {
            final Map obj = s is Map ? s : {};
            final num =
                obj['number'] ??
                obj['nomor'] ??
                obj['id'] ??
                obj['no'] ??
                obj['surah_number'] ??
                0;
            final number = (num is int)
                ? num
                : int.tryParse(num.toString()) ?? 0;

            // Use helper to pick strings safely from nested structures and prefer
            // the shape returned by https://api.quran.gading.dev (name:{}, numberOfVerses, revelation)
            final nameObj = obj['name'] is Map ? obj['name'] as Map : null;

            String nameLatinRaw = '';
            String nameArabicRaw = '';
            String translationRaw = '';
            if (nameObj != null) {
              nameLatinRaw = (nameObj['transliteration'] is Map)
                  ? (nameObj['transliteration']['id'] ??
                            nameObj['transliteration']['en'] ??
                            '')
                        .toString()
                  : (nameObj['transliteration'] ??
                            nameObj['long'] ??
                            nameObj['short'] ??
                            '')
                        .toString();
              nameArabicRaw = (nameObj['short'] ?? nameObj['long'] ?? '')
                  .toString();
              translationRaw = (nameObj['translation'] is Map)
                  ? (nameObj['translation']['id'] ??
                            nameObj['translation']['en'] ??
                            '')
                        .toString()
                  : (nameObj['translation'] ?? '').toString();
            } else {
              nameLatinRaw =
                  (obj['transliteration'] ??
                          obj['name'] ??
                          obj['name_latin'] ??
                          '')
                      .toString();
              nameArabicRaw =
                  (obj['short'] ??
                          obj['long'] ??
                          obj['name_ar'] ??
                          obj['arabic'] ??
                          '')
                      .toString();
              translationRaw =
                  (obj['translation'] ??
                          obj['translation_id'] ??
                          obj['translations'] ??
                          '')
                      .toString();
            }

            final nameLatin = _pickString(nameLatinRaw);
            final nameArabic = _pickString(nameArabicRaw);
            final translation = _pickString(translationRaw);

            final versesCountRaw =
                obj['numberOfVerses'] ??
                obj['number_of_verses'] ??
                obj['numberOfAyahs'] ??
                obj['numberOfAyat'] ??
                obj['verses_count'] ??
                obj['numberOfVerses'] ??
                0;
            final versesCount = (versesCountRaw is int)
                ? versesCountRaw
                : int.tryParse(versesCountRaw.toString()) ?? 0;

            final revObj = obj['revelation'];
            final revelation = _pickString(
              revObj is Map
                  ? (revObj['id'] ??
                        revObj['arab'] ??
                        revObj['en'] ??
                        revObj['name'])
                  : revObj,
            );

            return Surah(
              number: number,
              nameLatin: nameLatin.isNotEmpty ? nameLatin : 'Surah $number',
              nameArabic: nameArabic,
              translation: translation,
              versesCount: versesCount,
              revelation: revelation,
            );
          }).toList();
          return list;
        }
      }
      return Future.error('Gagal mengambil daftar surah.');
    } catch (e) {
      // Fallback ke data dummy jika ada masalah koneksi atau parsing
      return Future.value(Surah.dummyList);
    }
  }

  Future<Surah> fetchSurahDetail(int surahNumber) async {
    try {
      final response = await _dio.get('$baseUrl/surah/$surahNumber');
      if (response.statusCode == 200) {
        final respData = response.data;
        dynamic data;
        if (respData is Map && respData['data'] != null)
          data = respData['data'];
        else
          data = respData;

        // parse metadata and normalize with _pickString to avoid Map prints
        final meta = data is Map ? data : <String, dynamic>{};
        final number = surahNumber;
        final nameLatinRaw =
            meta['name'] ??
            meta['name_latin'] ??
            meta['transliteration'] ??
            meta['name'] ??
            'Surah $number';
        final nameArabicRaw =
            meta['name_arabic'] ??
            meta['name_ar'] ??
            meta['short'] ??
            meta['long'] ??
            '';
        final translationRaw =
            meta['translation_id'] ??
            meta['translation'] ??
            meta['translations'] ??
            '';
        final versesCountRaw =
            meta['verses_count'] ??
            meta['number_of_ayah'] ??
            meta['ayah_count'] ??
            meta['verses'] ??
            0;
        final revelationRaw =
            meta['revelation'] ??
            meta['revelation_place'] ??
            meta['revelation_type'] ??
            '';

        final nameLatin = _pickString(nameLatinRaw);
        final nameArabic = _pickString(nameArabicRaw);
        final translation = _pickString(translationRaw);
        final versesCount = (versesCountRaw is int)
            ? versesCountRaw
            : int.tryParse(versesCountRaw.toString()) ?? 0;
        final revelation = _pickString(revelationRaw);

        // find verses array
        List<dynamic> versesData = [];
        if (data is Map) {
          if (data['verses'] != null && data['verses'] is List)
            versesData = data['verses'];
          else if (data['ayahs'] != null && data['ayahs'] is List)
            versesData = data['ayahs'];
          else if (data['data'] != null && data['data'] is List)
            versesData = data['data'];
        } else if (data is List) {
          versesData = data;
        }

        List<Verse> verses = [];
        if (versesData.isNotEmpty) {
          for (var v in versesData) {
            final inSurah =
                (v is Map &&
                    v['number'] != null &&
                    v['number']['inSurah'] != null)
                ? (v['number']['inSurah'] is int
                      ? v['number']['inSurah']
                      : int.tryParse(v['number']['inSurah'].toString()) ?? 0)
                : (v['verse'] ?? v['number'] ?? 0);
            String arabic = '';
            String translationText = '';
            String audio = '';

            if (v is Map) {
              // Arabic text may be under different keys
              if (v['text'] is Map) {
                arabic = (v['text']['arab'] ?? v['text']['arabic'] ?? '')
                    .toString();
              } else {
                arabic =
                    (v['text'] ?? v['arab'] ?? v['arabic'] ?? v['ayah'] ?? '')
                        .toString();
              }

              // translation may be nested under translation or translations
              if (v['translation'] is Map) {
                translationText =
                    (v['translation']['id'] ?? v['translation']['en'] ?? '')
                        .toString();
              } else if (v['translations'] is Map) {
                translationText =
                    (v['translations']['id'] ?? v['translations']['en'] ?? '')
                        .toString();
              } else {
                translationText =
                    (v['translation'] ?? v['translation_text'] ?? '')
                        .toString();
              }
              if (v['audio'] != null) {
                if (v['audio'] is String)
                  audio = v['audio'];
                else if (v['audio'] is Map && v['audio']['primary'] != null)
                  audio = v['audio']['primary'];
              }
            }

            // fallback: use dummy text if missing
            if (arabic == '') arabic = 'نَصٌّ لآية ${inSurah}';
            if (translationText == '')
              translationText =
                  'Terjemahan ayat ke ${inSurah} dalam bahasa Indonesia.';

            verses.add(
              Verse(
                inSurah: inSurah is int
                    ? inSurah
                    : (int.tryParse(inSurah.toString()) ?? 0),
                arabic: _pickString(arabic),
                translation: _pickString(translationText),
                audioUrl: _pickString(audio),
                qoriPrimary: 'alafasy',
                qoriSecondary: 'basit',
              ),
            );
          }
        } else {
          // fallback to dummy verses instead of error so UI won't spin
          final fallbackSurahData = Surah.dummyList.firstWhere(
            (s) => s.number == surahNumber,
            orElse: () => Surah.dummyList.first,
          );
          final fallbackVerses = Verse.dummyVerses(
            surahNumber,
            fallbackSurahData.versesCount,
          );
          return Surah(
            number: fallbackSurahData.number,
            nameLatin: _pickString(nameLatin),
            nameArabic: _pickString(nameArabic),
            translation: _pickString(translation),
            versesCount: fallbackVerses.length,
            revelation: _pickString(revelation),
            versesList: fallbackVerses,
          );
        }

        return Surah(
          number: number,
          nameLatin: _pickString(nameLatin),
          nameArabic: _pickString(nameArabic),
          translation: _pickString(translation),
          versesCount: (versesCount > 0) ? versesCount : verses.length,
          revelation: _pickString(revelation),
          versesList: verses,
        );
      }
      return Future.error('Gagal mengambil detail surah.');
    } catch (e) {
      return Future.error('Gagal mengambil detail surah: $e');
    }
  }
}
