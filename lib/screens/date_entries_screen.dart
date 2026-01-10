import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../database/database_helper.dart';

class DateEntriesScreen extends StatefulWidget {
  final String date;
  final String dateKey;
  final List<JournalEntry> entries;

  const DateEntriesScreen({
    Key? key,
    required this.date,
    required this.dateKey,
    required this.entries,
  }) : super(key: key);

  @override
  State<DateEntriesScreen> createState() => _DateEntriesScreenState();
}

class _DateEntriesScreenState extends State<DateEntriesScreen> {
  late List<JournalEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = widget.entries;
  }

  void _deleteEntry(int id) async {
    await DatabaseHelper().deleteEntry(id);
    // Reload the entries for this date
    final allEntries = await DatabaseHelper().getAllEntries();
    final updatedEntries = allEntries.where((entry) {
      final entryDateKey = _formatDateKey(entry.createdAt);
      return entryDateKey == widget.dateKey;
    }).toList();

    setState(() {
      _entries = updatedEntries;
    });
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Entry',
          style: TextStyle(color: Color(0xFF5a189a)),
        ),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteEntry(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Entry deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfaf7ff),
      appBar: AppBar(
        title: Text(widget.date),
        backgroundColor: const Color(0xFF5a189a),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Date Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFf3d9ff),
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    left: BorderSide(
                      color: Color(0xFF7b2cbf),
                      width: 4,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.date,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5a189a),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_entries.length} ${_entries.length == 1 ? 'entry' : 'entries'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7b2cbf),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Entries List
              Expanded(
                child: _entries.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_add,
                              size: 64,
                              color: Color(0xFFd4c2e8),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No entries for this date',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF7b2cbf),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFf3d9ff),
                              borderRadius: BorderRadius.circular(14),
                              border: const Border(
                                left: BorderSide(
                                  color: Color(0xFF7b2cbf),
                                  width: 5,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Time
                                  Text(
                                    _formatTime(entry.createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF5a189a),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Entry Text
                                  Text(
                                    entry.text,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3c096c),
                                    ),
                                  ),

                                  // Biases
                                  if (entry.biases.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Biases: ${entry.biases.join(", ")}',
                                      style: const TextStyle(
                                        color: Color(0xFF7b2cbf),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
