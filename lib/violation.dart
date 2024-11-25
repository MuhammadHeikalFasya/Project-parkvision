import 'package:flutter/material.dart';

class ViolationPage extends StatelessWidget {
  const ViolationPage({super.key});

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
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: const [
            Text(
              'Daftar Pelanggaran Parkir',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            ViolationItem(
              
              imageUrl: './assets/images/mobil1.jpg', // Ganti dengan URL gambar yang sesuai
              date: '26 Oktober 2024',
              description: 'Kendaraan parkir di tempat terlarang.',
              location: 'Area Parkir 2',
            ),
            ViolationItem(
              imageUrl: './assets/images/mobil2.jpg', // Ganti dengan URL gambar yang sesuai
              date: '25 Oktober 2024',
              description: 'Kendaraan parkir di tempat terlarang.',
              location: 'Area 7',
            ),
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

  const ViolationItem({
    super.key,
    required this.imageUrl,
    required this.date,
    required this.description,
    required this.location,
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
                const Icon(Icons.warning, size: 30, color: Colors.red), // Ikon peringatan
                const SizedBox(width: 10),
                // Menambahkan teks "Pelanggaran Parkir"
                const Expanded(
                  child: Text(
                    "Pelanggaran Parkir", // Judul Pelanggaran
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Menampilkan tanggal di sebelah kanan
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Mengatur ukuran gambar
            Image.asset(
              imageUrl,
              width: 300, // Atur lebar gambar
              height: 300, // Atur tinggi gambar
              fit: BoxFit.cover, // Atur cara menampilkan gambar
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