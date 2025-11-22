import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/journal_entry.dart';
import 'package:printing/printing.dart';
import 'file_downloader.dart';

class PdfExport {
  static Future<File> generateMonthlyPDF(
      List<JournalEntry> entries, String monthYear) async {
    final pdf = pw.Document();

    // Get top 5 biases for the chart
    final topBiases = _getTopBiases(entries);

    // Add a page to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              'Created with love from DevLark',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.purple400,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Cognitive Journal Report',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.purple800,
                  ),
                ),
                pw.Text(
                  'Generated on: ${_formatDate(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
            pw.SizedBox(height: 15),

            // Month and summary
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.purple50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Month: $monthYear',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple900,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Total Entries: ${entries.length}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    'Total Biases Tracked: ${_getUniqueBiasesCount(entries)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Entries Header
            pw.Text(
              'Journal Entries',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.purple800,
              ),
            ),
            pw.SizedBox(height: 10),

            // Entries List
            if (entries.isEmpty)
              pw.Text(
                'No entries found for this month.',
                style: const pw.TextStyle(fontSize: 12),
              )
            else
              ...entries.map((entry) => _buildEntryWidget(entry)).toList(),

            // Bias Analysis Section (only if there are biases)
            if (topBiases.isNotEmpty) ...[
              pw.SizedBox(height: 30),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.purple50,
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: PdfColors.purple200, width: 1),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Bias Analysis for $monthYear',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.purple800,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    _buildBiasChart(topBiases),
                    pw.SizedBox(height: 15),
                    _buildBiasStats(topBiases),
                  ],
                ),
              ),
            ],
          ];
        },
      ),
    );

    // Save the PDF file
    return await _savePDF(pdf,
        'cognitive_journal_${monthYear.toLowerCase().replaceAll(' ', '_')}.pdf');
  }

  static Future<void> printMonthlyPDF(
    List<JournalEntry> entries,
    String monthYear,
  ) async {
    final pdfFile = await generateMonthlyPDF(entries, monthYear);
    final bytes = await pdfFile.readAsBytes();

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
    );
  }

  static pw.Widget _buildEntryWidget(JournalEntry entry) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.purple200, width: 1),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Date and Time - Fixed formatting
          pw.Row(
            children: [
              pw.SizedBox(width: 4),
              pw.Text(
                _formatDateOnly(entry.createdAt),
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.purple600,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Text(
                _formatTimeOnly(entry.createdAt),
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.purple600,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          // Entry Text
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              entry.text,
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),

          // Biases
          if (entry.biases.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 8),
              child: pw.Text(
                'Biases: ${entry.biases.join(", ")}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.purple700,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildBiasChart(List<MapEntry<String, int>> topBiases) {
    final total = topBiases.fold(0, (sum, entry) => sum + entry.value);
    final colors = [
      PdfColors.purple800,
      PdfColors.purple600,
      PdfColors.purple400,
      PdfColors.purple300,
      PdfColors.purple200,
    ];

    return pw.Column(
      children: [
        pw.Text(
          'Top ${topBiases.length} Biases Distribution',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.purple700,
          ),
        ),
        pw.SizedBox(height: 10),
        // Simple bar chart using containers
        ...topBiases.asMap().entries.map((entry) {
          final index = entry.key;
          final bias = entry.value;
          final percentage = (bias.value / total) * 100;

          return pw.Column(
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 12,
                    height: 12,
                    decoration: pw.BoxDecoration(
                      color: colors[index % colors.length],
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      bias.key,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    '${bias.value}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple700,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    '(${percentage.toStringAsFixed(1)}%)',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              // Bar visualization
              pw.Container(
                height: 8,
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      height: 8,
                      width: (percentage * 2), // Scale for visibility
                      decoration: pw.BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
            ],
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildBiasStats(List<MapEntry<String, int>> topBiases) {
    final total = topBiases.fold(0, (sum, entry) => sum + entry.value);
    final mostCommonBias = topBiases.isNotEmpty ? topBiases.first : null;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Quick Stats',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple800,
            ),
          ),
          pw.SizedBox(height: 8),
          if (mostCommonBias != null)
            pw.Text(
              'Most common bias: ${mostCommonBias.key} (${mostCommonBias.value} times)',
              style: const pw.TextStyle(fontSize: 10),
            ),
          pw.Text(
            'Total bias occurrences: $total',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Unique biases tracked: ${topBiases.length}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  static List<MapEntry<String, int>> _getTopBiases(List<JournalEntry> entries) {
    final biasCount = <String, int>{};

    for (final entry in entries) {
      for (final bias in entry.biases) {
        biasCount[bias] = (biasCount[bias] ?? 0) + 1;
      }
    }

    final sortedBiases = biasCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedBiases.take(5).toList();
  }

  static int _getUniqueBiasesCount(List<JournalEntry> entries) {
    final uniqueBiases = <String>{};
    for (final entry in entries) {
      uniqueBiases.addAll(entry.biases);
    }
    return uniqueBiases.length;
  }

  static String _formatDateOnly(DateTime date) {
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

  static String _formatTimeOnly(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static String _formatDateTime(DateTime date) {
    return '${_formatDateOnly(date)} • ${_formatTimeOnly(date)}';
  }

  static String _formatDate(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static Future<File> _savePDF(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');

    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<void> sharePDF(File file) async {
    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: file.path.split('/').last,
    );
  }

  static Future<String?> downloadMonthlyPDF(
      List<JournalEntry> entries, String monthYear) async {
    try {
      final pdfFile = await generateMonthlyPDF(entries, monthYear);
      final pdfBytes = await pdfFile.readAsBytes();

      final fileName =
          'cognitive_journal_${monthYear.toLowerCase().replaceAll(' ', '_')}.pdf';

      final downloadedPath =
          await FileDownloader.downloadPdfToDevice(pdfBytes, fileName);
      return downloadedPath;
    } catch (e) {
      print('Error in downloadMonthlyPDF: $e');
      return null;
    }
  }
}
