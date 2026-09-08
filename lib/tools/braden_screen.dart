import '../widgets/clinical_info_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/history_model.dart';

class BradenScreen extends StatefulWidget {
  const BradenScreen({super.key});

  @override
  State<BradenScreen> createState() => _BradenScreenState();
}

class _BradenScreenState extends State<BradenScreen> {
  int _sensory = 4;
  int _moisture = 4;
  int _activity = 4;
  int _mobility = 4;
  int _nutrition = 4;
  int _friction = 3;

  int get _totalScore =>
      _sensory + _moisture + _activity + _mobility + _nutrition + _friction;

  String _getRiskLevel(int score) {
    if (score <= 9) return 'Nguy cơ rất cao (Cần can thiệp chống loét tích cực)';
    if (score <= 12) return 'Nguy cơ cao (Xoay trở 2h/lần, đệm khí/nước)';
    if (score <= 14) return 'Nguy cơ trung bình (Chăm sóc da, đổi tư thế)';
    if (score <= 18) return 'Nguy cơ nhẹ / thấp (Theo dõi định kỳ)';
    return 'Không có nguy cơ loét ép';
  }

  Color _getRiskColor(int score) {
    if (score <= 9) return Colors.red.shade900;
    if (score <= 12) return Colors.red;
    if (score <= 14) return Colors.orange.shade800;
    if (score <= 18) return Colors.amber.shade800;
    return Colors.teal;
  }

  void _saveBradenResult() async {
    final int score = _totalScore;
    final String risk = _getRiskLevel(score);

    final historyItem = HistoryItem(
      toolName: 'Thang điểm Braden',
      inputData: 'S:$_sensory, M:$_moisture, A:$_activity, Mob:$_mobility, N:$_nutrition, F:$_friction',
      result: '$score/23 điểm ($risk)',
      createdTime: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
    );

    await DatabaseHelper.instance.insertHistory(historyItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu kết quả đánh giá Braden vào Lịch sử!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int total = _totalScore;
    final Color riskColor = _getRiskColor(total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thang điểm Braden (Loét ép)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
  IconButton(
    icon: const Icon(Icons.info_outline),
    tooltip: 'Thông tin chuyên môn',
    onPressed: () {
      ClinicalInfoSheet.show(
        context,
        title: 'Thang điểm Braden (Nguy cơ loét)',
        subtitle: 'Đánh giá 6 yếu tố cơ bản (Tổng điểm từ 6 đến 23):',
        children: [
          ClinicalInfoSheet.buildRow('1', 'Cảm giác (Sensory)', 'Mất hẳn (1) → Không giảm (4)'),
          ClinicalInfoSheet.buildRow('2', 'Độ ẩm (Moisture)', 'Ẩm ướt liên tục (1) → Khô ráo (4)'),
          ClinicalInfoSheet.buildRow('3', 'Hoạt động (Activity)', 'Liệt giường (1) → Đi lại tốt (4)'),
          ClinicalInfoSheet.buildRow('4', 'Di chuyển (Mobility)', 'Bất động (1) → Tự do (4)'),
          ClinicalInfoSheet.buildRow('5', 'Dinh dưỡng (Nutrition)', 'Rất kém (1) → Rất tốt (4)'),
          ClinicalInfoSheet.buildRow('6', 'Ma sát (Friction)', 'Vấn đề rõ (1) → Không vấn đề (3)'),
          const Divider(height: 20),
          ClinicalInfoSheet.buildTag('≤ 9 điểm', 'Nguy cơ rất cao', 'Cần can thiệp chống loét tích cực toàn diện.', Colors.red.shade900),
          ClinicalInfoSheet.buildTag('10 – 12 điểm', 'Nguy cơ cao', 'Xoay trở 2h/lần, dùng đệm khí giảm áp.', Colors.red),
          ClinicalInfoSheet.buildTag('13 – 14 điểm', 'Nguy cơ vừa', 'Chăm sóc giữ khô da, đổi tư thế.', Colors.orange.shade800),
          ClinicalInfoSheet.buildTag('15 – 18 điểm', 'Nguy cơ nhẹ', 'Dinh dưỡng đầy đủ, theo dõi sát.', Colors.amber.shade800),
          ClinicalInfoSheet.buildTag('> 18 điểm', 'Không có nguy cơ', 'Chăm sóc sinh hoạt thường quy.', Colors.teal),
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
            // Ô hiển thị kết quả trực tiếp
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
                      '$total / 23',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getRiskLevel(total),
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

            // 1. Cảm giác giác quan
            _buildDropdownSection(
              title: '1. Cảm giác giác quan (Sensory)',
              value: _sensory,
              items: const [
                DropdownMenuItem(value: 4, child: Text('4 - Không suy giảm (đáp ứng tốt)')),
                DropdownMenuItem(value: 3, child: Text('3 - Giảm nhẹ (đáp ứng lệnh nói)')),
                DropdownMenuItem(value: 2, child: Text('2 - Giảm nhiều (chỉ đáp ứng đau)')),
                DropdownMenuItem(value: 1, child: Text('1 - Mất hoàn toàn (không đáp ứng)')),
              ],
              onChanged: (v) => setState(() => _sensory = v!),
            ),
            const SizedBox(height: 12),

            // 2. Độ ẩm
            _buildDropdownSection(
              title: '2. Độ ẩm của da (Moisture)',
              value: _moisture,
              items: const [
                DropdownMenuItem(value: 4, child: Text('4 - Hiếm khi ẩm ướt (da khô ráo)')),
                DropdownMenuItem(value: 3, child: Text('3 - Thỉnh thoảng ẩm (thay ga 1 lần/ngày)')),
                DropdownMenuItem(value: 2, child: Text('2 - Thường xuyên ẩm (thay ga mỗi ca)')),
                DropdownMenuItem(value: 1, child: Text('1 - Ẩm ướt liên tục (mồ hôi, tiểu tiện)')),
              ],
              onChanged: (v) => setState(() => _moisture = v!),
            ),
            const SizedBox(height: 12),

            // 3. Hoạt động
            _buildDropdownSection(
              title: '3. Mức độ hoạt động (Activity)',
              value: _activity,
              items: const [
                DropdownMenuItem(value: 4, child: Text('4 - Đi lại thường xuyên')),
                DropdownMenuItem(value: 3, child: Text('3 - Thỉnh thoảng đi lại (quãng ngắn)')),
                DropdownMenuItem(value: 2, child: Text('2 - Ngồi tại ghế (không tự đi)')),
                DropdownMenuItem(value: 1, child: Text('1 - Nằm liệt giường hoàn toàn')),
              ],
              onChanged: (v) => setState(() => _activity = v!),
            ),
            const SizedBox(height: 12),

            // 4. Di chuyển
            _buildDropdownSection(
              title: '4. Khả năng dịch chuyển tư thế (Mobility)',
              value: _mobility,
              items: const [
                DropdownMenuItem(value: 4, child: Text('4 - Không hạn chế (tự xoay trở tốt)')),
                DropdownMenuItem(value: 3, child: Text('3 - Hạn chế nhẹ (tự đổi tư thế nhỏ)')),
                DropdownMenuItem(value: 2, child: Text('2 - Hạn chế nhiều (cần trợ giúp nhiều)')),
                DropdownMenuItem(value: 1, child: Text('1 - Bất động hoàn toàn')),
              ],
              onChanged: (v) => setState(() => _mobility = v!),
            ),
            const SizedBox(height: 12),

            // 5. Dinh dưỡng
            _buildDropdownSection(
              title: '5. Tình trạng dinh dưỡng (Nutrition)',
              value: _nutrition,
              items: const [
                DropdownMenuItem(value: 4, child: Text('4 - Rất tốt (ăn hết khẩu phần)')),
                DropdownMenuItem(value: 3, child: Text('3 - Đầy đủ (> 1/2 khẩu phần / nuôi sonde đủ)')),
                DropdownMenuItem(value: 2, child: Text('2 - Không đầy đủ (ăn 1/2 khẩu phần)')),
                DropdownMenuItem(value: 1, child: Text('1 - Rất kém (ăn < 1/3 khẩu phần)')),
              ],
              onChanged: (v) => setState(() => _nutrition = v!),
            ),
            const SizedBox(height: 12),

            // 6. Ma sát và trượt xước
            _buildDropdownSection(
              title: '6. Ma sát & Trượt xước (Friction & Shear)',
              value: _friction,
              items: const [
                DropdownMenuItem(value: 3, child: Text('3 - Không có vấn đề (tự nâng mình lên)')),
                DropdownMenuItem(value: 2, child: Text('2 - Có vấn đề tiềm tàng (yếu, dễ trượt)')),
                DropdownMenuItem(value: 1, child: Text('1 - Vấn đề rõ rệt (trượt liên tục, co cứng)')),
              ],
              onChanged: (v) => setState(() => _friction = v!),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveBradenResult,
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