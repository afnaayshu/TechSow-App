import 'package:flutter/material.dart';

class RoverControlPage extends StatefulWidget {
  @override
  _RoverControlPageState createState() => _RoverControlPageState();
}

class _RoverControlPageState extends State<RoverControlPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rover Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Send command to move forward
                // Implement Bluetooth communication with ESP32 here
              },
              child: Text('Forward'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    // Send command to move left
                    // Implement Bluetooth communication with ESP32 here
                  },
                  child: Text('Left'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Send command to move right
                    // Implement Bluetooth communication with ESP32 here
                  },
                  child: Text('Right'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Send command to move backward
                // Implement Bluetooth communication with ESP32 here
              },
              child: Text('Backward'),
            ),
          ],
        ),
      ),
    );
  }
}
