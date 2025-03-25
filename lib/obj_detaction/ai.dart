import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key});

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isDetecting = false;

  final ObjectDetector _objectDetector = ObjectDetector(
    options: ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: true,
      multipleObjects: true,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(_cameras[0], ResolutionPreset.high);
        await _cameraController!.initialize();
        if (!mounted) return;
        setState(() {});
        _startDetection();
      } else {
        debugPrint("❌ لا توجد كاميرات متاحة!");
      }
    } catch (e) {
      debugPrint("⚠️ خطأ أثناء تحميل الكاميرا: $e");
    }
  }

  void _startDetection() {
    if (_cameraController == null) return;

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      final inputImage = InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final objects = await _objectDetector.processImage(inputImage);
      debugPrint("✅ تم التعرف على ${objects.length} كائنات");
      _isDetecting = false;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(_cameraController!),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.call_end, color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }
}
