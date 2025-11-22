class JournalEntry {
  final int id;
  final String text;
  final List<String> biases;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.text,
    required this.biases,
    required this.createdAt,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      text: map['content'],
      biases: (map['biases'] as String).split(','),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': text,
      'biases': biases.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
