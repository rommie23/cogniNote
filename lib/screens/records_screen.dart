import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../database/database_helper.dart';
import 'date_entries_screen.dart';
import '../utils/pdf_export.dart'; // Add this import
import 'package:printing/printing.dart'; // Add this import
import '../component//hamburger_menu.dart';
import 'yearly_chart_screen.dart';
import 'about_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({Key? key}) : super(key: key);

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

  void _showExportOptions() {
    setState(() {
      _showDownloadOptions = true;
    });
  }

  void _cancelExport() {
    setState(() {
      _showDownloadOptions = false;
    });
  }

  Future<void> _loadAllEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allEntries = await DatabaseHelper().getAllEntries();
      _groupEntriesByDate(allEntries);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _printMonthlyData() async {
    setState(() => _isExporting = true);

    try {
      final allEntries = await DatabaseHelper().getAllEntries();
      final now = DateTime.now();

      final currentMonth = now.month;
      final currentYear = now.year;

      // Filter only current month's entries
      final monthlyEntries = allEntries.where((entry) {
        return entry.createdAt.month == currentMonth &&
            entry.createdAt.year == currentYear;
      }).toList();

      if (monthlyEntries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No entries found for this month to print.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final monthName = _getFullMonthName(currentMonth);
      final monthYear = '$monthName $currentYear';

      // PRINT / SAVE PDF
      await PdfExport.printMonthlyPDF(monthlyEntries, monthYear);
    } catch (e) {
      print("Error printing PDF: $e");
    }

    setState(() => _isExporting = false);
  }

  void _groupEntriesByDate(List<JournalEntry> entries) {
    final Map<String, List<JournalEntry>> grouped = {};

    for (final entry in entries) {
      final dateKey = _formatDateKey(entry.createdAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(entry);
    }

    // Sort dates in descending order (newest first)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final sortedMap = <String, List<JournalEntry>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    setState(() {
      _groupedEntries = sortedMap;
    });
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(String dateKey) {
    final parts = dateKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    final date = DateTime(year, month, day);

    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
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
      return '${months[month - 1]} $day, $year';
    }
  }

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

  Future<void> _downloadMonthlyData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final allEntries = await DatabaseHelper().getAllEntries();
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year;

      // Filter entries for current month
      final monthlyEntries = allEntries.where((entry) {
        return entry.createdAt.month == currentMonth &&
            entry.createdAt.year == currentYear;
      }).toList();

      if (monthlyEntries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No entries found for this month to download.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final monthName = _getFullMonthName(currentMonth);
      final monthYear = '$monthName $currentYear';

      // Download the PDF
      final downloadedPath =
          await PdfExport.downloadMonthlyPDF(monthlyEntries, monthYear);

      if (downloadedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF downloaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Failed to download PDF. Please check storage permissions.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
        _showDownloadOptions =
            false; // Add this line to hide options after download
      });
    }
  }

  Future<void> _exportMonthlyData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final allEntries = await DatabaseHelper().getAllEntries();
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year;

      // Filter entries for current month
      final monthlyEntries = allEntries.where((entry) {
        return entry.createdAt.month == currentMonth &&
            entry.createdAt.year == currentYear;
      }).toList();

      if (monthlyEntries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No entries found for this month to export.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final monthName = _getFullMonthName(currentMonth);
      final monthYear = '$monthName $currentYear';

      final pdfFile =
          await PdfExport.generateMonthlyPDF(monthlyEntries, monthYear);

      // Share the PDF
      await PdfExport.sharePDF(pdfFile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF exported successfully for $monthYear!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
        _showDownloadOptions = false;
      });
    }
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
                    Icons.history,
                    size: 28,
                    color: Color(0xFF5a189a),
                  ),
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
                  // Hamburger Menu (your existing code)
                  // ... your hamburger menu code here
                ],
              ),
              const SizedBox(height: 20),

              // Records List
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
                            backgroundColor: const Color(0xFFfaf7ff),
                            color: const Color(0xFF7b2cbf),
                            onRefresh: _loadAllEntries,
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _groupedEntries.length,
                                    itemBuilder: (context, index) {
                                      final dateKey =
                                          _groupedEntries.keys.elementAt(index);
                                      final entries = _groupedEntries[dateKey]!;
                                      final date = _formatDisplayDate(dateKey);
                                      final parts = dateKey.split('-');
                                      final day = int.parse(parts[2]);
                                      final month = int.parse(parts[1]);
                                      final year = int.parse(parts[0]);

                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DateEntriesScreen(
                                                    date: date,
                                                    dateKey: dateKey,
                                                    entries: entries,
                                                  ),
                                                ),
                                              );
                                            },
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFFe0c3fc),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  // Date Circle
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFF7b2cbf),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          day.toString(),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          _getMonthName(month),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),

                                                  // Date and Count Info
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          date,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xFF5a189a),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            color: Color(
                                                                0xFF7b2cbf),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Arrow Icon
                                                  const Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 16,
                                                    color: Color(0xFF7b2cbf),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Export Button
                                const SizedBox(height: 16),
                                _buildExportButton(),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    if (_showDownloadOptions) {
      return _buildDownloadOptions();
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isExporting ? null : _showExportOptions,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7b2cbf),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Export This Month as PDF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadOptions() {
    return Column(
      children: [
        // Download to Device Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isExporting ? null : _printMonthlyData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5a189a),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isExporting
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Preparing PDF...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.print, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Print / Save PDF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Share Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _isExporting ? null : _exportMonthlyData,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7b2cbf),
              side: const BorderSide(color: Color(0xFF7b2cbf)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share, size: 20),
                SizedBox(width: 8),
                Text(
                  'Share PDF',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Cancel Button
        TextButton(
          onPressed: _cancelExport,
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
