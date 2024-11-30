import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import library intl
import 'package:parkvision/db__helper.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  List<Announcement> announcements = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    final loadedAnnouncements = await DatabaseHelper.instance.getAllAnnouncements();
    setState(() {
      announcements = loadedAnnouncements;
    });
  }

  String _formatDate(String rawDate) {
    final dateTime = DateTime.parse(rawDate);
    return DateFormat('dd MMMM yyyy').format(dateTime); // Format seperti "30 November 2024"
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
        child: announcements.isEmpty
            ? const Center(
                child: Text(
                  'Belum ada pengumuman',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: announcements.map((announcement) {
                  return AnnouncementItem(
                    id: announcement.id,
                    title: announcement.title,
                    date: _formatDate(announcement.date), // Format tanggal
                    description: announcement.description,
                    author: announcement.author,
                    icon: Icons.campaign,
                    onDelete: () async {
                      if (announcement.id != null) {
                        try {
                          await DatabaseHelper.instance.deleteAnnouncement(announcement.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pengumuman berhasil dihapus'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _loadAnnouncements();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal menghapus pengumuman'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  );
                }).toList(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (context) => const AddAnnouncementSheet(),
          );
          if (result == true) {
            _loadAnnouncements();
          }
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
  final int? id; // Add this
  final Function? onDelete; // Add this

  const AnnouncementItem({
    super.key,
    required this.title,
    required this.date,
    required this.description,
    required this.author,
    required this.icon,
    this.id, // Add this
    this.onDelete, // Add this
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
                if (id != null && onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Hapus Pengumuman'),
                            content: const Text('Anda yakin ingin menghapus pengumuman ini?'),
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
                                  onDelete!();
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

class AddAnnouncementSheet extends StatefulWidget {
  const AddAnnouncementSheet({super.key});

  @override
  State<AddAnnouncementSheet> createState() => _AddAnnouncementSheetState();
}

class _AddAnnouncementSheetState extends State<AddAnnouncementSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveAnnouncement() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi semua field'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final announcement = Announcement(
        title: _titleController.text,
        description: _descriptionController.text,
        date: DateTime.now().toString().split(' ')[0],
        author: 'Admin', // You might want to get this from user session
      );

      await DatabaseHelper.instance.createAnnouncement(announcement);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengumuman berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menambahkan pengumuman'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Judul',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isLoading ? null : _saveAnnouncement,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'Simpan Pengumuman',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}