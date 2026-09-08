import '../widgets/clinical_info_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/history_model.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  double? _bmi;
  String _classification = '';
  Color _resultColor = Colors.teal;

  void _calculateBmi() async {
    final double? weight = double.tryParse(_weightController.text);
    final double? heightCm = double.tryParse(_heightController.text);

    if (weight == null || heightCm == null || weight <= 0 || heightCm <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập cân nặng và chiều cao hợp lệ!')),
      );
      return;
    }

    final double heightM = heightCm / 100;
    final double bmiValue = weight / (heightM * heightM);

    String status;
    Color color;

    // Phân loại BMI theo chuẩn WHO cho người châu Á (IDI & WPRO)
    if (bmiValue < 18.5) {
      status = 'Gầy (Thiếu cân)';
      color = Colors.orange;
    } else if (bmiValue < 23.0) {
      status = 'Bình thường';
      color = Colors.green;
    } else if (bmiValue < 25.0) {
      status = 'Thừa cân (Tiền béo phì)';
      color = Colors.deepOrange;
    } else {
      status = 'Béo phì';
      color = Colors.red;
    }

    setState(() {
      _bmi = bmiValue;
      _classification = status;
      _resultColor = color;
    });

    // Lưu kết quả vào SQLite
    final historyItem = HistoryItem(
      toolName: 'BMI',
      inputData: 'CN: ${weight}kg, CC: ${heightCm}cm',
      result: '${bmiValue.toStringAsFixed(1)} ($status)',
      createdTime: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
    );
    await DatabaseHelper.instance.insertHistory(historyItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu kết quả vào Lịch sử!')),
      );
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tính Chỉ số Khối Cơ thể (BMI)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
  IconButton(
    icon: const Icon(Icons.info_outline),
    tooltip: 'Thông tin chuyên môn',
    onPressed: () {
      ClinicalInfoSheet.show(
        context,
        title: 'Chỉ số khối cơ thể (BMI WPRO)',
        subtitle: 'Công thức: BMI = Cân nặng (kg) / [Chiều cao (m)]²',
        children: [
          const Text('Tiêu chuẩn phân loại cho người Châu Á (IDI & WPRO):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          ClinicalInfoSheet.buildTag('< 18.5', 'Gầy / Thiếu cân', 'Nguy cơ suy dinh dưỡng, giảm miễn dịch.', Colors.blue),
          ClinicalInfoSheet.buildTag('18.5 – 22.9', 'Bình thường', 'Cân nặng lý tưởng theo thể trạng người Việt.', Colors.teal),
          ClinicalInfoSheet.buildTag('23.0 – 24.9', 'Thừa cân / Tiền béo phì', 'Cần điều chỉnh chế độ ăn và vận động.', Colors.amber.shade800),
          ClinicalInfoSheet.buildTag('25.0 – 29.9', 'Béo phì độ I', 'Nguy cơ tim mạch, rối loạn chuyển hóa.', Colors.orange.shade800),
          ClinicalInfoSheet.buildTag('≥ 30.0', 'Béo phì độ II', 'Nguy cơ biến chứng bệnh mạn tính rất cao.', Colors.red.shade700),
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
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cân nặng (kg)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Chiều cao (cm)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.height),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateBmi,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('TÍNH TOÁN & LƯU', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
            if (_bmi != null)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Chỉ số BMI của người bệnh:', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        _bmi!.toStringAsFixed(1),
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: _resultColor),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _classification,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _resultColor),
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