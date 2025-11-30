// import 'package:flutter/material.dart';
// import '../models/journal_entry.dart';
// import '../database/database_helper.dart';
// import '../component//hamburger_menu.dart';
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

//     try {
//       await DatabaseHelper().insertEntry(entry);

//       _textController.clear();
//       setState(() {
//         _selectedBiases.clear();
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Entry saved successfully!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error saving entry: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFfaf7ff),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               // Header
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.auto_awesome,
//                     size: 28,
//                     color: Color(0xFF5a189a),
//                   ),
//                   const SizedBox(width: 10),
//                   const Text(
//                     'Add Observation',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF5a189a),
//                     ),
//                   ),
//                   const Spacer(),
//                   HamburgerMenu(
//                     options: [
//                       HamburgerMenuItem(
//                         label: "Yearly Chart",
//                         icon: Icons.bar_chart,
//                         onPress: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                     const YearlyChartScreen()),
//                           );
//                         },
//                       ),
//                       HamburgerMenuItem(
//                         label: "About",
//                         icon: Icons.info,
//                         onPress: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const AboutScreen()),
//                           );
//                         },
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//               const SizedBox(height: 25),

//               // Text Input Section
//               const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Your Observation',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF3c096c),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color(0xFFbda4e5)),
//                 ),
//                 child: TextField(
//                   controller: _textController,
//                   maxLines: 4,
//                   decoration: const InputDecoration(
//                     hintText: 'Describe what you observed today...',
//                     hintStyle: TextStyle(color: Color(0xFF999999)),
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.all(16),
//                   ),
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),
//               const SizedBox(height: 10),

//               // Bias Categories Section
//               const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Select Bias Categories',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF3c096c),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 4),

//               // Bias Categories List
//               Expanded(
//                 child: ListView(
//                   children: [
//                     for (int index = 0; index < _biasCategories.length; index++)
//                       _buildBiasCategory(index, _biasCategories[index]),
//                   ],
//                 ),
//               ),

//               // Save Button
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: _saveEntry,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF7b2cbf),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.save, color: Colors.white, size: 22),
//                       SizedBox(width: 8),
//                       Text(
//                         'Save Entry',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBiasCategory(int index, Map<String, dynamic> category) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFf3d9ff),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           // Category Header
//           ListTile(
//             title: Text(
//               category['title'],
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Color(0xFF5a189a),
//               ),
//             ),
//             trailing: Text(
//               _openCategory == index ? '−' : '+',
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF7b2cbf),
//               ),
//             ),
//             onTap: () => _toggleCategory(index),
//           ),

//           // Expanded Biases
//           if (_openCategory == index)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//               child: Column(
//                 children: (category['biases'] as List<String>).map((bias) {
//                   final isSelected = _selectedBiases.contains(bias);
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: () => _toggleBias(bias),
//                         borderRadius: BorderRadius.circular(8),
//                         child: Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 12,
//                             horizontal: 16,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? const Color(0xFFe0c3fc)
//                                 : Colors.white,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                               color: isSelected
//                                   ? const Color(0xFF7b2cbf)
//                                   : const Color(0xFFd4c2e8),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 isSelected
//                                     ? Icons.check_box
//                                     : Icons.check_box_outline_blank,
//                                 color: const Color(0xFF7b2cbf),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(
//                                   bias,
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                     color: isSelected
//                                         ? const Color(0xFF5a189a)
//                                         : const Color(0xFF444444),
//                                   ),
//                                 ),
//                               ),
//                             ],
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

//   @override
//   void dispose() {
//     _textController.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../database/database_helper.dart';
import '../component/hamburger_menu.dart';
import '../ai/bias_detector.dart';
import 'yearly_chart_screen.dart';
import 'about_screen.dart';

class InsertScreen extends StatefulWidget {
  const InsertScreen({Key? key}) : super(key: key);

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
          content: Text("Entry saved!"), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfaf7ff),

      // 🔥 Automatically adjusts when keyboard opens
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
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
                    const SizedBox(height: 100), // space before bottom button
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

  Widget _buildHeader() {
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
          HamburgerMenu(options: [
            HamburgerMenuItem(
              label: "Yearly Chart",
              icon: Icons.bar_chart,
              onPress: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const YearlyChartScreen()),
              ),
            ),
            HamburgerMenuItem(
              label: "About",
              icon: Icons.info,
              onPress: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const AboutScreen()),
              ),
            ),
          ])
        ],
      ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFbda4e5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _textController,
        maxLines: 4,
        onChanged: (_) => _updateSuggestions(),
        decoration: const InputDecoration(
          hintText: "Describe what you observed today...",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSuggestedBiases() {
    if (_suggestedBiases.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFe9d8ff),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Suggested Biases:",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF5a189a)),
          ),
          const SizedBox(height: 8),

          // Wrap suggestions with scroll if many
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

        // List of all categories
        ..._biasCategories.asMap().entries.map((entry) {
          return _buildCategory(entry.key, entry.value);
        }).toList(),
      ],
    );
  }

  Widget _buildCategory(int index, Map<String, dynamic> category) {
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
                          color:
                              selected ? const Color(0xFFe0c3fc) : Colors.white,
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
                                : const Color(0xFF333333),
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
                  borderRadius: BorderRadius.circular(14)),
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
