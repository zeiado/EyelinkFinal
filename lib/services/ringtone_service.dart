import 'package:just_audio/just_audio.dart';

class RingtoneService {
  static final RingtoneService _instance = RingtoneService._internal();
  factory RingtoneService() => _instance;
  RingtoneService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> initialize() async {
    // Set up audio session
    await _audioPlayer.setAsset('assets/sounds/call_ringtone.mp3');
    await _audioPlayer.setLoopMode(LoopMode.one);
  }

  Future<void> playRingtone() async {
    if (!_isPlaying) {
      try {
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.play();
        _isPlaying = true;
        print('Ringtone started playing');
      } catch (e) {
        print('Error playing ringtone: $e');
      }
    }
  }

  Future<void> stopRingtone() async {
    if (_isPlaying) {
      try {
        await _audioPlayer.stop();
        _isPlaying = false;
        print('Ringtone stopped');
      } catch (e) {
        print('Error stopping ringtone: $e');
      }
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}