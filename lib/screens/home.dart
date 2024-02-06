import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example Page'),
      ),
      body: const Center(
        child: Text(
          'This is an example page!',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
