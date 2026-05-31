// this is landing screen or add entry screen //

import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../database/database_helper.dart';
import '../component/hamburger_menu.dart';
import '../ai/bias_detector.dart';
import 'yearly_chart_screen.dart';
import 'about_screen.dart';
import '../theme/theme_controller.dart';
import '../screens/bias_info_screen.dart';
import '../data/bias_data.dart';
import '../screens/backup_restore_screen.dart';

class InsertScreen extends StatefulWidget {
  final ThemeController themeController;

  const InsertScreen({
    Key? key,
    required this.themeController,
  }) : super(key: key);

  @override
  State<InsertScreen> createState() => _InsertScreenState();
}

class _InsertScreenState extends State<InsertScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _selectedBiases = [];
  List<String> _suggestedBiases = [];
  int? _openCategory;

  void _updateSuggestions() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() => _suggestedBiases = []);
      return;
    }
    setState(() {
      _suggestedBiases = BiasDetector.detectBiases(text);
    });
  }

  void _toggleBias(String bias) {
    setState(() {
      if (_selectedBiases.contains(bias)) {
        _selectedBiases.remove(bias);
      } else {
        _selectedBiases.add(bias);
      }
    });
  }

  void _toggleCategory(int index) {
    setState(() {
      _openCategory = _openCategory == index ? null : index;
    });
  }

  /// ───────────────── SAVE ENTRY ────────────────
  void _saveEntry() async {
    final text = _textController.text.trim();

    /// REMOVE INVALID BIASES
    _selectedBiases.removeWhere(
      (bias) => bias.trim().isEmpty,
    );

    print("SELECTED BIASES: $_selectedBiases");
    print("COUNT: ${_selectedBiases.length}");

    /// VALIDATE TEXT
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please write something first!',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    /// VALIDATE BIAS
    if (_selectedBiases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one bias!',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    /// CREATE ENTRY
    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch,
      text: text,
      biases: _selectedBiases,
      createdAt: DateTime.now(),
    );

    /// SAVE
    await DatabaseHelper().insertEntry(entry);

    /// SAFETY
    if (!mounted) return;

    /// CLEAR UI
    _textController.clear();

    setState(() {
      _selectedBiases.clear();

      _suggestedBiases.clear();
    });

    /// SUCCESS
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Entry saved!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputBox(),
                    const SizedBox(height: 12),
                    _buildSuggestedBiases(),
                    const SizedBox(height: 20),
                    _buildBiasCategories(),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 6,
                    ),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ───────────────── HEADER ─────────────────

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 28, color: Color(0xFF5a189a)),
          const SizedBox(width: 10),
          const Text(
            'Add Observation',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5a189a),
            ),
          ),
          const Spacer(),

          // 🌙 / 🌞 THEME TOGGLE
          IconButton(
            tooltip: "Toggle theme",
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
                    builder: (c) => const BiasInfoScreen(),
                  ),
                ),
              ),
              HamburgerMenuItem(
                label: "Yearly Chart",
                icon: Icons.bar_chart,
                onPress: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => const YearlyChartScreen(),
                  ),
                ),
              ),
              HamburgerMenuItem(
                label: "About",
                icon: Icons.info,
                onPress: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => const AboutScreen(),
                  ),
                ),
              ),
              HamburgerMenuItem(
                label: "Backup & Restore",
                icon: Icons.backup,
                onPress: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => const BackupRestoreScreen(),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ───────────────── INPUT BOX ─────────────────

  Widget _buildInputBox() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: const Color(0xFFbda4e5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _textController,
        maxLines: 4,
        onChanged: (_) => _updateSuggestions(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: "Describe what you observed today...",
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  // ───────────────── SUGGESTED BIASES ─────────────────

  Widget _buildSuggestedBiases() {
    if (_suggestedBiases.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Suggested Biases:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF5a189a),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedBiases.map((bias) {
              final selected = _selectedBiases.contains(bias);
              return ChoiceChip(
                label: Text(bias),
                selected: selected,
                onSelected: (_) => _toggleBias(bias),
                selectedColor: const Color(0xFFc77dff),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ───────────────── CATEGORIES ─────────────────

  Widget _buildBiasCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bias Categories",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3c096c),
          ),
        ),

        const SizedBox(height: 8),

        /// USING DATA FROM bias_data.dart
        ...biasCategories.asMap().entries.map(
              (entry) => _buildCategory(
                entry.key,
                entry.value,
              ),
            ),
      ],
    );
  }

  Widget _buildCategory(int index, Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              category['title'],
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5a189a),
              ),
            ),
            trailing: Icon(
              _openCategory == index ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFF7b2cbf),
            ),
            onTap: () => _toggleCategory(index),
          ),
          if (_openCategory == index)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: (category["biases"] as List<Map<String, dynamic>>)
                    .map((bias) {
                  final selected = _selectedBiases.contains(bias["name"]);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: GestureDetector(
                      onTap: () => _showBiasDialog(bias),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFe0c3fc)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF7b2cbf)
                                : const Color(0xFFd4c2e8),
                          ),
                        ),
                        child: Text(
                          bias["name"],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? const Color(0xFF5a189a)
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────── DIALOG BOX ─────────────────
  Future<void> _showBiasDialog(Map<String, dynamic> bias) async {
    final alreadySelected = _selectedBiases.contains(bias["name"]);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Row(
                    children: [
                      const Icon(
                        Icons.psychology,
                        color: Color(0xFF7b2cbf),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bias["name"],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5a189a),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// DESCRIPTION
                  Text(
                    bias["description"],
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// EXAMPLE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf3e8ff),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "💡 Example",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5a189a),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bias["example"],
                          style: const TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// RECOGNIZE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFfff4e6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "🧠 How to recognize",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9c6644),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bias["recognize"],
                          style: const TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7b2cbf),
                          ),
                          onPressed: () {
                            _toggleBias(bias["name"]);
                            Navigator.pop(context);
                          },
                          child: Text(
                            alreadySelected ? "Remove" : "Select",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ───────────────── SAVE BUTTON ─────────────────

  Widget _buildSaveButton() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
        width: double.infinity,
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _saveEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7b2cbf),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Save Entry",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
