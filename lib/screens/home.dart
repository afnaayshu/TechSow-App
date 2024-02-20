import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:techsow/constants.dart';
import 'package:techsow/controllers/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //WeatherFactory wf = new WeatherFactory("WEATHER_API_KEY");

  int index = 0;
  // Weather data
  String? temperature;
  String? humidity;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  initializeCamera() async {
    cameras = await availableCameras();
  }

  void navigateToCameraScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CameraScreen(cameras: cameras); // Pass cameras to CameraScreen
        },
      ),
    );
  }

  Future<void> fetchWeatherData() async {
    if (await Permission.location.request().isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        await fetchWeatherDataFromCoordinates(
            position.latitude, position.longitude);
      } catch (e) {
        setState(() {
          // Update state to indicate error
          temperature = "Error fetching location";
          humidity = null;
        });
        print('Failed to fetch location: $e');
      }
    } else {
      print('Location permissions are not granted.');
    }
  }

  Future<void> fetchWeatherDataFromCoordinates(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$WEATHER_API_KEY';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          temperature = (data['main']['temp'] - 273.15)
              .toStringAsFixed(1); // Convert Kelvin to Celsius
          humidity = data['main']['humidity'].toString();
          // Extract more weather properties as needed
        });
      } else {
        setState(() {
          // Update state to indicate error
          temperature = "Error fetching weather data: ${response.statusCode}";
          humidity = null;
        });
        print('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        // Update state to indicate error
        temperature = "Error fetching weather data";
        humidity = null;
      });
      print('Error during HTTP request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        title: const Text('Techsow'),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,

      //body
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: const EdgeInsets.only(top: 80.0, left: 8.0),
            child: Text(
              'Select Crop',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 120, // Adjust the height as needed
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0), // Rounded border
                  color: Colors.white // Container background color
                  ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () {
                      print("clicked tomato");
                    },
                    child: Container(
                      width: 80, // Adjust the width and height as needed
                      height: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/tomato.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("clicked cassava");
                    },
                    child: Container(
                      width: 80, // Adjust the width and height as needed
                      height: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/cassava.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      // Handle click on the plus symbol
                    },
                    child: Container(
                      width: 80, // Adjust the width and height as needed
                      height: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors
                            .grey[300], // Background color for the plus symbol
                      ),
                      child: Icon(
                        Icons.add,
                        size: 40,
                        color: Colors.grey[600], // Color of the plus symbol
                      ),
                    ),
                  ),
                  // Add more GestureDetector widgets for additional crops
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              color: Colors.green.withOpacity(0.3),
              padding: const EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width - 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      print("clicked");
                    },
                    child: Column(
                      children: [
                        Image.asset('assets/images/fertilizer_count.png',
                            width: 80, height: 80),
                        const SizedBox(height: 20),
                        const Text(
                          'Calculate Fertilizer Count',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  GestureDetector(
                    onTap: () {
                      print("clicked another");
                    },
                    child: Column(
                      children: [
                        Image.asset('assets/images/cultivation_tips.jpeg',
                            width: 80, height: 80),
                        const SizedBox(height: 20),
                        const Text(
                          'Cultivation Tips',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),

      // Bottom Navbar
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.scanner_sharp),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon:
                Image.asset('assets/images/remote.jpg', width: 32, height: 32),
            label: 'Rover',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        showUnselectedLabels: true,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
            if (index == 1) {
              navigateToCameraScreen();
            }
          });
        },
      ),
    );
  }

  // Helper functions for color and icon
  Color _getBackgroundColor(double temperature) {
    if (temperature >= 30.0) {
      return Colors.orangeAccent;
    } else if (temperature >= 20.0) {
      return Colors.yellowAccent;
    } else if (temperature >= 10.0) {
      return Colors.lightGreenAccent;
    } else {
      return Colors.blueAccent;
    }
  }
}

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Example Page'),
//         actions:  [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () {
//               FirebaseAuth.instance.signOut();
//             },
//           ),
//         ],
//       ),
//       body: const Center(
//         child: Text(
//           'This is an example page!',
//           style: TextStyle(fontSize: 24.0),
//         ),
//       ),
//     );
//   }
// }
