import '../tools/news2_screen.dart';
import '../tools/morse_screen.dart';
import '../tools/braden_screen.dart';
import '../tools/syringepump_screen.dart';
import '../tools/urine_screen.dart';
import '../tools/balance_screen.dart';
import '../tools/gcs_screen.dart';
import '../tools/pain_screen.dart';
import '../tools/fluid_screen.dart';
import 'history_screen.dart';
import '../tools/bmi_screen.dart';

import 'package:flutter/material.dart';

import '../models/tool_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ToolItem> _allTools = [
    ToolItem(
      id: 'pain',
      name: 'Đánh giá đau (NRS)',
      description: 'Thang điểm đau số từ 0 - 10',
      icon: Icons.sentiment_dissatisfied,
    ),
    ToolItem(
      id: 'gcs',
      name: 'Glasgow Coma Scale (GCS)',
      description: 'Đánh giá mức độ tri giác, hôn mê',
      icon: Icons.visibility,
    ),
    ToolItem(
      id: 'news2',
      name: 'NEWS2',
      description: 'Cảnh báo sớm suy thoái lâm sàng',
      icon: Icons.warning_amber_rounded,
    ),
    ToolItem(
      id: 'braden',
      name: 'Thang điểm Braden',
      description: 'Đánh giá nguy cơ loét do tỳ đè',
      icon: Icons.airline_seat_flat,
    ),
    ToolItem(
      id: 'morse',
      name: 'Thang điểm Morse',
      description: 'Đánh giá nguy cơ té ngã ở người bệnh',
      icon: Icons.transfer_within_a_station,
    ),
    ToolItem(
      id: 'fluid',
      name: 'Tốc độ truyền dịch',
      description: 'Tính ml/giờ và giọt/phút',
      icon: Icons.water_drop,
    ),
    ToolItem(
      id: 'balance',
      name: 'Bilan dịch',
      description: 'Cân bằng dịch vào - ra trong 24h',
      icon: Icons.compare_arrows,
    ),
    ToolItem(
      id: 'urine',
      name: 'Nước tiểu (ml/kg/giờ)',
      description: 'Đánh giá chức năng bài tiết theo cân nặng',
      icon: Icons.opacity,
    ),
    ToolItem(
      id: 'bmi',
      name: 'Chỉ số khối cơ thể (BMI)',
      description: 'Đánh giá tình trạng dinh dưỡng (kg/m²)',
      icon: Icons.monitor_weight,
    ),
    ToolItem(
      id: 'syringepump',
      name: 'Tốc độ bơm tiêm điện',
      description: 'Tính toán tốc độ tiêm dịch chuẩn xác',
      icon: Icons.colorize,
    ),
  ];

  List<ToolItem> _filteredTools = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredTools = _allTools;
  }

  void _filterTools(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        _filteredTools = _allTools;
      } else {
        _filteredTools = _allTools
            .where(
              (item) =>
                  item.name.toLowerCase().contains(keyword.toLowerCase()) ||
                  item.description.toLowerCase().contains(
                    keyword.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  void _navigateToTool(String toolId) {
    if (toolId == 'bmi') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BmiScreen()),
      );
    } else if (toolId == 'fluid') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FluidScreen()),
      );
    } else if (toolId == 'pain') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PainScreen()),
      );
    } else if (toolId == 'gcs') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GcsScreen()),
      );
    } else if (toolId == 'balance') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BalanceScreen()),
      );
    } else if (toolId == 'urine') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UrineScreen()),
      );
    } else if (toolId == 'syringepump') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SyringePumpScreen()),
      );
    } else if (toolId == 'braden') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BradenScreen()),
      );
    } else if (toolId == 'morse') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MorseScreen()),
      );
    } else if (toolId == 'news2') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const News2Screen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Công cụ $toolId đang được hoàn thiện')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nurse Care Calculator VN',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Lịch sử tính toán',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTools,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm công cụ...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredTools.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 64),
              itemBuilder: (context, index) {
                final tool = _filteredTools[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade50,
                    foregroundColor: Colors.teal,
                    child: Icon(tool.icon),
                  ),
                  title: Text(
                    tool.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    tool.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () => _navigateToTool(tool.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
