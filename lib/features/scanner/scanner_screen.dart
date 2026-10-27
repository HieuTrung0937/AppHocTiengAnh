import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/features/scanner/word_selection_screen.dart';
import 'dart:typed_data'; // Thêm dòng này vào phần import

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String? _error;

  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;

  static const double _frameWidthRatio = 0.9;
  static const double _frameHeightRatio = 0.15;

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
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
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

      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();

      // ✅ SỬA LỖI: Gọi hàm async để lấy min/max zoom level
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
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    final double newZoomLevel = (_baseZoomLevel * details.scale).clamp(
      _minZoomLevel,
      _maxZoomLevel,
    );
    if (newZoomLevel != _currentZoomLevel) {
      setState(() => _currentZoomLevel = newZoomLevel);
      _cameraController!.setZoomLevel(_currentZoomLevel);
    }
  }

  Future<void> _takePictureAndProcess() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final XFile image = await _cameraController!.takePicture();
      final croppedImagePath = await _cropImageToFrame(image.path);
      final recognizedText = await _processImage(croppedImagePath);

      if (mounted) {
        setState(() => _isProcessing = false);
        if (recognizedText.trim().isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WordSelectionScreen(
                recognizedText: recognizedText,
                imagePath: croppedImagePath,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Không nhận diện được từ vựng. Hãy chụp cận cảnh hơn!',
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  // Thay thế toàn bộ hàm _cropImageToFrame cũ bằng hàm này
  Future<String> _cropImageToFrame(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();

    // Decode ảnh gốc
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final int width = image.width;
    final int height = image.height;

    // Tính toán vùng crop
    final int cropWidth = (width * _frameWidthRatio).toInt();
    final int cropHeight = (height * _frameHeightRatio).toInt();
    final int left = ((width - cropWidth) / 2).toInt();
    final int top = ((height - cropHeight) / 2).toInt();

    // Đọc pixel của vùng cần crop
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (byteData == null) return imagePath; // Fallback nếu lỗi

    final List<int> croppedPixels = [];
    for (int y = top; y < top + cropHeight; y++) {
      for (int x = left; x < left + cropWidth; x++) {
        final int index = (y * width + x) * 4;
        croppedPixels.add(byteData.getUint8(index)); // R
        croppedPixels.add(byteData.getUint8(index + 1)); // G
        croppedPixels.add(byteData.getUint8(index + 2)); // B
        croppedPixels.add(byteData.getUint8(index + 3)); // A
      }
    }

    // Tạo ảnh mới từ pixel đã crop
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(
      Uint8List.fromList(croppedPixels),
    );
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: cropWidth,
      height: cropHeight,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final ui.Codec croppedCodec = await descriptor.instantiateCodec(
      targetWidth: cropWidth,
      targetHeight: cropHeight,
    );
    final ui.FrameInfo croppedFrame = await croppedCodec.getNextFrame();
    final ui.Image croppedImage = croppedFrame.image;

    // Convert sang PNG bytes
    final ByteData? pngByteData = await croppedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final croppedBytes = pngByteData!.buffer.asUint8List();

    // Lưu file tạm
    final tempDir = Directory.systemTemp;
    final croppedFile = File(
      '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await croppedFile.writeAsBytes(croppedBytes);

    return croppedFile.path;
  }

  Future<String> _processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      return recognizedText.text;
    } finally {
      textRecognizer.close();
    }
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
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
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          if (_isCameraInitialized)
            IgnorePointer(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * _frameWidthRatio,
                  height:
                      MediaQuery.of(context).size.height * _frameHeightRatio,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.9),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.15),
                  ),
                  child: Stack(
                    children: [
                      _buildCorner(true, true),
                      _buildCorner(true, false),
                      _buildCorner(false, true),
                      _buildCorner(false, false),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Quét từ vựng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          if (_isCameraInitialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pinch, color: Colors.white70, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Chụm 2 ngón tay để thu phóng',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _isProcessing ? null : _takePictureAndProcess,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isProcessing ? Colors.grey : Colors.white,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: _isProcessing
                              ? const CircularProgressIndicator(
                                  color: Colors.grey,
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                  size: 32,
                                ),
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
