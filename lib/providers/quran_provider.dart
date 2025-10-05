// lib/providers/quran_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/surah.dart';
import '../services/quran_api_service.dart';

class QuranState {
  final List<Surah> surahList;
  final Surah? selectedSurah;
  final bool isLoading;
  final String? error;

  // State Audio
  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final int currentVerseIndex;
  final String selectedQori;

  QuranState({
    this.surahList = const [],
    this.selectedSurah,
    this.isLoading = true,
    this.error,
    required this.audioPlayer,
    this.isPlaying = false,
    this.currentVerseIndex = 0,
    this.selectedQori = 'alafasy', // Default reciter id
  });

  // Metode copyWith untuk memperbarui state
  QuranState copyWith({
    List<Surah>? surahList,
    Surah? selectedSurah,
    bool? isLoading,
    String? error,
    bool? isPlaying,
    int? currentVerseIndex,
    String? selectedQori,
  }) {
    return QuranState(
      surahList: surahList ?? this.surahList,
      selectedSurah: selectedSurah,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      audioPlayer: audioPlayer,
      isPlaying: isPlaying ?? this.isPlaying,
      currentVerseIndex: currentVerseIndex ?? this.currentVerseIndex,
      selectedQori: selectedQori ?? this.selectedQori,
    );
  }
}

class QuranNotifier extends StateNotifier<QuranState> {
  final QuranApiService _service;
  StreamSubscription<PlayerState>? _playerStateSub;
  bool _isHandlingCompletion = false;

  QuranNotifier(this._service) : super(QuranState(audioPlayer: AudioPlayer()));

  Future<void> fetchSurahList() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _service.fetchSurahList();
      state = state.copyWith(surahList: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectSurah(int surahNumber) async {
    // Reset state audio saat pindah surah
    await state.audioPlayer.stop();
    state = state.copyWith(
      selectedSurah: null,
      isPlaying: false,
      currentVerseIndex: 0,
    );

    // Ambil detail surah
    final detail = await _service.fetchSurahDetail(surahNumber);
    state = state.copyWith(selectedSurah: detail, isLoading: false);

    // Setup listener untuk auto-play ayat berikutnya
    // Cancel previous subscription if any to avoid duplicate listeners
    _playerStateSub?.cancel();
    _playerStateSub = state.audioPlayer.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.completed &&
          !_isHandlingCompletion) {
        _isHandlingCompletion = true;
        _handleCompletion().then((_) {
          _isHandlingCompletion = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    state.audioPlayer.dispose();
    super.dispose();
  }

  // Public method to play a specific verse index (0-based)
  Future<void> playVerse(int verseIndex) async {
    if (state.selectedSurah == null) return;
    if (verseIndex < 0 || verseIndex >= state.selectedSurah!.versesList.length)
      return;

    final verse = state.selectedSurah!.versesList[verseIndex];
    // Map qori selection to URL (simulation)
    final url = _audioUrlForQori(
      verse,
      state.selectedQori,
      state.selectedSurah!.number,
    );

    try {
      await state.audioPlayer.setUrl(url);
      await state.audioPlayer.play();
      state = state.copyWith(isPlaying: true, currentVerseIndex: verseIndex);
    } catch (e) {
      // handle error
    }
  }

  Future<void> playCurrentVerse() async {
    await playVerse(state.currentVerseIndex);
  }

  // Logika Pemutaran Audio

  Future<void> _playNextVerse(int index) async {
    if (state.selectedSurah == null ||
        index >= state.selectedSurah!.versesList.length) {
      return;
    }

    final verse = state.selectedSurah!.versesList[index];
    // Gunakan URL berdasarkan Qori yang dipilih
    final audioUrl = _audioUrlForQori(
      verse,
      state.selectedQori,
      state.selectedSurah!.number,
    );

    try {
      await state.audioPlayer.setUrl(audioUrl);
      state = state.copyWith(isPlaying: true, currentVerseIndex: index);
      await state.audioPlayer.play();
    } catch (e) {
      // Error loading audio, skip to next verse
      _playNextVerse(index + 1);
    }
  }

  Future<void> _handleCompletion() async {
    if (state.selectedSurah == null) return;
    if (state.currentVerseIndex < state.selectedSurah!.versesList.length - 1) {
      await _playNextVerse(state.currentVerseIndex + 1);
    } else {
      state.audioPlayer.stop();
      state = state.copyWith(isPlaying: false, currentVerseIndex: 0);
    }
  }

  void togglePlayPause() {
    if (state.selectedSurah == null) return;
    if (state.isPlaying) {
      state.audioPlayer.pause();
      state = state.copyWith(isPlaying: false);
      return;
    }

    // If not currently playing, try to resume if an item is loaded and not finished
    final duration = state.audioPlayer.duration;
    final position = state.audioPlayer.position;
    if (duration != null && position < duration) {
      state.audioPlayer.play();
      state = state.copyWith(isPlaying: true);
      return;
    }

    // Otherwise start playing the current verse (or first verse)
    playVerse(state.currentVerseIndex);
  }

  void changeQori(String qoriId) {
    state = state.copyWith(selectedQori: qoriId);
    // Hentikan dan mulai ulang dari awal setelah ganti qori
    state.audioPlayer.stop();
    state = state.copyWith(isPlaying: false, currentVerseIndex: 0);
  }

  void clearSelection() {
    state.audioPlayer.stop();
    state = state.copyWith(
      selectedSurah: null,
      isPlaying: false,
      currentVerseIndex: 0,
    );
  }

  String _audioUrlForQori(dynamic verse, String qoriId, int surahNumber) {
    // If verse provides a full audio URL, prefer it (it may already point to a reciter)
    final base = (verse.audioUrl ?? '').toString();
    if (base.isNotEmpty && base.startsWith('http')) {
      // If audio URL already contains reciter info, try to replace reciter query if present
      if (base.contains('?')) return '$base&reciter=$qoriId';
      return '$base?reciter=$qoriId';
    }

    // Map qori id to known CDN folder names
    final Map<String, String> reciterMap = {
      'alafasy': 'ar.alafasy',
      'basit': 'ar.abdulbasit',
      'husary': 'ar.husary',
      'minshawi': 'ar.minshawi',
    };

    final reciterFolder = reciterMap[qoriId] ?? qoriId;

    // Construct URL pattern commonly used by islamic.network CDN
    // Format: https://cdn.islamic.network/quran/audio/128/{reciterFolder}/{surahNumber}/{verseNumber}.mp3
    final verseNumber = (verse.inSurah ?? 0).toString();
    return 'https://cdn.islamic.network/quran/audio/128/$reciterFolder/$surahNumber/$verseNumber.mp3';
  }

  // Returns available qori ids and names (simple)
  Map<String, String> availableQori() {
    return {
      'alafasy': 'Mishary Rashid Alafasy',
      'basit': 'Abdul Basit',
      'husary': 'Muhammad Siddiq Al-Minshawi',
    };
  }
}

final quranProvider = StateNotifierProvider<QuranNotifier, QuranState>((ref) {
  return QuranNotifier(QuranApiService());
});
