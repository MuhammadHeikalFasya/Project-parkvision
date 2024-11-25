import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

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
              'Pengumuman Terbaru',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            AnnouncementItem(
              title: 'Kunci motor tertinggal',
              date: '26 Oktober 2024',
              description:
                  'Ditemukan pada motor Vario dengan Nomor Plat BL 111 N',
              author: 'Shivaurahman (Satpam)',
              icon: Icons.campaign,
            ),
            AnnouncementItem(
              title: 'Tumbler tertinggal',
              date: '25 Oktober 2024',
              description: 'Ditemukan di parkiran',
              author: 'Zulkifli (Satpam)',
              icon: Icons.campaign,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            builder: (context) => const AddAnnouncementSheet(),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AnnouncementItem extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final String author;
  final IconData icon;

  const AnnouncementItem({
    super.key,
    required this.title,
    required this.date,
    required this.description,
    required this.author,
    required this.icon,
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
                Icon(icon, size: 30, color: const Color(0xFFff0d04)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
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
              'Dikirim oleh: $author',
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

class AddAnnouncementSheet extends StatelessWidget {
  const AddAnnouncementSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Sesuaikan tinggi otomatis saat keyboard terbuka
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Tambah Pengumuman',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Judul',
              labelStyle: TextStyle(
                color: Colors.black, // Warna label
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.black, width: 1.0), // Border saat tidak fokus
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.red, width: 2.0), // Border saat fokus
              ),
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Deskripsi',
              labelStyle: TextStyle(
                color: Colors.black, // Warna label
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.black, width: 1.0), // Border saat tidak fokus
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.red, width: 2.0), // Border saat fokus
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Simpan Pengumuman',
              style: TextStyle(
                  color: Colors.black), // Mengubah warna teks menjadi hitam
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}