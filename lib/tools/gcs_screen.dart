import '../widgets/clinical_info_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/history_model.dart';

class GcsScreen extends StatefulWidget {
  const GcsScreen({super.key});

  @override
  State<GcsScreen> createState() => _GcsScreenState();
}

class _GcsScreenState extends State<GcsScreen> {
  int _eyeScore = 4;
  int _verbalScore = 5;
  int _motorScore = 6;

  int get _totalScore => _eyeScore + _verbalScore + _motorScore;

  String _getClassification(int score) {
    if (score >= 13) return 'Hôn mê nhẹ / Tỉnh táo (Chấn thương nhẹ)';
    if (score >= 9) return 'Hôn mê vừa (Chấn thương mức độ trung bình)';
    return 'Hôn mê nặng (Nguy cơ suy hô hấp, cân nhắc đặt NKQ)';
  }

  Color _getStatusColor(int score) {
    if (score >= 13) return Colors.teal;
    if (score >= 9) return Colors.orange;
    return Colors.red;
  }

  void _saveGcsResult() async {
    final int score = _totalScore;
    final String classification = _getClassification(score);

    final historyItem = HistoryItem(
      toolName: 'Thang điểm GCS',
      inputData: 'E: $_eyeScore, V: $_verbalScore, M: $_motorScore',
      result: '$score/15 điểm - $classification',
      createdTime: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
    );

    await DatabaseHelper.instance.insertHistory(historyItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu kết quả GCS vào Lịch sử!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int total = _totalScore;
    final Color statusColor = _getStatusColor(total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thang điểm Glasgow (GCS)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
  IconButton(
    icon: const Icon(Icons.info_outline),
    tooltip: 'Thông tin chuyên môn',
    onPressed: () {
      ClinicalInfoSheet.show(
        context,
        title: 'Thang điểm tri giác Glasgow (GCS)',
        subtitle: 'Đánh giá 3 đáp ứng lâm sàng độc lập (Tổng: 3 - 15 điểm):',
        children: [
          ClinicalInfoSheet.buildRow('E', 'Mắt (Eye)', 'Tự nhiên (4) | Lời nói (3) | Kích thích đau (2) | Không mở (1)'),
          ClinicalInfoSheet.buildRow('V', 'Lời nói (Verbal)', 'Định hướng đúng (5) | Lẫn lộn (4) | Vô nghĩa (3) | Âm khó hiểu (2) | Không đáp ứng (1)'),
          ClinicalInfoSheet.buildRow('M', 'Vận động (Motor)', 'Làm theo lệnh (6) | Gạt đúng đau (5) | Rụt chi (4) | Gập cứng mất vỏ (3) | Duỗi cứng mất não (2) | Liệt mềm (1)'),
          const Divider(height: 20),
          ClinicalInfoSheet.buildTag('13 – 15 điểm', 'Nhẹ / Tỉnh', 'Tiên lượng phục hồi tốt.', Colors.teal),
          ClinicalInfoSheet.buildTag('9 – 12 điểm', 'Hôn mê vừa', 'Tổn thương não vừa, cần theo dõi sát.', Colors.orange.shade800),
          ClinicalInfoSheet.buildTag('3 – 8 điểm', 'Hôn mê sâu / Nặng', 'Mất phản xạ bảo vệ đường thở, chỉ định đặt NKQ.', Colors.red.shade700),
        ],
      );
    },
  ),
]
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ô hiển thị tổng điểm trực tiếp
            Card(
              color: statusColor.withAlpha(25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: statusColor, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                child: Column(
                  children: [
                    Text(
                      '$total / 15',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phân loại: ${_getClassification(total)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nhóm 1: Mắt (E)
            _buildDropdownSection(
              title: '1. Mắt (Eye opening - E)',
              currentValue: _eyeScore,
              items: const [
                DropdownMenuItem(value: 4, child: Text('4 - Mở tự nhiên')),
                DropdownMenuItem(value: 3, child: Text('3 - Mở khi nghe gọi')),
                DropdownMenuItem(value: 2, child: Text('2 - Mở khi gây đau')),
                DropdownMenuItem(value: 1, child: Text('1 - Không mở mắt')),
              ],
              onChanged: (val) => setState(() => _eyeScore = val!),
            ),
            const SizedBox(height: 12),

            // Nhóm 2: Lời nói (V)
            _buildDropdownSection(
              title: '2. Lời nói (Verbal response - V)',
              currentValue: _verbalScore,
              items: const [
                DropdownMenuItem(value: 5, child: Text('5 - Trả lời đúng, nhanh nhẹn')),
                DropdownMenuItem(value: 4, child: Text('4 - Lẫn lộn, không chính xác')),
                DropdownMenuItem(value: 3, child: Text('3 - Nói lung tung, vô nghĩa')),
                DropdownMenuItem(value: 2, child: Text('2 - Kêu rên, phát ra âm thanh khó hiểu')),
                DropdownMenuItem(value: 1, child: Text('1 - Không đáp ứng lời nói')),
              ],
              onChanged: (val) => setState(() => _verbalScore = val!),
            ),
            const SizedBox(height: 12),

            // Nhóm 3: Vận động (M)
            _buildDropdownSection(
              title: '3. Vận động (Motor response - M)',
              currentValue: _motorScore,
              items: const [
                DropdownMenuItem(value: 6, child: Text('6 - Làm theo đúng y lệnh')),
                DropdownMenuItem(value: 5, child: Text('5 - Gạt đúng vị trí kích thích đau')),
                DropdownMenuItem(value: 4, child: Text('4 - Rụt chi lại khi gây đau')),
                DropdownMenuItem(value: 3, child: Text('3 - Gập cứng bất thường (mất vỏ)')),
                DropdownMenuItem(value: 2, child: Text('2 - Duỗi cứng bất thường (mất não)')),
                DropdownMenuItem(value: 1, child: Text('1 - Không đáp ứng vận động')),
              ],
              onChanged: (val) => setState(() => _motorScore = val!),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveGcsResult,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('LƯU ĐÁNH GIÁ VÀO LỊCH SỬ', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required int currentValue,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          initialValue: currentValue,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}