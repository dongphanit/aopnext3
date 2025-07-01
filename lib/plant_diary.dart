import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class PlantDiaryScreen extends StatefulWidget {
  const PlantDiaryScreen({super.key});

  @override
  State<PlantDiaryScreen> createState() => _PlantDiaryScreenState();
}

class _PlantDiaryScreenState extends State<PlantDiaryScreen> {
  List<FileSystemEntity> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<Directory> getNoteDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final noteDir = Directory('${dir.path}/plant_notes');
    if (!await noteDir.exists()) await noteDir.create();
    return noteDir;
  }

  Future<void> loadNotes() async {
    final dir = await getNoteDir();
    final files = dir.listSync()
      ..sort((a, b) => b.path.compareTo(a.path));
    setState(() {
      notes = files;
    });
  }
  Future<void> addNote() async {
    final controller = TextEditingController();
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          "📝 Ghi chú ngày $dateStr",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF4CAF50),
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: "Ví dụ: Trời mưa nhẹ, hôm nay bón phân kali...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Huỷ",
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final dir = await getNoteDir();
              final noteFile = File('${dir.path}/$dateStr-${DateTime.now().microsecondsSinceEpoch}.txt');
              await noteFile.writeAsString(controller.text);
              if (mounted) {
                Navigator.pop(ctx);
                await loadNotes();
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  Future<String> readNote(FileSystemEntity file) async {
    return await File(file.path).readAsString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📔 Nhật ký cây trồng"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.note_add),
      ),
      body: notes.isEmpty
          ? const Center(child: Text("Chưa có ghi chú nào."))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final file = notes[index];
                final date = file.path.split('/').last.split('-').take(3).join('-');
                
                return ListTile(
                  title: Text("🗓 $date"),
                  subtitle: const Text("Nhấn để xem chi tiết"),
                  onTap: () async {
                    final content = await readNote(file);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiaryDetailScreen(date: date, content: content),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
class DiaryDetailScreen extends StatelessWidget {
  final String date;
  final String content;

  const DiaryDetailScreen({super.key, required this.date, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📝 Ghi chú ngày $date"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ngày: $date",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
