import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../database/database_helper.dart';
import '../utils/bias_utils.dart';
import '../utils/pdf_export.dart';

class YearlyChartScreen extends StatefulWidget {
  const YearlyChartScreen({Key? key}) : super(key: key);

  @override
  State<YearlyChartScreen> createState() => _YearlyChartScreenState();
}

class _YearlyChartScreenState extends State<YearlyChartScreen> {
  List<MonthlyData> _monthlyData = [];
  bool _isLoading = true;
  final int _currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadYearlyData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadYearlyData(); // reloads when returning to the screen
  }

  Future<void> _loadYearlyData() async {
    setState(() => _isLoading = true);

    final allEntries = await DatabaseHelper().getAllEntries();
    final List<MonthlyData> months = [];

    for (int month = 0; month < 12; month++) {
      final biasCounts =
          BiasUtils.getBiasCountForMonth(allEntries, month, _currentYear);

      biasCounts.sort((a, b) => b.count.compareTo(a.count));

      final topFive = biasCounts.take(5).toList();

      months.add(
        MonthlyData(
          monthIndex: month,
          totalBiases: biasCounts.fold(0, (s, b) => s + b.count),
          topBiases: topFive,
        ),
      );
    }

    setState(() {
      _monthlyData = months;
      _isLoading = false;
    });
  }

  Future<void> _printMonthPDF(int monthIndex) async {
    final allEntries = await DatabaseHelper().getAllEntries();
    final month = monthIndex + 1;

    final entries = allEntries.where((entry) {
      return entry.createdAt.year == _currentYear &&
          entry.createdAt.month == month;
    }).toList();

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No data for ${_getMonthName(monthIndex)}")),
      );
      return;
    }

    final monthYear = "${_getMonthName(monthIndex)} $_currentYear";
    await PdfExport.printMonthlyPDF(entries, monthYear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfaf7ff),
      appBar: AppBar(
        title: Text("Yearly Bias Overview ($_currentYear)"),
        backgroundColor: const Color(0xFF5a189a),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7b2cbf)))
          : RefreshIndicator(
              backgroundColor: const Color(0xFFfaf7ff),
              color: const Color(0xFF7b2cbf),
              onRefresh: _loadYearlyData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 20),
                  ..._monthlyData.map((m) => _buildMonthCard(m)),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final totalBiases = _monthlyData.fold(0, (s, m) => s + m.totalBiases);

    final activeMonths =
        _monthlyData.where((m) => m.topBiases.isNotEmpty).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFf3d9ff),
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFF7b2cbf), width: 5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem("Total Biases", "$totalBiases"),
          _summaryItem("Active Months", "$activeMonths"),
          _summaryItem("Top Biases", "Top 5"),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7b2cbf)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Color(0xFF5a189a))),
      ],
    );
  }

  Widget _buildMonthCard(MonthlyData m) {
    final monthName = _getMonthName(m.monthIndex);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFf3d9ff),
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFF7b2cbf), width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthName,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5a189a)),
              ),
              if (m.topBiases.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text("Print PDF"),
                  onPressed: () => _printMonthPDF(m.monthIndex),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF5a189a),
                  ),
                ),
            ],
          ),

          if (m.topBiases.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "No data this month",
                style: TextStyle(
                  color: Color(0xFF7b2cbf),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Column(
              children: [
                // Horizontal bar chart
                const SizedBox(height: 20),
                ...m.topBiases.map((b) => _buildBar(b, m.totalBiases)),
                const SizedBox(height: 10),

                Text(
                  "Total Bias Occurrences: ${m.totalBiases}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7b2cbf),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildBar(BiasCount b, int total) {
    double percentage = (b.count / total);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${b.bias} (${b.count})",
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF3c096c),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEAD7FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              widthFactor: percentage,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF7b2cbf),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int m) {
    const names = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return names[m];
  }
}

class MonthlyData {
  final int monthIndex;
  final int totalBiases;
  final List<BiasCount> topBiases;

  MonthlyData({
    required this.monthIndex,
    required this.totalBiases,
    required this.topBiases,
  });
}
