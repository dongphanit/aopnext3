import 'dart:io';
import 'package:farmai/plant_diary.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const FarmAI());

class FarmAI extends StatelessWidget {
  const FarmAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmAI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainTabController(),
    );
  }
}

class MainTabController extends StatefulWidget {
  const MainTabController({super.key});

  @override
  State<MainTabController> createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PlantDiaryScreen(),
    const PlantHomePage(),
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
           BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Nhật ký',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Hình Ảnh Cây Trồng',
          ),
         
        ],
      ),
    );
  }
}


class PlantHomePage extends StatefulWidget {
  const PlantHomePage({super.key});
  @override
  State<PlantHomePage> createState() => _PlantHomePageState();
}

class _PlantHomePageState extends State<PlantHomePage> {
  List<File> photos = [];

  @override
  void initState() {
    super.initState();
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = Directory('${dir.path}/photos');
    if (await path.exists()) {
      final files = path.listSync().whereType<File>().toList()
        ..sort((a, b) => b.path.compareTo(a.path));
      setState(() => photos = files);
    }
  }

  Future<void> capturePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/photos');
      if (!await folder.exists()) await folder.create();
      final now = DateTime.now();
      final name = "${now.year}-${now.month}-${now.day}_${now.microsecond}.jpg";
      final saved = await File(picked.path).copy('${folder.path}/$name');
      setState(() => photos.insert(0, saved));
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = photos.isNotEmpty ? photos.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 FarmAI'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4CAF50),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.camera_alt),
        label: const Text("Chụp ảnh hôm nay"),
        onPressed: capturePhoto,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (today != null) ...[
            Text(
              "📸 Ảnh hôm nay (${today.path.split('/').last.split('_').first})",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(today, height: 220, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            "🗓 Ảnh các ngày trước",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: photos.skip(1).map((file) {
              final date = file.path.split('/').last.split('_').first;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailImage(file: file, date: date)),
                  );
                },
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(file, height: 100, width: 100, fit: BoxFit.cover),
                    ),
                    Text(date, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          if (photos.length >= 2)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF689F38),
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompareScreen(img1: photos[0], img2: photos[1]),
                  ),
                );
              },
              icon: const Icon(Icons.compare),
              label: const Text("So sánh ảnh gần nhất", style: TextStyle(fontSize: 16, color: Colors.blue)),
            ),
        ],
      ),
    );
  }
}

class DetailImage extends StatelessWidget {
  final File file;
  final String date;
  const DetailImage({super.key, required this.file, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ảnh ngày $date")),
      body: Center(child: Image.file(file)),
    );
  }
}

class CompareScreen extends StatelessWidget {
  final File img1;
  final File img2;
  const CompareScreen({super.key, required this.img1, required this.img2});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('So sánh ảnh cây')),
      body: Row(
        children: [
          Expanded(child: Image.file(img1, fit: BoxFit.cover)),
          Expanded(child: Image.file(img2, fit: BoxFit.cover)),
        ],
      ),
    );
  }
}
