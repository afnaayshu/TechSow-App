import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the camera controller
    _controller = CameraController(
      // Get the first available camera
      CameraDescription(
        name: '0',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 0, // Set the sensor orientation (adjust as needed)
      ),
      ResolutionPreset.medium,
    );

    // Initialize the camera controller asynchronously
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the camera controller when not needed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Example')),
      // Wait until the camera controller is initialized before displaying the camera preview
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the camera preview
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: () async {
          try {
            // Ensure the camera is initialized before attempting to take a picture
            await _initializeControllerFuture;

            // Construct a unique filename for the captured image
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final String filePath = '$timestamp.jpg';

            // Capture the image and save it to the device's storage
            await _controller.takePicture();

            // Display a message after the image is captured
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image saved to $filePath')),
            );
          } catch (e) {
            // If an error occurs, display it in the console
            print('Error taking picture: $e');
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
