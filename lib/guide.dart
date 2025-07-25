import 'package:flutter/material.dart';

Widget introductionStep(Function callBack) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Text(
                'Ứng dụng giúp bạn ghi chú và chăm sóc cây trồng một cách dễ dàng, khoa học và hiệu quả.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Dưới đây là một số tính năng bạn có thể sử dụng để theo dõi và chăm sóc cây:',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              buildSection('🌱 Ghi chú cây trồng', [
                buildHabit('📝 Ghi chú từng loại cây',
                    '→ Lưu thông tin về tên cây, ngày trồng, loại đất, ánh sáng, v.v.'),
                buildHabit('📷 Thêm hình ảnh cây trồng',
                    '→ Giúp bạn theo dõi sự phát triển của cây qua từng giai đoạn.'),
              ]),
              buildSection('⏰ Nhắc lịch tưới tiêu', [
                buildHabit('💧 Đặt lịch tưới định kỳ',
                    '→ Tùy chỉnh theo từng loại cây (hằng ngày, cách ngày, hàng tuần...).'),
                buildHabit('🔔 Nhận thông báo tưới nước',
                    '→ Không còn lo quên tưới cây, giúp cây luôn khỏe mạnh.'),
              ]),
              buildSection('📊 Theo dõi & phân tích', [
                buildHabit('📅 Xem lại lịch sử chăm sóc',
                    '→ Biết được bạn đã tưới lần cuối khi nào và theo dõi lịch sử đầy đủ.'),
                buildHabit('📈 Ghi chú bệnh hoặc tình trạng đặc biệt',
                    '→ Giúp bạn xử lý sâu bệnh hoặc điều chỉnh điều kiện chăm sóc kịp thời.'),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => callBack(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF388E3C), // xanh lá
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Bắt đầu chăm cây',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        )
      ],
    ),
  );
}

TextStyle get titleStyle => const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: Color(0xFF0D47A1),
    );

TextStyle get habitTitleStyle => const TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );

TextStyle get habitDescriptionStyle => const TextStyle(
      fontSize: 7,
      color: Colors.black87,
    );

Widget buildHabit(String title, String description) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: habitTitleStyle),
        // const SizedBox(height: 4),
        Text(description, style: habitDescriptionStyle),
      ],
    ),
  );
}

Widget buildSection(String heading, List<Widget> habits) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: titleStyle),
        const SizedBox(height: 12),
        ...habits,
      ],
    ),
  );
}