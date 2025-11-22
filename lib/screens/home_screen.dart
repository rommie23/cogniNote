import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../database/database_helper.dart';
import '../component//hamburger_menu.dart';
import 'yearly_chart_screen.dart';
import 'about_screen.dart';
import 'edit_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<JournalEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await DatabaseHelper().getTodaysEntries();
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteEntry(int id) async {
    await DatabaseHelper().deleteEntry(id);
    _loadEntries();
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 28,
                    color: Color(0xFF5a189a),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Today's Records",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5a189a),
                    ),
                  ),
                  const Spacer(),
                  HamburgerMenu(
                    options: [
                      HamburgerMenuItem(
                        label: "Yearly Chart",
                        icon: Icons.bar_chart,
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const YearlyChartScreen()),
                          );
                        },
                      ),
                      HamburgerMenuItem(
                        label: "About",
                        icon: Icons.info,
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AboutScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Entries List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF7b2cbf),
                        ),
                      )
                    : _entries.isEmpty
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
                                  'No records yet.\nStart adding your observations!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF7b2cbf),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            backgroundColor: const Color(0xFFfaf7ff),
                            color: const Color(0xFF7b2cbf),
                            onRefresh: _loadEntries,
                            child: ListView.builder(
                              itemCount: _entries.length,
                              itemBuilder: (context, index) {
                                final entry = _entries[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Date and Time
                                        Text(
                                          '${_formatDate(entry.createdAt)} • ${_formatTime(entry.createdAt)}',
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

                                        // Action Buttons
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            // Edit Button
                                            GestureDetector(
                                              behavior:
                                                  HitTestBehavior.translucent,
                                              onTap: () async {
                                                final refresh =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditEntryScreen(
                                                            entry: entry),
                                                  ),
                                                );

                                                if (refresh == true)
                                                  _loadEntries();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFe0c3fc),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 16),
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.edit,
                                                        size: 18,
                                                        color:
                                                            Color(0xFF5a189a)),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      'Edit',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF5a189a),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 12),

                                            // Delete Button
                                            Material(
                                              color: const Color(0xFFf9d6d5),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: InkWell(
                                                onTap: () =>
                                                    _showDeleteDialog(entry.id),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 8,
                                                    horizontal: 16,
                                                  ),
                                                  child: const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.delete,
                                                        size: 18,
                                                        color:
                                                            Color(0xFFb22222),
                                                      ),
                                                      SizedBox(width: 6),
                                                      Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFFb22222),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
