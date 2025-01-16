import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit.dart';
import 'add.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white, fontSize: 18),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 14),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List notes = [];
  final String baseUrl = 'http://10.0.2.2/api/';

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}get_notes.php'));
      if (response.statusCode == 200) {
        final List<dynamic> responseBody = json.decode(response.body);
        setState(() {
          notes = responseBody.map((note) {
            note['id'] = int.tryParse(note['id'].toString()) ?? 0;
            return note;
          }).toList();
        });
      } else {
        print('Failed to fetch notes: ${response.body}');
      }
    } catch (e) {
      print('Error fetching notes: $e');
    }
  }

  void navigateToEditPage(int id, String title, String content) async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPage(id: id, title: title, content: content),
      ),
    );
    if (result == true) {
      fetchNotes();  // Memperbarui data setelah pengeditan selesai
    }
  }

  void navigateToAddPage() async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPage(),
      ),
    );
    if (result == true) {
      fetchNotes();  // Memperbarui data setelah penambahan selesai
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}delete_note.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );
      if (response.statusCode == 200) {
        // Hapus catatan dari daftar secara lokal setelah berhasil dihapus di backend
        setState(() {
          notes.removeWhere((note) => note['id'] == id);
        });
      } else {
        print('Failed to delete note: ${response.body}');
      }
    } catch (e) {
      print('Error deleting note: $e');
    }
  }

  // Fungsi untuk menampilkan konfirmasi sebelum menghapus
  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Menutup dialog tanpa menghapus
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteNote(id);  // Hapus catatan jika konfirmasi
                Navigator.of(context).pop();  // Menutup dialog setelah penghapusan
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
        centerTitle: true,
      ),
      body: notes.isEmpty
          ? const Center(child: Text('No notes available.'))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                // Potong konten jika lebih dari 100 karakter
                String contentPreview = note['content'].length > 100
                    ? note['content'].substring(0, 100) + '...'
                    : note['content'];

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[600]!, width: 2), // Warna abu-abu gelap
                    borderRadius: BorderRadius.circular(8), // Sudut melengkung
                    color: Colors.black87, // Warna latar belakang lebih gelap
                  ),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note['title'],
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        // Menambahkan garis bawah judul dengan warna lebih lembut
                        Container(
                          margin: const EdgeInsets.only(top: 8.0),
                          height: 2.0,
                          color: Colors.grey[600], // Warna garis bawah abu-abu gelap
                        ),
                      ],
                    ),
                    subtitle: Text(
                      contentPreview,  // Menampilkan potongan konten
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () => navigateToEditPage(note['id'], note['title'], note['content']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _showDeleteConfirmationDialog(note['id']),  // Tampilkan dialog konfirmasi
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddPage,
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,  // Warna hijau zamrud untuk tombol
      ),
    );
  }
}
