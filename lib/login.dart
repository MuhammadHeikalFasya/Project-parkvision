  import 'package:flutter/material.dart';
  import 'package:parkvision/register.dart';

  // Kelas yang mewakili layar login responsif
  class ResponsiveLoginScreen extends StatelessWidget {
    const ResponsiveLoginScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Desktop View
              return const DesktopLoginScreen();
            } else {
              // Mobile View
              return const MobileLoginScreen();
            }
          },
        ),
      );
    }
  }

  // Desktop Login Screen
  class DesktopLoginScreen extends StatefulWidget {
    const DesktopLoginScreen({super.key});

    @override
    // ignore: library_private_types_in_public_api
    _DesktopLoginScreenState createState() => _DesktopLoginScreenState();
  }

  class _DesktopLoginScreenState extends State<DesktopLoginScreen> {
    bool _obscureText = true;

    @override
    Widget build(BuildContext context) {
      return Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Kolom dengan ukuran minimal
            crossAxisAlignment: CrossAxisAlignment.center, // Posisikan di tengah
            children: [
              Image.asset('./assets/images/logo_parkvision.png', height: 60), // menambahkan logo
              const SizedBox(height: 25),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Log in',
                  style: TextStyle(
                  color: Colors.black),
                  ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ParkVisionRegis()),
                  );
                },
                child: const Text(
                  "Belum punya akun? Daftar",
                  style: TextStyle(color: Color.fromARGB(255, 10, 10, 10)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Mobile Login Screen
  class MobileLoginScreen extends StatefulWidget {
    const MobileLoginScreen({super.key});

    @override
    // ignore: library_private_types_in_public_api
    _MobileLoginScreenState createState() => _MobileLoginScreenState();
  }

  class _MobileLoginScreenState extends State<MobileLoginScreen> {
    bool _obscureText = true;

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('./assets/images/logo_parkvision.png', height: 100), // Add logo image
            const SizedBox(height: 40),
            const Text(
              'Login to Your Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Username',
                prefixIcon: Icon(Icons.person),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              obscureText: _obscureText,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Log in',
                style: TextStyle(
                  color: Colors.black),),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ParkVisionRegis()),
                );
              },
              child: const Text(
                "Belum punya akun? Daftar",
                style: TextStyle(color: Color.fromARGB(255, 10, 10, 10)),
              ),
            ),
          ],
        ),
      );
    }
  }