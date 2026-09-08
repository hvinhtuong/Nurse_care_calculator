import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/history_model.dart';
import '../widgets/clinical_info_sheet.dart';

class MorseScreen extends StatefulWidget {
  const MorseScreen({super.key});

  @override
  State<MorseScreen> createState() => _MorseScreenState();
}

class _MorseScreenState extends State<MorseScreen> {
  int _historyOfFalling = 0;
  int _secondaryDiagnosis = 0;
  int _ambulatoryAid = 0;
  int _ivAccess = 0;
  int _gait = 0;
  int _mentalStatus = 0;

  int get _totalScore =>
      _historyOfFalling +
      _secondaryDiagnosis +
      _ambulatoryAid +
      _ivAccess +
      _gait +
      _mentalStatus;

  String _getRiskLevel(int score) {
    if (score >= 45) {
      return 'Nguy cơ cao (Can thiệp dự phòng ngã tích cực, gắn chuông gọi, vòng đeo tay)';
    } else if (score >= 25) {
      return 'Nguy cơ trung bình (Áp dụng các biện pháp phòng ngừa chuẩn)';
    }
    return 'Nguy cơ thấp (Chăm sóc cơ bản, giáo dục an toàn)';
  }

  Color _getRiskColor(int score) {
    if (score >= 45) return Colors.red.shade700;
    if (score >= 25) return Colors.orange.shade800;
    return Colors.teal;
  }

  void _saveMorseResult() async {
    final int score = _totalScore;
    final String risk = _getRiskLevel(score);

    final historyItem = HistoryItem(
      toolName: 'Thang điểm Morse',
      inputData:
          'Ngã:$_historyOfFalling, Kèm:$_secondaryDiagnosis, Dụng cụ:$_ambulatoryAid, IV:$_ivAccess, Dáng đi:$_gait, TT:$_mentalStatus',
      result: '$score điểm ($risk)',
      createdTime: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
    );

    await DatabaseHelper.instance.insertHistory(historyItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu kết quả đánh giá Morse vào Lịch sử!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int total = _totalScore;
    final Color riskColor = _getRiskColor(total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thang điểm ngã Morse (MFS)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Thông tin chuyên môn',
            onPressed: () {
              ClinicalInfoSheet.show(
                context,
                title: 'Chuyên môn Thang điểm Morse (MFS)',
                subtitle: 'Gồm 6 yếu tố đánh giá lâm sàng với trọng số chuẩn hóa:',
                children: [
                  ClinicalInfoSheet.buildRow('1', 'Tiền sử ngã trong 3 tháng qua', 'Không (0) / Có (25)'),
                  ClinicalInfoSheet.buildRow('2', 'Bệnh chẩn đoán thứ phát (≥ 2 bệnh)', 'Không (0) / Có (15)'),
                  ClinicalInfoSheet.buildRow('3', 'Trợ giúp đi lại', 'Không/Liệt/Điều dưỡng (0)\nNạng/Gậy/Khung (15)\nBám tường/Đồ đạc (30)'),
                  ClinicalInfoSheet.buildRow('4', 'Đường truyền tĩnh mạch (IV lock)', 'Không (0) / Có (20)'),
                  ClinicalInfoSheet.buildRow('5', 'Dáng đi / Di chuyển', 'Bình thường/Liệt/Xe lăn (0)\nYếu (10)\nSuy giảm/Mất thăng bằng (20)'),
                  ClinicalInfoSheet.buildRow('6', 'Tình trạng tâm thần', 'Lượng đúng sức mình (0)\nQuá tự tin / Quên hạn chế (15)'),
                  const Divider(height: 20),
                  ClinicalInfoSheet.buildTag('0 – 24 điểm', 'Nguy cơ thấp', 'Chăm sóc điều dưỡng cơ bản, dặn dò an toàn.', Colors.teal),
                  ClinicalInfoSheet.buildTag('25 – 44 điểm', 'Nguy cơ trung bình', 'Áp dụng quy trình phòng ngừa ngã chuẩn.', Colors.orange.shade800),
                  ClinicalInfoSheet.buildTag('≥ 45 điểm', 'Nguy cơ cao', 'Can thiệp tích cực: chuông gọi, giường thấp, vòng cảnh báo.', Colors.red.shade700),
                ],
              );
            },
          ),
        ],
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

            _buildDropdownSection(
              title: '1. Tiền sử té ngã gần đây (trong 3 tháng qua)',
              value: _historyOfFalling,
              items: const [
                DropdownMenuItem(value: 0, child: Text('Không ngã (0 điểm)')),
                DropdownMenuItem(value: 25, child: Text('Có ngã trong 3 tháng qua (25 điểm)')),
              ],
              onChanged: (v) => setState(() => _historyOfFalling = v!),
            ),
            const SizedBox(height: 12),

            _buildDropdownSection(
              title: '2. Bệnh chẩn đoán kèm theo (≥ 2 bệnh)',
              value: _secondaryDiagnosis,
              items: const [
                DropdownMenuItem(value: 0, child: Text('Không (0 điểm)')),
                DropdownMenuItem(value: 15, child: Text('Có chẩn đoán thứ phát (15 điểm)')),
              ],
              onChanged: (v) => setState(() => _secondaryDiagnosis = v!),
            ),
            const SizedBox(height: 12),

            _buildDropdownSection(
              title: '3. Trợ giúp đi lại / Dụng cụ hỗ trợ',
              value: _ambulatoryAid,
              items: const [
                DropdownMenuItem(
                    value: 0,
                    child: Text('Không / Nằm liệt / Điều dưỡng hỗ trợ (0 điểm)')),
                DropdownMenuItem(
                    value: 15,
                    child: Text('Dùng nạng / gậy / khung tập đi (15 điểm)')),
                DropdownMenuItem(
                    value: 30,
                    child: Text('Bám vào đồ đạc, tường khi đi (30 điểm)')),
              ],
              onChanged: (v) => setState(() => _ambulatoryAid = v!),
            ),
            const SizedBox(height: 12),

            _buildDropdownSection(
              title: '4. Đang đặt kim luồn / Truyền tĩnh mạch (IV)',
              value: _ivAccess,
              items: const [
                DropdownMenuItem(value: 0, child: Text('Không (0 điểm)')),
                DropdownMenuItem(value: 20, child: Text('Có truyền dịch / Heparin lock (20 điểm)')),
              ],
              onChanged: (v) => setState(() => _ivAccess = v!),
            ),
            const SizedBox(height: 12),

            _buildDropdownSection(
              title: '5. Dáng đi & Khả năng di chuyển',
              value: _gait,
              items: const [
                DropdownMenuItem(
                    value: 0,
                    child: Text('Bình thường / Nằm liệt giường / Xe lăn (0 điểm)')),
                DropdownMenuItem(
                    value: 10,
                    child: Text('Dáng đi yếu, bước ngắn, chậm chạp (10 điểm)')),
                DropdownMenuItem(
                    value: 20,
                    child: Text('Dáng đi suy giảm, mất thăng bằng, lảo đảo (20 điểm)')),
              ],
              onChanged: (v) => setState(() => _gait = v!),
            ),
            const SizedBox(height: 12),

            _buildDropdownSection(
              title: '6. Tình trạng nhận thức về khả năng di chuyển',
              value: _mentalStatus,
              items: const [
                DropdownMenuItem(
                    value: 0,
                    child: Text('Biết rõ giới hạn bản thân (0 điểm)')),
                DropdownMenuItem(
                    value: 15,
                    child: Text('Quên hạn chế / Đánh giá quá cao khả năng (15 điểm)')),
              ],
              onChanged: (v) => setState(() => _mentalStatus = v!),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveMorseResult,
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