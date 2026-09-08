import '../widgets/clinical_info_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/history_model.dart';

class News2Screen extends StatefulWidget {
  const News2Screen({super.key});

  @override
  State<News2Screen> createState() => _News2ScreenState();
}

class _News2ScreenState extends State<News2Screen> {
  int _respScore = 0;
  int _spo2Score = 0;
  int _o2TherapyScore = 0;
  int _sbpScore = 0;
  int _pulseScore = 0;
  int _consciousScore = 0;
  int _tempScore = 0;

  int get _totalScore =>
      _respScore +
      _spo2Score +
      _o2TherapyScore +
      _sbpScore +
      _pulseScore +
      _consciousScore +
      _tempScore;

  bool get _hasSingleRedScore =>
      _respScore == 3 ||
      _spo2Score == 3 ||
      _sbpScore == 3 ||
      _pulseScore == 3 ||
      _consciousScore == 3 ||
      _tempScore == 3;

  String _getRiskClassification(int total) {
    if (total >= 7) {
      return 'Nguy cơ cao - Cảnh báo khẩn cấp (Hội chẩn ICU/MET ngay)';
    } else if (total >= 5 || _hasSingleRedScore) {
      return 'Nguy cơ trung bình (Đánh giá khẩn bởi bác sĩ điều trị)';
    }
    return 'Nguy cơ thấp (Theo dõi thường quy điều dưỡng)';
  }

  Color _getRiskColor(int total) {
    if (total >= 7) return Colors.red.shade800;
    if (total >= 5 || _hasSingleRedScore) return Colors.orange.shade800;
    return Colors.teal;
  }

  void _saveNews2Result() async {
    final int total = _totalScore;
    final String status = _getRiskClassification(total);

    final historyItem = HistoryItem(
      toolName: 'Thang điểm NEWS2',
      inputData:
          'Thở:$_respScore, SpO2:$_spo2Score, O2:$_o2TherapyScore, HA:$_sbpScore, Mạch:$_pulseScore, Ý thức:$_consciousScore, Nhiệt:$_tempScore',
      result: '$total điểm ($status)',
      createdTime: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
    );

    await DatabaseHelper.instance.insertHistory(historyItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu kết quả đánh giá NEWS2 vào Lịch sử!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int total = _totalScore;
    final Color riskColor = _getRiskColor(total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thang cảnh báo sớm NEWS2'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
  IconButton(
    icon: const Icon(Icons.info_outline),
    tooltip: 'Thông tin chuyên môn',
    onPressed: () {
      ClinicalInfoSheet.show(
        context,
        title: 'Thang cảnh báo sớm NEWS2',
        subtitle: 'Đánh giá 6 thông số sinh hiệu phát hiện sớm suy thoái:',
        children: [
          ClinicalInfoSheet.buildRow('•', 'Tần số thở (l/p)', '12-20 (0đ) | 9-11 (1đ) | 21-24 (2đ) | ≤8 hoặc ≥25 (3đ)'),
          ClinicalInfoSheet.buildRow('•', 'SpO2 (%)', '≥96 (0đ) | 94-95 (1đ) | 92-93 (2đ) | ≤91 (3đ)'),
          ClinicalInfoSheet.buildRow('•', 'Thở Oxy', 'Khí phòng (0đ) | Có hỗ trợ Oxy (2đ)'),
          ClinicalInfoSheet.buildRow('•', 'Huyết áp tâm thu', '111-219 (0đ) | 101-110 (1đ) | 91-100 (2đ) | ≤90/≥220 (3đ)'),
          ClinicalInfoSheet.buildRow('•', 'Mạch (nhịp/phút)', '51-90 (0đ) | 41-50 hoặc 91-110 (1đ) | 111-130 (2đ) | ≤40/≥131 (3đ)'),
          ClinicalInfoSheet.buildRow('•', 'Ý thức (ACVPU)', 'A - Tỉnh (0đ) | Mới lẫn lộn / V / P / U (3đ)'),
          ClinicalInfoSheet.buildRow('•', 'Nhiệt độ (°C)', '36.1-38.0 (0đ) | 35.1-36.0 / 38.1-39.0 (1đ) | ≥39.1 (2đ) | ≤35.0 (3đ)'),
          const Divider(height: 20),
          ClinicalInfoSheet.buildTag('0 – 4 điểm', 'Nguy cơ thấp', 'Theo dõi điều dưỡng định kỳ mỗi 12 giờ.', Colors.teal),
          ClinicalInfoSheet.buildTag('5 – 6 điểm', 'Nguy cơ vừa / Điểm 3 đỏ', 'Báo bác sĩ điều trị, theo dõi mỗi 4 - 6 giờ.', Colors.orange.shade800),
          ClinicalInfoSheet.buildTag('≥ 7 điểm', 'Nguy cơ cao khẩn cấp', 'Báo động cấp cứu, kích hoạt đội hồi sức ICU/MET khẩn.', Colors.red.shade800),
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
            Card(
              color: riskColor.withAlpha(25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: riskColor, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                child: Column(
                  children: [
                    Text(
                      '$total điểm',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getRiskClassification(total),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: riskColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 1. Nhịp thở
            _buildDropdown(
              title: '1. Tần số thở (lần/phút)',
              value: _respScore,
              items: const [
                DropdownMenuItem(value: 0, child: Text('12 - 20 (0 điểm)')),
                DropdownMenuItem(value: 1, child: Text('9 - 11 (1 điểm)')),
                DropdownMenuItem(value: 2, child: Text('21 - 24 (2 điểm)')),
                DropdownMenuItem(value: 3, child: Text('≤ 8 hoặc ≥ 25 (3 điểm)')),
              ],
              onChanged: (v) => setState(() => _respScore = v!),
            ),
            const SizedBox(height: 12),

            // 2. SpO2
            _buildDropdown(
              title: '2. Độ bão hòa Oxy SpO2 (%)',
              value: _spo2Score,
              items: const [
                DropdownMenuItem(value: 0, child: Text('≥ 96% (0 điểm)')),
                DropdownMenuItem(value: 1, child: Text('94 - 95% (1 điểm)')),
                DropdownMenuItem(value: 2, child: Text('92 - 93% (2 điểm)')),
                DropdownMenuItem(value: 3, child: Text('≤ 91% (3 điểm)')),
              ],
              onChanged: (v) => setState(() => _spo2Score = v!),
            ),
            const SizedBox(height: 12),

            // 3. Hỗ trợ Oxy
            _buildDropdown(
              title: '3. Có đang thở Oxy hỗ trợ không?',
              value: _o2TherapyScore,
              items: const [
                DropdownMenuItem(value: 0, child: Text('Không - Thở khí trời (0 điểm)')),
                DropdownMenuItem(value: 2, child: Text('Có - Đang thở Oxy (2 điểm)')),
              ],
              onChanged: (v) => setState(() => _o2TherapyScore = v!),
            ),
            const SizedBox(height: 12),

            // 4. Huyết áp tâm thu
            _buildDropdown(
              title: '4. Huyết áp tâm thu (mmHg)',
              value: _sbpScore,
              items: const [
                DropdownMenuItem(value: 0, child: Text('111 - 219 (0 điểm)')),
                DropdownMenuItem(value: 1, child: Text('101 - 110 (1 điểm)')),
                DropdownMenuItem(value: 2, child: Text('91 - 100 (2 điểm)')),
                DropdownMenuItem(value: 3, child: Text('≤ 90 hoặc ≥ 220 (3 điểm)')),
              ],
              onChanged: (v) => setState(() => _sbpScore = v!),
            ),
            const SizedBox(height: 12),

            // 5. Mạch
            _buildDropdown(
              title: '5. Tần số tim / Mạch (nhịp/phút)',
              value: _pulseScore,
              items: const [
                DropdownMenuItem(value: 0, child: Text('51 - 90 (0 điểm)')),
                DropdownMenuItem(value: 1, child: Text('41 - 50 hoặc 91 - 110 (1 điểm)')),
                DropdownMenuItem(value: 2, child: Text('111 - 130 (2 điểm)')),
                DropdownMenuItem(value: 3, child: Text('≤ 40 hoặc ≥ 131 (3 điểm)')),
              ],
              onChanged: (v) => setState(() => _pulseScore = v!),
            ),
            const SizedBox(height: 12),

            // 6. Ý thức
            _buildDropdown(
              title: '6. Tình trạng ý thức (ACVPU)',
              value: _consciousScore,
              items: const [
                DropdownMenuItem(value: 0, child: Text('A - Tỉnh táo hoàn toàn (0 điểm)')),
                DropdownMenuItem(value: 3, child: Text('C/V/P/U - Mới lẫn lộn / Gọi / Đau / Không đáp ứng (3 điểm)')),
              ],
              onChanged: (v) => setState(() => _consciousScore = v!),
            ),
            const SizedBox(height: 12),

            // 7. Nhiệt độ
            _buildDropdown(
              title: '7. Nhiệt độ cơ thể (°C)',
              value: _tempScore,
              items: const [
                DropdownMenuItem(value: 0, child: Text('36.1 - 38.0 °C (0 điểm)')),
                DropdownMenuItem(value: 1, child: Text('35.1 - 36.0 hoặc 38.1 - 39.0 °C (1 điểm)')),
                DropdownMenuItem(value: 2, child: Text('≥ 39.1 °C (2 điểm)')),
                DropdownMenuItem(value: 3, child: Text('≤ 35.0 °C (3 điểm)')),
              ],
              onChanged: (v) => setState(() => _tempScore = v!),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveNews2Result,
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

  Widget _buildDropdown({
    required String title,
    required int value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          initialValue: value,
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