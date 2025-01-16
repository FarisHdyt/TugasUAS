import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  int contentLength = 0;  // Untuk menghitung jumlah karakter pada content

  @override
  void initState() {
    super.initState();
    contentController.addListener(() {
      setState(() {
        contentLength = contentController.text.length;  // Update content length
      });
    });
  }

  Future<void> addNote() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/add_note.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': titleController.text,
          'content': contentController.text,
        }),
      );
      if (response.statusCode == 200) {
        Navigator.pop(context, true);  // Mengembalikan true setelah berhasil menambahkan
      } else {
        print('Failed to add note: ${response.body}');
      }
    } catch (e) {
      print('Error adding note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: addNote,  // Tombol simpan di kanan atas
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                filled: true,
                fillColor: Colors.black26, // Warna gelap untuk background text field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  filled: true,
                  fillColor: Colors.black26, // Warna gelap untuk background text field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,  // Tidak ada batasan baris
              ),
            ),
            // Menambahkan widget untuk menampilkan jumlah karakter
            Text(
              'Characters: $contentLength',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
