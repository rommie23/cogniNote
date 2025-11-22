import '../models/journal_entry.dart';

class BiasUtils {
  static List<BiasCount> getBiasCountForMonth(
      List<JournalEntry> allEntries, int month, int year) {
    final Map<String, int> biasCount = {};

    // Filter entries for the specific month and year
    final monthEntries = allEntries.where((entry) {
      final entryDate = entry.createdAt;
      return entryDate.month == month + 1 && entryDate.year == year;
    }).toList();

    // Count biases
    for (final entry in monthEntries) {
      for (final bias in entry.biases) {
        biasCount[bias] = (biasCount[bias] ?? 0) + 1;
      }
    }

    // Convert to list and sort by count (descending)
    final biasList = biasCount.entries
        .map((entry) => BiasCount(bias: entry.key, count: entry.value))
        .toList();

    biasList.sort((a, b) => b.count.compareTo(a.count));

    // Return top 5 biases
    return biasList.take(5).toList();
  }
}

class BiasCount {
  final String bias;
  final int count;

  BiasCount({required this.bias, required this.count});
}
