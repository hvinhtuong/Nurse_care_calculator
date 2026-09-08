import '../widgets/clinical_info_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/history_model.dart';

class SyringePumpScreen extends StatefulWidget {
  const SyringePumpScreen({super.key});

  @override
  State<SyringePumpScreen> createState() => _SyringePumpScreenState();
}

class _SyringePumpScreenState extends State<SyringePumpScreen> {
  final _doseController = TextEditingController(); // mcg/kg/phút
  final _weightController = TextEditingController(); // kg
  final _drugAmountController = TextEditingController(); // mg
  final _diluentVolumeController = TextEditingController(text: '50'); // ml, mặc định bơm 50ml

  double? _flowRateMlPerHour;
  double? _concentrationMcgPerMl;

  void _calculateRate() async {
    final double? dose = double.tryParse(_doseController.text);
    final double? weight = double.tryParse(_weightController.text);
    final double? drugMg = double.tryParse(_drugAmountController.text);
    final double? volumeMl = double.tryParse(_diluentVolumeController.text);

    if (dose == null || weight == null || drugMg == null || volumeMl == null ||
        dose <= 0 || weight <= 0 || drugMg <= 0 || volumeMl <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ các thông số hợp lệ (> 0)!')),
      );
      return;
    }

    // Nồng độ dung dịch = (mg * 1000) / ml => mcg/ml
    final double concentration = (drugMg * 1000) / volumeMl;
    // Tốc độ truyền ml/h = (Liều mcg/kg/phút * Cân nặng * 60) / Nồng độ
    final double rate = (dose * weight * 60) / concentration;

    setState(() {
      _concentrationMcgPerMl = concentration;
      _flowRateMlPerHour = rate;
    });

    final historyItem = HistoryItem(
      toolName: 'Bơm tiêm điện',
      inputData: 'Liều: $dose mcg/kg/p, $weight kg, Pha $drugMg mg/$volumeMl ml',
      result: '${rate.toStringAsFixed(2)} ml/h (Nồng độ: ${concentration.toStringAsFixed(1)} mcg/ml)',
      createdTime: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
    );

    await DatabaseHelper.instance.insertHistory(historyItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu kết quả cài đặt bơm tiêm vào Lịch sử!')),
      );
    }
  }

  @override
  void dispose() {
    _doseController.dispose();
    _weightController.dispose();
    _drugAmountController.dispose();
    _diluentVolumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tốc độ Bơm tiêm điện'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
  IconButton(
    icon: const Icon(Icons.info_outline),
    tooltip: 'Thông tin chuyên môn',
    onPressed: () {
      ClinicalInfoSheet.show(
        context,
        title: 'Tính tốc độ Bơm tiêm điện (ml/h)',
        subtitle: 'Áp dụng cho các thuốc vận mạch, trợ tim liều nhỏ:',
        children: [
          ClinicalInfoSheet.buildRow('1', 'Nồng độ thuốc (mcg/ml)', '[Tổng mg thuốc × 1000] ÷ Thể tích bơm (ml)'),
          ClinicalInfoSheet.buildRow('2', 'Tốc độ ml/h', '[Liều (mcg/kg/phút) × Cân nặng (kg) × 60] ÷ Nồng độ (mcg/ml)'),
          const Divider(height: 20),
          const Text('Thuốc thường dùng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          const Text('• Noradrenaline: 4mg hoặc 8mg pha trong 50ml NaCl 0.9%\n• Dobutamine / Dopamine: 200mg pha trong 50ml\n• Adrenaline: 4mg hoặc 8mg pha trong 50ml Glucose 5%'),
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
              controller: _doseController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Liều y lệnh (mcg / kg / phút)',
                hintText: 'VD: 0.05, 0.1, 5...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication_liquid_outlined),
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _drugAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Thuốc pha (mg)',
                      hintText: 'VD: 4, 8, 200...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _diluentVolumeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Tổng thể tích pha (ml)',
                      hintText: 'Mặc định 50ml',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateRate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('TÍNH TỐC ĐỘ BƠM (ml/h)', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),

            if (_flowRateMlPerHour != null)
              Card(
                elevation: 3,
                color: Colors.teal.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.teal, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Tốc độ cài đặt trên bơm tiêm điện:',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_flowRateMlPerHour!.toStringAsFixed(2)} ml/h',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const Divider(height: 24),
                      Text(
                        'Nồng độ dung dịch: ${_concentrationMcgPerMl!.toStringAsFixed(1)} mcg/ml',
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
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