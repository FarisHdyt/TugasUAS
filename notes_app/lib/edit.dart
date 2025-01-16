import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditPage extends StatefulWidget {
  final int id;
  final String title;
  final String content;

  const EditPage({
    Key? key,
    required this.id,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  int contentLength = 0;  // Untuk menghitung jumlah karakter pada content

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    contentController = TextEditingController(text: widget.content);
    contentLength = widget.content.length; // Menginisialisasi panjang konten yang ada

    contentController.addListener(() {
      setState(() {
        contentLength = contentController.text.length;  // Update content length
      });
    });
  }

  Future<void> updateNote() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/api/update_note.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': widget.id,
          'title': titleController.text,
          'content': contentController.text,
        }),
      );
      if (response.statusCode == 200) {
        Navigator.pop(context, true);  // Mengembalikan true setelah berhasil mengupdate
      } else {
        print('Failed to update note: ${response.body}');
      }
    } catch (e) {
      print('Error updating note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: updateNote,  // Tombol simpan di kanan atas
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
