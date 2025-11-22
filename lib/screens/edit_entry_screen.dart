import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../database/database_helper.dart';

class EditEntryScreen extends StatefulWidget {
  final JournalEntry entry;

  const EditEntryScreen({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  late TextEditingController _textController;
  late List<String> _selectedBiases;

  int? _openCategory;

  // Reusing YOUR bias categories from InsertScreen
  final List<Map<String, dynamic>> _biasCategories = [
    {
      "title": "Thinking & Decision Making",
      "biases": [
        "Confirmation Bias",
        "Anchoring Bias",
        "Availability Heuristic",
        "Representativeness Heuristic",
        "Framing Effect",
        "Choice-Supportive Bias",
        "Status Quo Bias"
      ]
    },
    {
      "title": "Memory & Perception",
      "biases": [
        "Hindsight Bias",
        "False Memory",
        "Rosy Retrospection",
        "Mandela Effect"
      ]
    },
    {
      "title": "Social / Self",
      "biases": [
        "Self-serving Bias",
        "Optimism Bias",
        "Egocentric Bias",
        "Fundamental Attribution Error",
        "In-group Bias"
      ]
    },
    {
      "title": "Risk & Loss",
      "biases": ["Loss Aversion", "Risk Compensation", "Sunk Cost Fallacy"]
    },
    {
      "title": "Attention & Recency",
      "biases": ["Recency Bias", "Primacy Effect", "Attentional Bias"]
    },
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.entry.text);
    _selectedBiases = List.from(widget.entry.biases);
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

  Future<void> _saveChanges() async {
    final updatedEntry = JournalEntry(
      id: widget.entry.id,
      text: _textController.text.trim(),
      biases: _selectedBiases,
      createdAt: widget.entry.createdAt,
    );

    await DatabaseHelper().updateEntry(updatedEntry);

    Navigator.pop(context, true); // return to previous page and refresh
  }

  Widget _buildBiasCategory(int index, Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFf3d9ff),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              category['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF5a189a),
              ),
            ),
            trailing: Text(
              _openCategory == index ? '−' : '+',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7b2cbf),
              ),
            ),
            onTap: () => _toggleCategory(index),
          ),
          if (_openCategory == index)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: (category["biases"] as List<String>).map((bias) {
                  final isSelected = _selectedBiases.contains(bias);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => _toggleBias(bias),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFe0c3fc)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF7b2cbf)
                                : const Color(0xFFd4c2e8),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: const Color(0xFF7b2cbf),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                bias,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF5a189a)
                                      : const Color(0xFF444444),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfaf7ff),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5a189a),
        foregroundColor: Colors.white,
        title: const Text("Edit Entry"),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TEXT FIELD
              const Text(
                "Update Observation",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3c096c),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFbda4e5)),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Update your thought...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Edit Bias Categories",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3c096c),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: ListView(
                  children: [
                    for (int i = 0; i < _biasCategories.length; i++)
                      _buildBiasCategory(i, _biasCategories[i]),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7b2cbf),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
