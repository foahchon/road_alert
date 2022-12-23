import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewScreen extends StatefulWidget {
  const CameraPreviewScreen({super.key});

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  late final CameraController _cameraController;

  @override
  void initState() {
    availableCameras().then((cameras) {
      _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      _cameraController.initialize().then((_) => setState(() {}));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return Scaffold(
      body: Stack(
        children: [
          _cameraController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: deviceRatio,
                  child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(
                          _cameraController.value.aspectRatio, 1, 1),
                      child: CameraPreview(_cameraController)),
                )
              : const Center(child: CircularProgressIndicator()),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 22.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.cached_sharp,
                        color: Colors.white,
                        size: 48.0,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 7.5,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                      onPressed: () =>
                          debugPrint("Will switch cameras when implemented."),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.check_circle_outline_sharp,
                        color: Colors.white,
                        size: 48.0,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 7.5,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop(
                          await _cameraController.takePicture(),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 48.0,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 7.5,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
