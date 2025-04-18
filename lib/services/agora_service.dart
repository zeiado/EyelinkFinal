// lib/services/agora_service.dart

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config_agora/agora_config.dart';

// lib/services/agora_service.dart

class AgoraService {
  late final RtcEngine _engine;
  bool _isInitialized = false;
  bool _isInChannel = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check permissions
      await _checkPermissions();

      // Initialize engine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(const RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      // Configure video
      await _engine.setVideoEncoderConfiguration(AgoraConfig.videoConfig);

      // Enable video & audio
      await _engine.enableVideo();
      await _engine.enableAudio();
      await _engine.startPreview();
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      _isInitialized = true;
      print('Agora Engine initialized successfully');
    } catch (e) {
      print('Error initializing Agora Engine: $e');
      throw Exception('Failed to initialize Agora Engine: $e');
    }
  }

  Future<void> _checkPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (!statuses[Permission.camera]!.isGranted || 
        !statuses[Permission.microphone]!.isGranted) {
      throw Exception('Camera and Microphone permissions are required');
    }
  }

  Future<void> joinChannel(String channelName, int uid) async {
    if (!_isInitialized) {
      throw Exception('Agora Engine not initialized');
    }

    try {
      await _engine.joinChannel(
        token: AgoraConfig.tempToken,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
      _isInChannel = true;
    } catch (e) {
      throw Exception('Failed to join channel: $e');
    }
  }

  Future<void> leaveChannel() async {
    if (_isInChannel) {
      await _engine.leaveChannel();
      _isInChannel = false;
    }
  }

  void dispose() {
    if (_isInChannel) {
      leaveChannel();
    }
    if (_isInitialized) {
      _engine.release();
      _isInitialized = false;
    }
  }

  RtcEngine get engine => _engine;
}