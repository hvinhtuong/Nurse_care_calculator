class HistoryItem {
  final int? id;
  final String toolName;
  final String inputData;
  final String result;
  final String createdTime;

  HistoryItem({
    this.id,
    required this.toolName,
    required this.inputData,
    required this.result,
    required this.createdTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tool_name': toolName,
      'input_data': inputData,
      'result': result,
      'created_time': createdTime,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'],
      toolName: map['tool_name'],
      inputData: map['input_data'],
      result: map['result'],
      createdTime: map['created_time'],
    );
  }
}