import 'package:flutter/material.dart';
import 'package:parkvision/splash_screen.dart';

void main() {
  runApp(const Parkvision());
}

class Parkvision extends StatelessWidget {
  const Parkvision({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Splashpage(),
    );
  }
}