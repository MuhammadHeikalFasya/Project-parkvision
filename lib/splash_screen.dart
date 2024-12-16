import 'dart:async';
import 'package:flutter/material.dart';
import 'package:parkvision/homepage.dart';

class Splashpage extends StatelessWidget {
  const Splashpage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const ParkVisionApp(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  double _logoSize = 0.0;
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Animasi untuk logo dengan zoom-in effect
    _logoController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addListener(() {
        setState(() {
          _logoSize = _logoController.value * 100.0;
        });
      });

    // Animasi untuk teks dengan fade-in effect
    _textController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addListener(() {
        setState(() {
          _textOpacity = _textController.value;
        });
      });

    // Mulai animasi
    _logoController.forward().then((_) {
      _textController.forward();
    });

    // Menavigasi ke halaman berikutnya setelah beberapa detik
    Future.delayed(const Duration(seconds: 3), () {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeOut,
              width: _logoSize,
              height: _logoSize,
              child: Image.asset('./assets/images/icon_parkvision.png'), // Logo menggunakan image asset
            ),
            const SizedBox(height: 16.0),
            AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: _textOpacity,
              child: Image.asset(
                './assets/images/teks_parkvision.png', // Teks menggunakan image asset
                width: 200, // Sesuaikan ukuran sesuai kebutuhan
              ),
            ),
          ],
        ),
      ),
    );
  }
}