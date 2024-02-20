import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  // Uncomment these variables if you intend to switch between cameras
  // late List<CameraDescription> cameras;
  // int selectedCamera = 0;
  List<File> capturedImages = [];

  @override
  void initState() {
    super.initState();
    // Uncomment this if you intend to switch between cameras
    // initCamera(selectedCamera);
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeCamera([CameraDescription? newCamera]) async {
    _controller = CameraController(newCamera ?? widget.cameras.first, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize().then((_) {
      // Once the controller is initialized, trigger a rebuild to show the camera preview
      if (mounted) {
        setState(() {}); // Trigger a rebuild
      }
    }).catchError((error) {
      print('Error initializing camera: $error');
    });
  }

  // Uncomment this method and related variables if you intend to switch between cameras
  // initCamera(int cameraIndex) async {
  //   cameras = await availableCameras();
  //   _controller = CameraController(cameras[cameraIndex], ResolutionPreset.medium);
  //   _initializeControllerFuture = _controller.initialize();
  // }

  Future<void> _pickImageFromCamera() async {
    await _initializeControllerFuture;
    final xFile = await _controller.takePicture();
    setState(() {
      capturedImages.add(File(xFile.path));
    });
    // Pass the captured image to the TensorFlow model immediately
    _runModel(File(xFile.path));
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        capturedImages.add(File(pickedImage.path));
      });
      // Pass the picked image to the TensorFlow model immediately
      _runModel(File(pickedImage.path));
    }
  }

  Future<void> _runModel(File imageFile) async {
    await Tflite.loadModel(
      model: "assets/model/model_unquant.tflite",
      labels: "assets/model/labels.txt",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );

    final output = await Tflite.runModelOnImage(
      path: imageFile.path,
      numResults: 10,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    if (output != null && output.isNotEmpty) {
      // Display the result screen with the inference result
      _showResultScreen(output[0]['label']);
    }
  }

  void _showResultScreen(String result) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Center(
            child: Text(
              'Result: $result',
              style: TextStyle(fontSize: 20),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (_controller.value.isInitialized) {
                  return CameraPreview(_controller);
                } else {
                  return Center(child: Text('Failed to initialize camera'));
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    // Switch between cameras
                    final newCameraIndex = (_controller.description == widget.cameras.first) ? 1 : 0;
                    final newCamera = widget.cameras[newCameraIndex];
                    _initializeCamera(newCamera);
                  },
                  icon: Icon(Icons.switch_camera_rounded, color: Colors.white),
                ),
                GestureDetector(
                  onTap: _pickImageFromCamera,
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
                // GestureDetector(
                //   onTap: _pickImageFromGallery,
                //   child: Container(
                //     height: 60,
                //     width: 60,
                //     decoration: BoxDecoration(
                //       border: Border.all(color: Colors.white),
                //       image: capturedImages.isNotEmpty
                //           ? DecorationImage(
                //               image: FileImage(capturedImages.last),
                //               fit: BoxFit.cover,
                //             )
                //           : null,
                //     ),
                //   ),
                // ),
                IconButton(
                  onPressed: _pickImageFromGallery,
                  icon: Icon(
                    Icons.image,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
