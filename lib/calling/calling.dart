// lib/screens/video_call_screen.dart

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../services/agora_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final int uid;

  const VideoCallScreen({
    required this.channelName,
    required this.uid,
    super.key,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final AgoraService _agoraService = AgoraService();
  bool _localUserJoined = false;
  bool _muted = false;
  bool _videoEnabled = true;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    try {
      setState(() => _isInitializing = true);
      await _agoraService.initialize();
      _agoraService.engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            setState(() => _localUserJoined = true);
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            setState(() {});
          },
          onUserOffline: (connection, remoteUid, reason) {
            setState(() {});
          },
          onError: (err, msg) {
            _handleError('Video call error occurred');
          },
        ),
      );

      await _agoraService.joinChannel(widget.channelName, widget.uid);
      setState(() => _isInitializing = false);
    } catch (e) {
      _handleError('Failed to initialize video call');
    }
  }

  void _handleError(String message) {
    setState(() {
      _errorMessage = message;
      _isInitializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Return'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      body: Stack(
        children: [
          _buildVideoViews(),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildVideoViews() {
    return Stack(
      children: [
        AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _agoraService.engine,
            canvas: const VideoCanvas(uid: 0),
            connection: RtcConnection(channelId: widget.channelName),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            width: 120,
            height: 160,
            margin: const EdgeInsets.all(16),
            child: AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _agoraService.engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RawMaterialButton(
              onPressed: _onToggleMute,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
              fillColor: _muted ? Colors.red : Colors.white,
              child: Icon(
                _muted ? Icons.mic_off : Icons.mic,
                color: _muted ? Colors.white : Colors.black,
                size: 20,
              ),
            ),
            RawMaterialButton(
              onPressed: () => _onCallEnd(context),
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(15),
              fillColor: Colors.red,
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 35,
              ),
            ),
            RawMaterialButton(
              onPressed: _onToggleVideo,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
              fillColor: _videoEnabled ? Colors.white : Colors.red,
              child: Icon(
                _videoEnabled ? Icons.videocam : Icons.videocam_off,
                color: _videoEnabled ? Colors.black : Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _agoraService.engine.muteLocalAudioStream(_muted);
  }

  void _onToggleVideo() {
    setState(() {
      _videoEnabled = !_videoEnabled;
    });
    _agoraService.engine.muteLocalVideoStream(!_videoEnabled);
  }

  void _onCallEnd(BuildContext context) {
    _agoraService.leaveChannel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _agoraService.dispose();
    super.dispose();
  }
}