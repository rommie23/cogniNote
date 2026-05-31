// All records screen, shows entire year screen //
import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../database/database_helper.dart';
import 'date_entries_screen.dart';
import '../utils/pdf_export.dart';
import '../component/hamburger_menu.dart';
import 'yearly_chart_screen.dart';
import 'about_screen.dart';
import '../theme/theme_controller.dart';
import '../screens/bias_info_screen.dart';
import '../screens/backup_restore_screen.dart';

class RecordsScreen extends StatefulWidget {
  final ThemeController themeController;
  const RecordsScreen({
    Key? key,
    required this.themeController,
  }) : super(key: key);

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  Map<String, List<JournalEntry>> _groupedEntries = {};
  bool _isLoading = true;
  bool _isExporting = false;
  bool _showDownloadOptions = false;

  @override
  void initState() {
    super.initState();
    _loadAllEntries();
  }

  Future<void> _loadAllEntries() async {
    setState(() => _isLoading = true);

    try {
      final allEntries = await DatabaseHelper().getAllEntries();
      _groupEntriesByDate(allEntries);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _groupEntriesByDate(List<JournalEntry> entries) {
    final Map<String, List<JournalEntry>> grouped = {};

    for (final entry in entries) {
      final key = _formatDateKey(entry.createdAt);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(entry);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    _groupedEntries = {for (final k in sortedKeys) k: grouped[k]!};
  }

  String _formatDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatDisplayDate(String dateKey) {
    final parts = dateKey.split('-');
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (_sameDay(date, today)) return 'Today';
    if (_sameDay(date, yesterday)) return 'Yesterday';

    const months = [
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

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _getFullMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ───────── HEADER ─────────
              Row(
                children: [
                  const Icon(Icons.history, size: 28, color: Color(0xFF5a189a)),
                  const SizedBox(width: 10),
                  const Text(
                    "All Records",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5a189a),
                    ),
                  ),
                  const Spacer(),

                  // 🌙 / 🌞 THEME TOGGLE
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: const Color(0xFF5a189a),
                    ),
                    onPressed: widget.themeController.toggleTheme,
                  ),

                  HamburgerMenu(
                    options: [
                      HamburgerMenuItem(
                        label: "Bias Guide",
                        icon: Icons.psychology,
                        onPress: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BiasInfoScreen(),
                          ),
                        ),
                      ),
                      HamburgerMenuItem(
                        label: "Yearly Chart",
                        icon: Icons.bar_chart,
                        onPress: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const YearlyChartScreen(),
                          ),
                        ),
                      ),
                      HamburgerMenuItem(
                        label: "About",
                        icon: Icons.info,
                        onPress: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutScreen(),
                          ),
                        ),
                      ),
                      HamburgerMenuItem(
                        label: "Backup & Restore",
                        icon: Icons.backup,
                        onPress: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BackupRestoreScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ───────── CONTENT ─────────
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF7b2cbf),
                        ),
                      )
                    : _groupedEntries.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history_toggle_off,
                                  size: 64,
                                  color: Color(0xFFd4c2e8),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No records found.\nStart adding your observations!',
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
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            color: const Color(0xFF7b2cbf),
                            onRefresh: _loadAllEntries,
                            child: ListView.builder(
                              itemCount: _groupedEntries.length,
                              itemBuilder: (_, index) {
                                final dateKey =
                                    _groupedEntries.keys.elementAt(index);
                                final entries = _groupedEntries[dateKey]!;
                                final date = _formatDisplayDate(dateKey);

                                final parts = dateKey.split('-');
                                final day = int.parse(parts[2]);
                                final month = int.parse(parts[1]);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DateEntriesScreen(
                                            date: date,
                                            dateKey: dateKey,
                                            entries: entries,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFe0c3fc),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF7b2cbf),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  day.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  _getMonthName(month),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  date,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF5a189a),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF7b2cbf),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Color(0xFF7b2cbf),
                                          ),
                                        ],
                                      ),
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
