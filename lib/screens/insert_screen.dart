// import 'package:flutter/material.dart';
// import '../models/journal_entry.dart';
// import '../database/database_helper.dart';
// import '../component/hamburger_menu.dart';
// import '../ai/bias_detector.dart';
// import 'yearly_chart_screen.dart';
// import 'about_screen.dart';

// class InsertScreen extends StatefulWidget {
//   const InsertScreen({Key? key}) : super(key: key);

//   @override
//   State<InsertScreen> createState() => _InsertScreenState();
// }

// class _InsertScreenState extends State<InsertScreen> {
//   final TextEditingController _textController = TextEditingController();
//   final List<String> _selectedBiases = [];
//   List<String> _suggestedBiases = [];
//   int? _openCategory;

//   final List<Map<String, dynamic>> _biasCategories = [
//     {
//       "title": "Thinking & Decision Making",
//       "biases": [
//         "Confirmation Bias",
//         "Anchoring Bias",
//         "Availability Heuristic",
//         "Representativeness Heuristic",
//         "Framing Effect",
//         "Choice-Supportive Bias",
//         "Status Quo Bias"
//       ]
//     },
//     {
//       "title": "Memory & Perception",
//       "biases": [
//         "Hindsight Bias",
//         "False Memory",
//         "Rosy Retrospection",
//         "Mandela Effect"
//       ]
//     },
//     {
//       "title": "Social / Self",
//       "biases": [
//         "Self-serving Bias",
//         "Optimism Bias",
//         "Egocentric Bias",
//         "Fundamental Attribution Error",
//         "In-group Bias"
//       ]
//     },
//     {
//       "title": "Risk & Loss",
//       "biases": ["Loss Aversion", "RISK Compensation", "Sunk Cost Fallacy"]
//     },
//     {
//       "title": "Attention & Recency",
//       "biases": ["Recency Bias", "Primacy Effect", "Attentional Bias"]
//     },
//   ];

//   void _updateSuggestions() {
//     final text = _textController.text.trim();
//     if (text.isEmpty) {
//       setState(() => _suggestedBiases = []);
//       return;
//     }
//     setState(() {
//       _suggestedBiases = BiasDetector.detectBiases(text);
//     });
//   }

//   void _toggleBias(String bias) {
//     setState(() {
//       if (_selectedBiases.contains(bias)) {
//         _selectedBiases.remove(bias);
//       } else {
//         _selectedBiases.add(bias);
//       }
//     });
//   }

//   void _toggleCategory(int index) {
//     setState(() {
//       _openCategory = _openCategory == index ? null : index;
//     });
//   }

//   void _saveEntry() async {
//     if (_textController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please write something first!'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     final entry = JournalEntry(
//       id: DateTime.now().millisecondsSinceEpoch,
//       text: _textController.text.trim(),
//       biases: _selectedBiases,
//       createdAt: DateTime.now(),
//     );

//     await DatabaseHelper().insertEntry(entry);

//     _textController.clear();
//     setState(() {
//       _selectedBiases.clear();
//       _suggestedBiases.clear();
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//           content: Text("Entry saved!"), backgroundColor: Colors.green),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFfaf7ff),

//       // 🔥 Automatically adjusts when keyboard opens
//       resizeToAvoidBottomInset: true,

//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildInputBox(),
//                     const SizedBox(height: 12),
//                     _buildSuggestedBiases(),
//                     const SizedBox(height: 20),
//                     _buildBiasCategories(),
//                     const SizedBox(height: 100), // space before bottom button
//                   ],
//                 ),
//               ),
//             ),
//             _buildSaveButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         children: [
//           const Icon(Icons.auto_awesome, size: 28, color: Color(0xFF5a189a)),
//           const SizedBox(width: 10),
//           const Text(
//             'Add Observation',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF5a189a),
//             ),
//           ),
//           const Spacer(),
//           HamburgerMenu(options: [
//             HamburgerMenuItem(
//               label: "Yearly Chart",
//               icon: Icons.bar_chart,
//               onPress: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (c) => const YearlyChartScreen()),
//               ),
//             ),
//             HamburgerMenuItem(
//               label: "About",
//               icon: Icons.info,
//               onPress: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (c) => const AboutScreen()),
//               ),
//             ),
//           ])
//         ],
//       ),
//     );
//   }

//   Widget _buildInputBox() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: const Color(0xFFbda4e5)),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: TextField(
//         controller: _textController,
//         maxLines: 4,
//         onChanged: (_) => _updateSuggestions(),
//         decoration: const InputDecoration(
//           hintText: "Describe what you observed today...",
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.all(16),
//         ),
//       ),
//     );
//   }

//   Widget _buildSuggestedBiases() {
//     if (_suggestedBiases.isEmpty) return const SizedBox.shrink();

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFe9d8ff),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Suggested Biases:",
//             style: TextStyle(
//                 fontWeight: FontWeight.bold, color: Color(0xFF5a189a)),
//           ),
//           const SizedBox(height: 8),

//           // Wrap suggestions with scroll if many
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: _suggestedBiases.map((bias) {
//               final selected = _selectedBiases.contains(bias);
//               return ChoiceChip(
//                 label: Text(bias),
//                 selected: selected,
//                 onSelected: (_) => _toggleBias(bias),
//                 selectedColor: const Color(0xFFc77dff),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBiasCategories() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Bias Categories",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF3c096c),
//           ),
//         ),
//         const SizedBox(height: 8),

//         // List of all categories
//         ..._biasCategories.asMap().entries.map((entry) {
//           return _buildCategory(entry.key, entry.value);
//         }).toList(),
//       ],
//     );
//   }

//   Widget _buildCategory(int index, Map<String, dynamic> category) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFf3d9ff),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           ListTile(
//             title: Text(
//               category['title'],
//               style: const TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF5a189a),
//               ),
//             ),
//             trailing: Icon(
//               _openCategory == index ? Icons.expand_less : Icons.expand_more,
//               color: const Color(0xFF7b2cbf),
//             ),
//             onTap: () => _toggleCategory(index),
//           ),
//           if (_openCategory == index)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: Column(
//                 children: (category["biases"] as List<String>).map((bias) {
//                   final selected = _selectedBiases.contains(bias);
//                   return Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                     child: GestureDetector(
//                       onTap: () => _toggleBias(bias),
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color:
//                               selected ? const Color(0xFFe0c3fc) : Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(
//                             color: selected
//                                 ? const Color(0xFF7b2cbf)
//                                 : const Color(0xFFd4c2e8),
//                           ),
//                         ),
//                         child: Text(
//                           bias,
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: selected
//                                 ? const Color(0xFF5a189a)
//                                 : const Color(0xFF333333),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSaveButton() {
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
//         width: double.infinity,
//         child: SizedBox(
//           height: 55,
//           child: ElevatedButton(
//             onPressed: _saveEntry,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF7b2cbf),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14)),
//             ),
//             child: const Text(
//               "Save Entry",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../database/database_helper.dart';
import '../component/hamburger_menu.dart';
import '../ai/bias_detector.dart';
import 'yearly_chart_screen.dart';
import 'about_screen.dart';
import '../theme/theme_controller.dart';

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
      "biases": ["Loss Aversion", "RISK Compensation", "Sunk Cost Fallacy"]
    },
    {
      "title": "Attention & Recency",
      "biases": ["Recency Bias", "Primacy Effect", "Attentional Bias"]
    },
  ];

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

  void _saveEntry() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something first!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch,
      text: _textController.text.trim(),
      biases: _selectedBiases,
      createdAt: DateTime.now(),
    );

    await DatabaseHelper().insertEntry(entry);

    _textController.clear();
    setState(() {
      _selectedBiases.clear();
      _suggestedBiases.clear();
    });

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
                    const SizedBox(height: 100),
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
        ..._biasCategories.asMap().entries.map(
              (entry) => _buildCategory(entry.key, entry.value),
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
                children: (category["biases"] as List<String>).map((bias) {
                  final selected = _selectedBiases.contains(bias);
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: GestureDetector(
                      onTap: () => _toggleBias(bias),
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
                          bias,
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
