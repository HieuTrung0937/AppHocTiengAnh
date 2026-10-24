import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/features/scanner/word_selection_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String? _error;

  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        setState(() => _error = 'Không tìm thấy camera');
        return;
      }

      _cameraController = CameraController(_cameras![0], ResolutionPreset.high, enableAudio: false);
      await _cameraController!.initialize();
      
      // SỬA LỖI ZOOM: Dùng hàm getMinZoomLevel() và getMaxZoomLevel()
      final minZ = await _cameraController!.getMinZoomLevel();
      final maxZ = await _cameraController!.getMaxZoomLevel();
      
      if (mounted) {
        setState(() {
          _minZoomLevel = minZ;
          _maxZoomLevel = maxZ;
          _currentZoomLevel = minZ;
          _isCameraInitialized = true;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Lỗi khởi tạo camera: $e');
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseZoomLevel = _currentZoomLevel;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    final double newZoomLevel = (_baseZoomLevel * details.scale).clamp(_minZoomLevel, _maxZoomLevel);
    if (newZoomLevel != _currentZoomLevel) {
      setState(() => _currentZoomLevel = newZoomLevel);
      _cameraController!.setZoomLevel(_currentZoomLevel);
    }
  }

  Future<void> _takePictureAndProcess() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final XFile image = await _cameraController!.takePicture();
      final recognizedText = await _processImage(image.path);
      
      if (mounted) {
        setState(() => _isProcessing = false);
        if (recognizedText.trim().isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WordSelectionScreen(
                recognizedText: recognizedText,
                imagePath: image.path,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không nhận diện được từ vựng. Hãy chụp cận cảnh hơn!')),
          );
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  // BỘ LỌC THÔNG MINH: Chỉ lấy các dòng ngắn, giống từ vựng/cụm từ
  Future<String> _processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      StringBuffer filteredText = StringBuffer();
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text.trim();
          // Chỉ giữ lại dòng dưới 40 ký tự và chủ yếu là chữ cái
          if (text.length < 40 && text.isNotEmpty && RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(text)) {
            filteredText.writeln(text);
          }
        }
      }
      return filteredText.toString().trim();
    } finally {
      textRecognizer.close();
    }
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          left: isLeft ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                child: CameraPreview(_cameraController!),
              ),
            ),
          if (!_isCameraInitialized && _error == null)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (_error != null)
            Center(child: Padding(padding: const EdgeInsets.all(20), child: Text(_error!, style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center))),
          
          if (_isCameraInitialized)
            IgnorePointer(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.15,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary.withOpacity(0.9), width: 3),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.15),
                  ),
                  child: Stack(children: [_buildCorner(true, true), _buildCorner(true, false), _buildCorner(false, true), _buildCorner(false, false)]),
                ),
              ),
            ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white, size: 28)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
                      child: const Text('Quét từ vựng', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          if (_isCameraInitialized)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pinch, color: Colors.white70, size: 16),
                            SizedBox(width: 8),
                            Text('Chụm 2 ngón tay để thu phóng', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _isProcessing ? null : _takePictureAndProcess,
                        child: Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: _isProcessing ? Colors.grey : Colors.white, border: Border.all(color: Colors.white, width: 4)),
                          child: _isProcessing ? const CircularProgressIndicator(color: Colors.grey) : const Icon(Icons.camera_alt, color: Colors.black, size: 32),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
