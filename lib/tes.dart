import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking Violation Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoFeedScreen(),
    );
  }
}

class VideoFeedScreen extends StatelessWidget {
  const VideoFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Parking Violation Detection'),
      ),
      body: const Center(
        child: StreamedVideoFeed(
          url: 'http://127.0.0.1:5001/video_feed',
        ),
      ),
    );
  }
}

class StreamedVideoFeed extends StatefulWidget {
  final String url;
  const StreamedVideoFeed({super.key, required this.url});

  @override
  _StreamedVideoFeedState createState() => _StreamedVideoFeedState();
}

class _StreamedVideoFeedState extends State<StreamedVideoFeed> {
  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.url,
      headers: const {'Cache-Control': 'no-cache'},
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Text('Error loading video feed'),
        );
      },
    );
  }
}
