import 'dart:io';
import 'package:farmai/guide.dart';
import 'package:farmai/plant_diary.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const PlantDiaryScreen(),
      PlantSelectionScreen(
        onPlantSelected: (selectedPlant) {
          // Navigator.pop(context); // Close the selection screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlantHomePage(
                selectedPlant: selectedPlant,
              ), // Navigate to PlantHomePage
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book, color: Colors.green),
            label: 'Nhật ký',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.green),
            label: 'Hình Ảnh Cây Trồng',
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class PlantHomePage extends StatefulWidget {
  final String selectedPlant;

  // This widget serves as the home page for plant images
  const PlantHomePage({super.key, required this.selectedPlant});
  @override
  State<PlantHomePage> createState() => _PlantHomePageState();
}

class _PlantHomePageState extends State<PlantHomePage> {
  List<File> photos = [];

  @override
  void initState() {
    super.initState();
    loadPhotos();
    checkAndShowIntro(context);
  }


  Future<void> checkAndShowIntro(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final seenIntro = prefs.getBool('seen_home_intro') ?? false;

    if (!seenIntro) {
      showReminderIntro(context);
      await prefs.setBool('seen_home_intro', true);
    }
  }

  void showReminderIntro(BuildContext context) {
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 500,
          child: introductionStep(
            () {
              Navigator.pop(context);
              // close dialog
            
            },
        ),
      ),
    ),
    );
  }


  Future<void> loadPhotos() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = Directory('${dir.path}/photos/${widget.selectedPlant}');
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
      final folder = Directory('${dir.path}/photos/${widget.selectedPlant}');
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
                    MaterialPageRoute(
                        builder: (_) => DetailImage(file: file, date: date)),
                  );
                },
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(file,
                          height: 100, width: 100, fit: BoxFit.cover),
                    ),
                    Text(date, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          if (photos.length >= 2)
            ElevatedButton(
              onPressed: () async {
                final result =
                    await compareImagesWithChatGPT(photos[0], photos[1]);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Phân tích từ GPT"),
                    content: Text(result),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Đóng")),
                    ],
                  ),
                );
              },
              child: const Text("GPT So sánh & phân tích"),
            ),

          // ElevatedButton.icon(
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: const Color(0xFF689F38),
          //     minimumSize: const Size.fromHeight(50),
          //   ),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => CompareScreen(img1: photos[0], img2: photos[1]),
          //       ),
          //     );
          //   },
          //   icon: const Icon(Icons.compare),
          //   label: const Text("So sánh ảnh gần nhất", style: TextStyle(fontSize: 16, color: Colors.blue)),
          // ),
        ],
      ),
    );
  }
}

class PlantSelectionScreen extends StatelessWidget {
  final Function(String) onPlantSelected;

  const PlantSelectionScreen({super.key, required this.onPlantSelected});

  @override
  Widget build(BuildContext context) {
    final plants = {
      "🍅 Cà chua": ["Khỏe mạnh", "Bệnh mốc sương", "Bệnh mốc lá"],
      "🌽 Ngô": ["Khỏe mạnh", "Bệnh gỉ sắt"],
      "🥔 Khoai tây": ["Khỏe mạnh", "Bệnh đốm lá sớm", "Bệnh mốc sương"],
      "🍇 Nho": ["Khỏe mạnh", "Bệnh thối đen"],
      "🌾 Lúa": ["Khỏe mạnh", "Bệnh đạo ôn lá"],
      "🌶️ Ớt": ["Khỏe mạnh", "Bệnh đốm lá"],
      // Add more plants and their conditions as needed
      "🌱 Cây trồng khác": ["Khỏe mạnh", "Bệnh khác"],
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn loại cây trồng"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: ListView.builder(
        itemCount: plants.keys.length,
        itemBuilder: (context, index) {
          final plant = plants.keys.elementAt(index);
          return ListTile(
            title: Text(plant),
            subtitle: Text(plants[plant]!.join(", ")),
            onTap: () => onPlantSelected(index.toString()),
          );
        },
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

Future<String> compareImagesWithChatGPT(File img1, File img2) async {
  final apiKey =
      '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';

  final bytes1 = await img1.readAsBytes();
  final bytes2 = await img2.readAsBytes();

  final base64Img1 = base64Encode(bytes1);
  final base64Img2 = base64Encode(bytes2);

  final uri = Uri.parse("https://api.openai.com/v1/chat/completions");

  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    "model": "gpt-4.1",
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text":
                "So sánh hai hình ảnh cây trồng này. Cây có phát triển tốt không? Có hiện tượng vàng lá, sâu bệnh, hoặc thay đổi hình dạng không? Đưa ra đánh giá và gợi ý chăm sóc nếu cần."
          },
          {
            "type": "image_url",
            "image_url": {"url": "data:image/jpeg;base64,$base64Img1"}
          },
          {
            "type": "image_url",
            "image_url": {"url": "data:image/jpeg;base64,$base64Img2"}
          }
        ]
      }
    ],
    "max_tokens": 1000
  });

  final res = await http.post(uri, headers: headers, body: body);
  if (res.statusCode == 200) {
    final responseData = jsonDecode(res.body);
    final text = responseData['choices'][0]['message']['content'];
    return text;
  } else {
    throw Exception("Lỗi khi gọi ChatGPT: ${res.statusCode} - ${res.body}");
  }
}
