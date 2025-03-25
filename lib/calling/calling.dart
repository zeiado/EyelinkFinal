import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // فتح الكاميرا الأمامية
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user', // الكاميرا الأمامية
        'width': 640,
        'height': 480
      }
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    setState(() {
      _localStream = stream;
      _localRenderer.srcObject = stream;
    });

    // في التطبيق الفعلي، يجب إضافة WebRTC signaling هنا
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // عرض بث الفيديو الخاص بالمستخدم الآخر
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: RTCVideoView(_remoteRenderer),
            ),

          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ),

          // شريط التحكم السفلي
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    // كتم الصوت
                    _localStream?.getAudioTracks().first.enabled = 
                        !_localStream!.getAudioTracks().first.enabled;
                  },
                  backgroundColor: Colors.grey,
                  child: const Icon(Icons.mic_off, color: Colors.white),
                ),
                FloatingActionButton(
                  onPressed: () {
                    // إنهاء المكالمة
                    Navigator.pop(context);
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
                FloatingActionButton(
                  onPressed: () async {
                    // تبديل الكاميرا
                    await _localStream?.getVideoTracks().first.switchCamera();
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.switch_camera, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
