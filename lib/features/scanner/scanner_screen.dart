import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';

/// Man hinh quet van ban (Camera)
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Khoi tao camera sau
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final backCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras!.first,
        );

        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.high,
          enableAudio: false, // Tat audio de tranh xung dot voi app khac
        );

        await _cameraController!.initialize();
        if (!mounted) return;
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Loi khoi tao camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// Chup anh va xu ly
  Future<void> _takePicture() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    try {
      // Haptic feedback khi chup
      // TODO: Them package vibration neu can
      
      final XFile picture = await _cameraController!.takePicture();
      debugPrint('Da chup anh tai: ${picture.path}');
      
      // TODO: Chuyen path nay sang ML Kit Text Recognition
      // Sau do Navigator.push den WordSelectionScreen
      
    } catch (e) {
      debugPrint('Loi khi chup anh: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Preview Camera
            if (_isCameraInitialized && _cameraController != null)
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),

            // 2. UI Overlay (Header)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black.withOpacity(0.3),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Quet van ban',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Canh giu tieu de o giua
                  ],
                ),
              ),
            ),

            // 3. UI Overlay (Viewport Frame - Khung ngam)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // 4 dau goc khung ngam
                    _buildCorner(0, 0, true, true),
                    _buildCorner(1, 0, false, true),
                    _buildCorner(0, 1, true, false),
                    _buildCorner(1, 1, false, false),
                    
                    // Huong dan
                    Positioned(
                      bottom: -40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Giữ máy thẳng, đủ sáng',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. UI Overlay (Bottom Controls - Nut chup)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ham phu ve 4 goc khung ngam
  Widget _buildCorner(int xAlign, int yAlign, bool isLeft, bool isTop) {
    return Positioned(
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            bottom: isTop ? BorderSide.none : const BorderSide(color: AppColors.primary, width: 4),
            left: isLeft ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            right: isLeft ? BorderSide.none : const BorderSide(color: AppColors.primary, width: 4),
          ),
        ),
      ),
    );
  }
}
