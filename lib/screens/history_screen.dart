import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<HistoryItem>> _historyList;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyList = DatabaseHelper.instance.getAllHistory();
    });
  }

  // Xác nhận xóa toàn bộ
  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa tất cả'),
        content: const Text('Bạn có chắc chắn muốn xóa toàn bộ lịch sử không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseHelper.instance.clearHistory();
              if (!mounted) return;
              _refreshHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa sạch lịch sử!')),
              );
            },
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }

  // Xác nhận xóa từng dòng
  void _confirmDeleteSingleItem(int id, String toolName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bản ghi'),
        content: Text('Bạn có chắc chắn muốn xóa kết quả của công cụ "$toolName" này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseHelper.instance.deleteHistoryById(id);
              if (!mounted) return;
              _refreshHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa 1 bản ghi thành công!')),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử tính toán'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Xóa toàn bộ',
            onPressed: _confirmClearAll,
          ),
        ],
      ),
      body: FutureBuilder<List<HistoryItem>>(
        future: _historyList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có lịch sử tính toán nào.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: history.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                elevation: 1.5,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade50,
                    foregroundColor: Colors.teal,
                    child: Text(
                      item.toolName.length > 3 ? item.toolName.substring(0, 3) : item.toolName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.toolName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        item.createdTime,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dữ liệu: ${item.inputData}', style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          'Kết quả: ${item.result}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Nút xóa riêng cho từng dòng
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                    tooltip: 'Xóa dòng này',
                    onPressed: () {
                      if (item.id != null) {
                        _confirmDeleteSingleItem(item.id!, item.toolName);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}