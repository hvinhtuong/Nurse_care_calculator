import '../widgets/clinical_info_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/history_model.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  // Dịch vào
  final _ivFluidController = TextEditingController();
  final _oralFluidController = TextEditingController();
  final _medFluidController = TextEditingController();

  // Dịch ra
  final _urineController = TextEditingController();
  final _drainController = TextEditingController();
  final _otherLossController = TextEditingController();

  double? _totalIn;
  double? _totalOut;
  double? _fluidBalance;

  void _calculateBalance() async {
    final double iv = double.tryParse(_ivFluidController.text) ?? 0;
    final double oral = double.tryParse(_oralFluidController.text) ?? 0;
    final double med = double.tryParse(_medFluidController.text) ?? 0;

    final double urine = double.tryParse(_urineController.text) ?? 0;
    final double drain = double.tryParse(_drainController.text) ?? 0;
    final double otherLoss = double.tryParse(_otherLossController.text) ?? 0;

    final double inTotal = iv + oral + med;
    final double outTotal = urine + drain + otherLoss;

    if (inTotal == 0 && outTotal == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập ít nhất một chỉ số dịch vào hoặc ra!')),
      );
      return;
    }

    final double balance = inTotal - outTotal;

    setState(() {
      _totalIn = inTotal;
      _totalOut = outTotal;
      _fluidBalance = balance;
    });

    String status = balance > 0
        ? 'Dương (+${balance.toStringAsFixed(0)} ml)'
        : balance < 0
            ? 'Âm (${balance.toStringAsFixed(0)} ml)'
            : 'Cân bằng (0 ml)';

    final historyItem = HistoryItem(
      toolName: 'Bilan dịch',
      inputData: 'Vào: ${inTotal.toStringAsFixed(0)}ml, Ra: ${outTotal.toStringAsFixed(0)}ml',
      result: 'Bilan: $status',
      createdTime: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
    );

    await DatabaseHelper.instance.insertHistory(historyItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tính và lưu Bilan dịch vào Lịch sử!')),
      );
    }
  }

  @override
  void dispose() {
    _ivFluidController.dispose();
    _oralFluidController.dispose();
    _medFluidController.dispose();
    _urineController.dispose();
    _drainController.dispose();
    _otherLossController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color balanceColor = Colors.teal;
    if (_fluidBalance != null) {
      if (_fluidBalance! > 0) balanceColor = Colors.blue.shade700;
      if (_fluidBalance! < 0) balanceColor = Colors.orange.shade800;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi Bilan dịch (24h)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
  IconButton(
    icon: const Icon(Icons.info_outline),
    tooltip: 'Thông tin chuyên môn',
    onPressed: () {
      ClinicalInfoSheet.show(
        context,
        title: 'Cân bằng Bilan dịch (Fluid Balance)',
        subtitle: 'Công thức: Bilan dịch = Tổng dịch vào – Tổng dịch ra',
        children: [
          ClinicalInfoSheet.buildRow('IN', 'Dịch vào', 'Truyền tĩnh mạch + Máu + Ăn uống/sonde + Nước pha thuốc.'),
          ClinicalInfoSheet.buildRow('OUT', 'Dịch ra', 'Nước tiểu + Dẫn lưu vết mổ + Sonde dạ dày + Nôn ói + Phân lỏng.'),
          const Divider(height: 20),
          ClinicalInfoSheet.buildTag('Bilan Dương (+)', 'Thặng dư dịch', 'Nguy cơ quá tải tuần hoàn, tăng huyết áp, phù phổi cấp.', Colors.blue.shade700),
          ClinicalInfoSheet.buildTag('Bilan Âm (-)', 'Thiếu hụt dịch', 'Nguy cơ tụt huyết áp, giảm tưới máu thận, sốc giảm thể tích.', Colors.orange.shade800),
          ClinicalInfoSheet.buildTag('Bilan Cân bằng', '0 ± 200ml', 'Cân bằng sinh lý ổn định.', Colors.teal),
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
            // Hiển thị kết quả tính toán nếu có
            if (_fluidBalance != null) ...[
              Card(
                color: balanceColor.withAlpha(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: balanceColor, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        _fluidBalance! > 0
                            ? '+${_fluidBalance!.toStringAsFixed(0)} ml'
                            : '${_fluidBalance!.toStringAsFixed(0)} ml',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: balanceColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fluidBalance! > 0
                            ? 'Bilan Dương (Thặng dư dịch)'
                            : _fluidBalance! < 0
                                ? 'Bilan Âm (Thiếu hụt dịch)'
                                : 'Bilan Cân bằng',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: balanceColor,
                        ),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Tổng vào: ${_totalIn!.toStringAsFixed(0)} ml',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text('Tổng ra: ${_totalOut!.toStringAsFixed(0)} ml',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Khối DỊCH VÀO
            Text('1. DỊCH VÀO (IN)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
            const SizedBox(height: 8),
            _buildInputField(_ivFluidController, 'Truyền dịch / Máu / Đạm (ml)'),
            const SizedBox(height: 8),
            _buildInputField(_oralFluidController, 'Ăn uống / Nuôi sonde (ml)'),
            const SizedBox(height: 8),
            _buildInputField(_medFluidController, 'Thuốc tiêm / Dịch pha thuốc (ml)'),
            const SizedBox(height: 20),

            // Khối DỊCH RA
            Text('2. DỊCH RA (OUT)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
            const SizedBox(height: 8),
            _buildInputField(_urineController, 'Nước tiểu (ml)'),
            const SizedBox(height: 8),
            _buildInputField(_drainController, 'Dẫn lưu / Sonde dạ dày (ml)'),
            const SizedBox(height: 8),
            _buildInputField(_otherLossController, 'Nôn ói / Tiêu chảy / Khác (ml)'),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _calculateBalance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('TÍNH BILAN & LƯU LỊCH SỬ', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}