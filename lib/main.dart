import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:techsow/controllers/rover_controller.dart';
import 'package:techsow/screens/home.dart';
import 'package:techsow/screens/profile.dart';
import 'package:techsow/screens/welcome_screen.dart';
import 'package:techsow/theme/theme.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

   // Get available cameras
  final cameras = await availableCameras();
  final camera = cameras.first; // Assuming you want the first camera
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
          return HomePage();
        } else {
          return const WelcomeScreen();
        }
        }
      ),
      routes: {
        '/home': (context) => HomePage(),
        '/rover': (context) => RoverControlPage(), // Define the IoT app development page route
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}