import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:parkvision/login.dart';
import 'package:parkvision/navbar.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:http/http.dart' as http;

class ParkVisionApp extends StatelessWidget {
  const ParkVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkVision',
      theme: ThemeData(
        primaryColor: Colors.grey[800],
        fontFamily: 'Arial',
      ),
      home: const NavigationRailPage(),
    );
  }
}

class MjpegVideoWidget extends StatefulWidget {
  final String streamUrl;

  const MjpegVideoWidget({
    super.key,
    required this.streamUrl,
  });

  @override
  State<MjpegVideoWidget> createState() => _MjpegVideoWidgetState();
}

class _MjpegVideoWidgetState extends State<MjpegVideoWidget> {
  Uint8List? _currentFrame;
  StreamSubscription? _streamSubscription;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToStream();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _connectToStream() async {
    try {
      final request = http.Request('GET', Uri.parse(widget.streamUrl));
      final response = await http.Client().send(request);
      
      setState(() {
        _isConnected = true;
      });

      final stream = response.stream.transform(StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);
        },
      ));

      List<int> bytes = [];
      _streamSubscription = stream.listen(
        (data) {
bytes.addAll(data as List<int>);
          
          // Look for JPEG start and end markers
          int startIndex = -1;
          int endIndex = -1;
          
          for (int i = 0; i < bytes.length - 1; i++) {
            if (bytes[i] == 0xFF && bytes[i + 1] == 0xD8) {
              startIndex = i;
            }
            if (bytes[i] == 0xFF && bytes[i + 1] == 0xD9 && startIndex != -1) {
              endIndex = i + 2;
              break;
            }
          }

          if (startIndex != -1 && endIndex != -1) {
            // Extract the JPEG image
            final imageBytes = bytes.sublist(startIndex, endIndex);
            setState(() {
              _currentFrame = Uint8List.fromList(imageBytes);
            });
            // Clear processed bytes
            bytes = bytes.sublist(endIndex);
          }
        },
        onError: (error) {
          setState(() {
            _isConnected = false;
          });
          _reconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
      _reconnect();
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _connectToStream();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to video stream...'),
          ],
        ),
      );
    }

    if (_currentFrame == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Image.memory(
      _currentFrame!,
      gaplessPlayback: true,
      fit: BoxFit.contain,
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 236, 233, 233),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Image.asset(
                  './assets/images/logo_parkvision.png',
                  height: 50,
                ),
                const SizedBox(width: 8),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResponsiveLoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return const DesktopLayout();
              } else {
                return const MobileLayout();
              }
            },
          ),
        ),
      ),
    );
  }
}

class VideoWidget extends StatelessWidget {
  const VideoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const MjpegVideoWidget(
      streamUrl: 'http://192.168.69.200:8080/video_feed',  // Replace with your backend IP
    );
  }
}

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 300,
                  child: VideoWidget(),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: StatusSlot(),
              ),
            ],
          ),
          SizedBox(height: 16),
          ParkingSlots(),
        ],
      ),
    );
  }
}

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: VideoWidget(),
          ),
          SizedBox(height: 16),
          StatusSlot(),
          SizedBox(height: 16),
          ParkingSlots(),
        ],
      ),
    );
  }
}

class StatusSlot extends StatefulWidget {
  const StatusSlot({super.key});

  @override
  State<StatusSlot> createState() => _StatusSlotState();
}

class _StatusSlotState extends State<StatusSlot> {
  int emptySlots = 0;
  int occupiedSlots = 0;
  int violationSlots = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    // Set up periodic updates every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.69.200:8080/status'),  // Replace with your backend IP
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          emptySlots = data['empty_slots'];
          occupiedSlots = data['occupied_slots'];
          violationSlots = data['violation_slots'];
        });
      }
    } catch (e) {
      print('Error fetching status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegend(Colors.green, 'Kosong'),
              _buildLegend(Colors.red, 'Melanggar'),
              _buildLegend(Colors.blue, 'Terisi'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SLOT STATUS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Text(
                'Penghitungan kendaraan yang diparkir\nStatus terkini jumlah slot parkir',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: _buildSlotCounter(Colors.black, Colors.green, emptySlots.toString()),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: _buildSlotCounter(Colors.black, Colors.red, violationSlots.toString()),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: _buildSlotCounter(Colors.black, Colors.blue, occupiedSlots.toString()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSlotCounter(Color bgColor, Color textColor, String count) {
    return Container(
      width: 80,
      height: 80,
      color: bgColor,
      child: Center(
        child: Text(
          count,
          style: TextStyle(
            color: textColor,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ParkingSlots extends StatelessWidget {
  const ParkingSlots({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BLOK A',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        if (screenWidth > 600)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
                12, (index) => ParkingSlot(slot: 'A${index + 1}')),
          )
        else
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                    6, (index) => ParkingSlot(slot: 'A${index + 1}')),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                    6, (index) => ParkingSlot(slot: 'A${index + 7}')),
              ),
            ],
          ),
        const SizedBox(height: 16),
        const Text(
          'BLOK B',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        if (screenWidth > 600)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
                12, (index) => ParkingSlot(slot: 'B${index + 1}')),
          )
        else
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                    6, (index) => ParkingSlot(slot: 'B${index + 1}')),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                    6, (index) => ParkingSlot(slot: 'B${index + 7}')),
              ),
            ],
          ),
      ],
    );
  }
}

class ParkingSlot extends StatelessWidget {
  final String slot;
  final bool isSelected;

  const ParkingSlot({super.key, required this.slot, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        slot,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}