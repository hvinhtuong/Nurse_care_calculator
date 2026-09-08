import '../widgets/clinical_info_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/history_model.dart';

class PainScreen extends StatefulWidget {
  const PainScreen({super.key});

  @override
  State<PainScreen> createState() => _PainScreenState();
}

class _PainScreenState extends State<PainScreen> {
  double _painScore = 0;

  String _getPainDescription(int score) {
    if (score == 0) return 'Không đau';
    if (score <= 3) return 'Đau nhẹ (không ảnh hưởng nhiều đến sinh hoạt)';
    if (score <= 6) return 'Đau vừa (ảnh hưởng đến giấc ngủ, vận động)';
    if (score <= 9) return 'Đau nặng (cản trở nghiêm trọng hoạt động)';
    return 'Đau dữ dội nhất có thể tưởng tượng';
  }

  Color _getPainColor(int score) {
    if (score == 0) return Colors.green;
    if (score <= 3) return Colors.lightGreen;
    if (score <= 6) return Colors.orange;
    if (score <= 9) return Colors.deepOrange;
    return Colors.red;
  }

  void _savePainScore() async {
    final int score = _painScore.round();
    final String description = _getPainDescription(score);

    final historyItem = HistoryItem(
      toolName: 'Đánh giá đau (NRS)',
      inputData: 'Điểm đau: $score/10',
      result: '$score/10 - $description',
      createdTime: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
    );

    await DatabaseHelper.instance.insertHistory(historyItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu kết quả đánh giá đau vào Lịch sử!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int score = _painScore.round();
    final Color scoreColor = _getPainColor(score);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thang điểm đau NRS (0 - 10)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
  IconButton(
    icon: const Icon(Icons.info_outline),
    tooltip: 'Thông tin chuyên môn',
    onPressed: () {
      ClinicalInfoSheet.show(
        context,
        title: 'Thang điểm đánh giá đau (NRS)',
        subtitle: 'Thang đo số từ 0 đến 10 dựa trên cảm nhận của người bệnh:',
        children: [
          ClinicalInfoSheet.buildTag('0 điểm', 'Không đau', 'Người bệnh hoàn toàn thoải mái.', Colors.teal),
          ClinicalInfoSheet.buildTag('1 – 3 điểm', 'Đau nhẹ', 'Ít ảnh hưởng sinh hoạt, có thể dùng giảm đau bậc 1 (Paracetamol).', Colors.green),
          ClinicalInfoSheet.buildTag('4 – 6 điểm', 'Đau vừa', 'Ảnh hưởng giấc ngủ, vận động; cân nhắc NSAIDs hoặc Opioid nhẹ.', Colors.orange.shade800),
          ClinicalInfoSheet.buildTag('7 – 10 điểm', 'Đau nặng / Dữ dội', 'Không thể chịu đựng, cần can thiệp Opioid mạnh hoặc hồi sức cấp cứu.', Colors.red.shade700),
          const Divider(height: 20),
          const Text('• Hướng dẫn: Đánh giá trước và sau dùng thuốc giảm đau 30-60 phút.', style: TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      );
    },
  ),
]
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Kéo thanh trượt để chọn mức độ đau của người bệnh:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: scoreColor.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(color: scoreColor, width: 3),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$score',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: scoreColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _getPainDescription(score),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: scoreColor),
              ),
            ),
            const SizedBox(height: 30),
            Slider(
              value: _painScore,
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: scoreColor,
              label: '$score',
              onChanged: (value) {
                setState(() {
                  _painScore = value;
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0 (Không đau)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('10 (Đau tột cùng)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _savePainScore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('LƯU ĐÁNH GIÁ VÀO LỊCH SỬ', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}