import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ViolationPage extends StatefulWidget {
  const ViolationPage({super.key});

  @override
  State<ViolationPage> createState() => _ViolationPageState();
}

class _ViolationPageState extends State<ViolationPage> {
  List<Map<String, dynamic>> violations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchViolations();
  }

  Future<void> fetchViolations() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.196.46:8080/violations'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          violations = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching violations: $e');
    }
  }

  Future<void> deleteViolation(String imageName) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.196.46:8080/violations/$imageName'),
      );
      if (response.statusCode == 200) {
        setState(() {
          violations
              .removeWhere((violation) => violation['image'] == imageName);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pelanggaran berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error deleting violation: $e');
    }
  }

  Future<void> deleteAllViolations() async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.196.46:8080/violations'),
      );
      if (response.statusCode == 200) {
        setState(() {
          violations.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua pelanggaran berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error deleting all violations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              './assets/images/logo_parkvision.png',
              height: 50,
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 236, 233, 233),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Text(
                    'Daftar Pelanggaran',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Hapus Semua Pelanggaran'),
                            content: const Text(
                                'Anda yakin ingin menghapus semua pelanggaran?'),
                            actions: [
                              TextButton(
                                child: const Text('Batal'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: const Text(
                                  'Hapus Semua',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  deleteAllViolations();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                    ),
                    child: const Text(
                      'Hapus Semua Pelanggaran',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...violations.map((violation) => ViolationItem(
                        imageUrl:
                            'http://192.168.196.46:8080/images/captures/${violation['image']}',
                        date: violation['date'],
                        description: violation['description'],
                        location: violation['location'],
                        onDelete: deleteViolation,
                      )),
                ],
              ),
      ),
    );
  }
}

class ViolationItem extends StatelessWidget {
  final String imageUrl;
  final String date;
  final String description;
  final String location;
  final Function(String) onDelete;

  const ViolationItem({
    super.key,
    required this.imageUrl,
    required this.date,
    required this.description,
    required this.location,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, size: 30, color: Colors.red),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Pelanggaran Parkir",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Hapus Pelanggaran'),
                          content: const Text(
                              'Anda yakin ingin menghapus pelanggaran ini?'),
                          actions: [
                            TextButton(
                              child: const Text('Batal'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: const Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                onDelete(imageUrl.split('/').last);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Image.network(
              imageUrl,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 300,
                  height: 300,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lokasi: $location',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
