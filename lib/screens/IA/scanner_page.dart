import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'diagnostic_page.dart';

class ScannerPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ScannerPage({super.key, required this.cameras});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late CameraController controller;
  bool isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialisation de la caméra arrière
  void _initializeCamera() {
    controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        isCameraInitialized = true;
      });
    });
  }

  // Fonction pour naviguer vers la page diagnostic avec l'image
  void _goToDiagnostic(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DiagnosticPage(imagePath: path)),
    );
  }

  // Choisir une image depuis la galerie
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? selectedImage = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (selectedImage != null) {
        _goToDiagnostic(selectedImage.path);
      }
    } catch (e) {
      debugPrint("Erreur galerie : $e");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Aperçu de la caméra en plein écran
          CameraPreview(controller),

          // 2. Overlay avec le rectangle de focus transparent
          _buildCameraMask(context),

          // 3. Barre supérieure (Retour, Titre, Galerie)
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "Scan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: _pickImageFromGallery,
                ),
              ],
            ),
          ),

          // 4. Instruction et Bouton de capture en bas
          Positioned(
            bottom: 40,
            left: 30,
            right: 30,
            child: Column(
              children: [
                const Text(
                  "Alignez la plante dans le cadre",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final image = await controller.takePicture();
                        _goToDiagnostic(image.path);
                      } catch (e) {
                        debugPrint("Erreur capture : $e");
                      }
                    },
                    icon: const Icon(
                      Icons.center_focus_weak,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Scanner",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFFFA74D,
                      ), // Orange AgriAlert
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour créer l'effet de masque avec le trou rectangulaire
  Widget _buildCameraMask(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.5),
        BlendMode.srcOut,
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              backgroundBlendMode: BlendMode.dstOut,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
