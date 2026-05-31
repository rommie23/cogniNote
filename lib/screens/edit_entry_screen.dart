// lib/screens/edit_entry_screen.dart

import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../database/database_helper.dart';
import '../data/bias_data.dart';

class EditEntryScreen extends StatefulWidget {
  final JournalEntry entry;

  const EditEntryScreen({
    super.key,
    required this.entry,
  });

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  late TextEditingController _textController;

  late Set<String> _selectedBiases;

  int? _openCategory;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.entry.text);

    _selectedBiases = Set<String>.from(widget.entry.biases);
  }

  /// ───────────────── TOGGLE CATEGORY ─────────────────

  void _toggleCategory(int index) {
    setState(() {
      _openCategory = _openCategory == index ? null : index;
    });
  }

  /// ───────────────── TOGGLE BIAS ─────────────────

  void _toggleBias(String biasName) {
    setState(() {
      if (_selectedBiases.contains(biasName)) {
        _selectedBiases.remove(biasName);
      } else {
        _selectedBiases.add(biasName);
      }
    });
  }

  /// ───────────────── DIALOG ─────────────────

  Future<void> _showBiasDialog(
    Map<String, dynamic> bias,
  ) async {
    final alreadySelected = _selectedBiases.contains(bias["name"]);

    await showDialog(
      context: context,
      builder: (_) {
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
                        color: Color(0xFF7B2CBF),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          bias["name"],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A189A),
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
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "💡 Example",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A189A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bias["example"],
                          style: const TextStyle(
                            height: 1.5,
                          ),
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
                      color: const Color(0xFFFFF4E6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "🧠 How to recognize",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9C6644),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bias["recognize"],
                          style: const TextStyle(
                            height: 1.5,
                          ),
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
                            backgroundColor: const Color(0xFF7B2CBF),
                          ),
                          onPressed: () {
                            _toggleBias(
                              bias["name"],
                            );

                            Navigator.pop(context);
                          },
                          child: Text(
                            alreadySelected ? "Remove" : "Select",
                            style: const TextStyle(
                              color: Colors.white,
                            ),
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

  /// ───────────────── SAVE ─────────────────

  Future<void> _saveChanges() async {
    final text = _textController.text.trim();

    /// REMOVE INVALID / EMPTY BIASES
    _selectedBiases.removeWhere(
      (bias) => bias.trim().isEmpty,
    );

    /// VALIDATE TEXT
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please update your observation first.",
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
            "Please select at least one bias.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    /// SAVE
    final updatedEntry = JournalEntry(
      id: widget.entry.id,
      text: text,
      biases: _selectedBiases.toList(),
      createdAt: widget.entry.createdAt,
    );
    await DatabaseHelper().updateEntry(updatedEntry);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  /// ───────────────── CATEGORY ─────────────────

  Widget _buildBiasCategory(
    int index,
    Map<String, dynamic> category,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// HEADER
          ListTile(
            title: Text(
              category["title"],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF5A189A),
              ),
            ),
            trailing: Icon(
              _openCategory == index ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFF7B2CBF),
            ),
            onTap: () => _toggleCategory(index),
          ),

          /// EXPANDED
          if (_openCategory == index)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                12,
              ),
              child: Column(
                children: (category["biases"] as List<Map<String, dynamic>>)
                    .map((bias) {
                  final isSelected = _selectedBiases.contains(
                    bias["name"],
                  );

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _showBiasDialog(bias),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE0C3FC)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF7B2CBF)
                                : const Color(0xFFD4C2E8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: const Color(0xFF7B2CBF),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                bias["name"],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF5A189A)
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
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

  /// ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A189A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Edit Entry",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              const Text(
                "Update Observation",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C096C),
                ),
              ),

              const SizedBox(height: 8),

              /// INPUT
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFBDA4E5),
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: "Update your thought...",
                    hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// BIAS TITLE
              const Text(
                "Edit Bias Categories",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C096C),
                ),
              ),

              const SizedBox(height: 8),

              /// LIST
              Expanded(
                child: ListView(
                  children: [
                    for (int i = 0; i < biasCategories.length; i++)
                      _buildBiasCategory(
                        i,
                        biasCategories[i],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// SAVE
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2CBF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
