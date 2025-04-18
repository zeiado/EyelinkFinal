// lib/config/agora_config.dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
class AgoraConfig {
  static const String appId = '5da6979a23a8485898722332743749d5';
  static const String tempToken = '007eJxTYNjYlaqX7WwsKb7jzZNrj6z9VD7GveifePNk0+VDujeeN8cqMJimJJpZmlsmGhknWphYmFpYWpgbGRkbG5mbGJubWKaYpqp/Tm8IZGRYavSWiZEBAkF8DgbXytR4n8y8bAYGADOeIeU='; // For testing
  static const String channelName = 'Eye_Link';

  static const int timeout = 45;
  static const int uid = 0;
  static const VideoEncoderConfiguration videoConfig = VideoEncoderConfiguration(
    dimensions: VideoDimensions(width: 640, height: 360),
    frameRate: 15,
    bitrate: 800,
  );
}