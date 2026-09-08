import '../widgets/clinical_info_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/history_model.dart';

class UrineScreen extends StatefulWidget {
  const UrineScreen({super.key});

  @override
  State<UrineScreen> createState() => _UrineScreenState();
}

class _UrineScreenState extends State<UrineScreen> {
  final _volumeController = TextEditingController();
  final _weightController = TextEditingController();
  final _hoursController = TextEditingController();

  double? _urineRate;
  String? _status;
  Color _statusColor = Colors.teal;

  void _calculateUrineRate() async {
    final double? volume = double.tryParse(_volumeController.text);
    final double? weight = double.tryParse(_weightController.text);
    final double? hours = double.tryParse(_hoursController.text);

    if (volume == null || weight == null || hours == null ||
        volume < 0 || weight <= 0 || hours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập cân nặng, thời gian (>0) và lượng nước tiểu hợp lệ!')),
      );
      return;
    }

    final double rate = volume / (weight * hours);

    String statusText;
    Color color;

    if (rate >= 0.5) {
      statusText = 'Bình thường (Đạt chuẩn tưới máu thận)';
      color = Colors.teal;
    } else if (rate >= 0.1) {
      statusText = 'Thiểu niệu (Cảnh báo suy thận cấp / thiếu dịch)';
      color = Colors.orange.shade800;
    } else {
      statusText = 'Vô niệu (Nguy hiểm, cần báo bác sĩ khẩn cấp)';
      color = Colors.red.shade700;
    }

    setState(() {
      _urineRate = rate;
      _status = statusText;
      _statusColor = color;
    });

    final historyItem = HistoryItem(
      toolName: 'Nước tiểu ml/kg/h',
      inputData: '${volume}ml, ${weight}kg, ${hours}h',
      result: '${rate.toStringAsFixed(2)} ml/kg/h ($statusText)',
      createdTime: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
    );

    await DatabaseHelper.instance.insertHistory(historyItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu kết quả đo nước tiểu vào Lịch sử!')),
      );
    }
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _weightController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi Nước tiểu (ml/kg/h)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
  IconButton(
    icon: const Icon(Icons.info_outline),
    tooltip: 'Thông tin chuyên môn',
    onPressed: () {
      ClinicalInfoSheet.show(
        context,
        title: 'Đánh giá Lượng nước tiểu theo giờ',
        subtitle: 'Công thức: ml/kg/h = Nước tiểu (ml) ÷ [Cân nặng (kg) × Giờ]',
        children: [
          ClinicalInfoSheet.buildTag('≥ 0.5 ml/kg/h', 'Bình thường', 'Thận được tưới máu đầy đủ và lọc chất thải hiệu quả.', Colors.teal),
          ClinicalInfoSheet.buildTag('0.1 – 0.49 ml/kg/h', 'Thiểu niệu (Oliguria)', 'Dấu hiệu sớm của suy thận cấp (AKI) hoặc sốc giảm tuần hoàn.', Colors.orange.shade800),
          ClinicalInfoSheet.buildTag('< 0.1 ml/kg/h', 'Vô niệu (Anuria)', 'Tình trạng khẩn cấp, nguy cơ hoại tử ống thận hoặc tắc nghẽn đường tiết niệu.', Colors.red.shade700),
          const Divider(height: 20),
          const Text('• Tiêu chuẩn KDIGO: Thiểu niệu kéo dài > 6h là tiêu chuẩn chẩn đoán tổn thương thận cấp.', style: TextStyle(fontSize: 12, color: Colors.black54)),
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
            TextField(
              controller: _volumeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Tổng thể tích nước tiểu (ml)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.water_drop_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cân nặng người bệnh (kg)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _hoursController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Khoảng thời gian theo dõi (giờ)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateUrineRate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('TÍNH TOÁN & LƯU LỊCH SỬ', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),

            if (_urineRate != null)
              Card(
                elevation: 3,
                color: _statusColor.withAlpha(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: _statusColor, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        '${_urineRate!.toStringAsFixed(2)} ml/kg/h',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _statusColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _status!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                        ),
                      ),
                      const Divider(height: 24),
                      const Text(
                        'Chuẩn tham chiếu người lớn:\n• Đạt: ≥ 0.5 ml/kg/h\n• Thiểu niệu: 0.1 - < 0.5 ml/kg/h\n• Vô niệu: < 0.1 ml/kg/h',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}