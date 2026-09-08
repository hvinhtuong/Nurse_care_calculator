import '../widgets/clinical_info_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/history_model.dart';

class FluidScreen extends StatefulWidget {
  const FluidScreen({super.key});

  @override
  State<FluidScreen> createState() => _FluidScreenState();
}

class _FluidScreenState extends State<FluidScreen> {
  final _volumeController = TextEditingController();
  final _timeController = TextEditingController();
  
  // Mặc định hệ số giọt là 20 giọt/ml (bộ dây truyền thông dụng người lớn)
  int _dropFactor = 20; 
  
  double? _mlPerHour;
  double? _dropsPerMinute;

  void _calculateFluid() async {
    final double? volume = double.tryParse(_volumeController.text);
    final double? hours = double.tryParse(_timeController.text);

    if (volume == null || hours == null || volume <= 0 || hours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập thể tích và thời gian hợp lệ (> 0)!')),
      );
      return;
    }

    final double mlh = volume / hours;
    final double totalMinutes = hours * 60;
    final double dpm = (volume * _dropFactor) / totalMinutes;

    setState(() {
      _mlPerHour = mlh;
      _dropsPerMinute = dpm;
    });

    final historyItem = HistoryItem(
      toolName: 'Truyền dịch',
      inputData: 'Dịch: ${volume}ml, TG: ${hours}h, Dây: $_dropFactor gtt/ml',
      result: '${mlh.toStringAsFixed(1)} ml/h | ${dpm.round()} giọt/phút',
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
    _volumeController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tính Tốc độ Truyền dịch'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
  IconButton(
    icon: const Icon(Icons.info_outline),
    tooltip: 'Thông tin chuyên môn',
    onPressed: () {
      ClinicalInfoSheet.show(
        context,
        title: 'Công thức tính Tốc độ truyền dịch',
        subtitle: 'Chuẩn hóa tính toán lưu lượng theo y lệnh lâm sàng:',
        children: [
          ClinicalInfoSheet.buildRow('1', 'Tốc độ ml/giờ', 'Thể tích (ml) ÷ Thời gian (giờ)'),
          ClinicalInfoSheet.buildRow('2', 'Tốc độ Giọt/phút', '(Thể tích (ml) × Hệ số giọt) ÷ [Thời gian (giờ) × 60]'),
          const Divider(height: 20),
          const Text('Hệ số giọt của các loại dây truyền thông dụng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          ClinicalInfoSheet.buildRow('•', 'Dây truyền người lớn (Macrodrip)', '20 giọt/ml'),
          ClinicalInfoSheet.buildRow('•', 'Dây truyền máu (Blood set)', '15 giọt/ml'),
          ClinicalInfoSheet.buildRow('•', 'Dây truyền nhi / Bầu đếm giọt (Microdrip)', '60 giọt/ml'),
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
                labelText: 'Tổng thể tích dịch cần truyền (ml)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.water_drop_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Thời gian truyền (giờ)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer_outlined),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _dropFactor,
              decoration: const InputDecoration(
                labelText: 'Hệ số giọt của bộ dây truyền',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tune),
              ),
              items: const [
                DropdownMenuItem(value: 20, child: Text('Dây người lớn chuẩn (20 giọt/ml)')),
                DropdownMenuItem(value: 15, child: Text('Dây dịch truyền máu / đặc biệt (15 giọt/ml)')),
                DropdownMenuItem(value: 60, child: Text('Dây vi giọt nhi khoa (60 giọt/ml)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _dropFactor = val);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateFluid,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('TÍNH TOÁN & LƯU', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
            if (_mlPerHour != null && _dropsPerMinute != null)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Tốc độ truyền khuyến nghị:', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                _mlPerHour!.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
                              ),
                              const Text('ml / giờ', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                          Container(height: 40, width: 1, color: Colors.grey.shade300),
                          Column(
                            children: [
                              Text(
                                '${_dropsPerMinute!.round()}',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
                              ),
                              const Text('giọt / phút', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ],
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