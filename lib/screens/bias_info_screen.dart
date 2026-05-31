import 'package:flutter/material.dart';
import '../data/bias_data.dart';

class BiasInfoScreen extends StatefulWidget {
  const BiasInfoScreen({super.key});

  @override
  State<BiasInfoScreen> createState() => _BiasInfoScreenState();
}

class _BiasInfoScreenState extends State<BiasInfoScreen> {
  int? expandedIndex;

  // 🎨 Theme-aware color helpers (keeps purple aesthetic as default)
  Color get _primaryPurple => const Color(0xFF7B2CBF);
  Color get _darkPurple => const Color(0xFF3C096C);
  Color get _lightPurple => const Color(0xFFF3E8FF);
  Color get _background => const Color(0xFFF6F2FF);
  Color get _cardBackground => const Color(0xFFFDFBFF);
  Color get _borderColor => const Color(0xFFE8D8FF);

  @override
  Widget build(BuildContext context) {
    // ✅ Use theme colors with purple fallbacks
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // ✅ Theme-aware background
      backgroundColor: theme.scaffoldBackgroundColor == Colors.white
          ? _background
          : theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        // ✅ Theme-aware app bar
        backgroundColor: theme.scaffoldBackgroundColor == Colors.white
            ? _background
            : theme.appBarTheme.backgroundColor ?? _background,
        foregroundColor: theme.appBarTheme.foregroundColor ?? _darkPurple,
        title: const Text(
          "Cognitive Bias Guide",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        itemCount: biasCategories.length,
        itemBuilder: (context, index) {
          final category = biasCategories[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  // ✅ Theme-aware shadow
                  color: (theme.brightness == Brightness.dark)
                      ? _primaryPurple.withValues(alpha: 0.2)
                      : _primaryPurple.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Theme(
                data: theme.copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  initiallyExpanded: expandedIndex == index,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      expandedIndex = expanded ? index : null;
                    });
                  },
                  // ✅ Theme-aware tile backgrounds
                  backgroundColor: theme.scaffoldBackgroundColor == Colors.white
                      ? _cardBackground
                      : colorScheme.surfaceVariant,
                  collapsedBackgroundColor:
                      theme.scaffoldBackgroundColor == Colors.white
                          ? Colors.white
                          : colorScheme.surface,
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),

                  leading: Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor == Colors.white
                          ? _lightPurple
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getCategoryIcon(category["title"]),
                      // ✅ Perfect contrast in both themes
                      color: Colors.white,
                    ),
                  ),

                  /// MAIN TITLE
                  title: Text(
                    category["title"],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      // ✅ Theme-aware title color
                      color: theme.textTheme.titleMedium?.color ?? _darkPurple,
                    ),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "${category["biases"].length} biases",
                      style: TextStyle(
                        fontSize: 12,
                        // ✅ Theme-aware subtitle color
                        color: theme.textTheme.bodySmall?.color ??
                            Colors.grey.shade600,
                      ),
                    ),
                  ),

                  iconColor: theme.iconTheme.color ?? _primaryPurple,
                  collapsedIconColor: theme.iconTheme.color ?? _primaryPurple,

                  children: (category["biases"] as List).map((bias) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        // ✅ Theme-aware card background
                        color: theme.scaffoldBackgroundColor == Colors.white
                            ? Colors.white
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          // ✅ Theme-aware border
                          color: theme.scaffoldBackgroundColor == Colors.white
                              ? _borderColor
                              : colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (theme.brightness == Brightness.dark)
                                ? Colors.black.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// BIAS NAME
                          Text(
                            bias["name"],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color ??
                                  _darkPurple,
                            ),
                          ),
                          const SizedBox(height: 12),

                          /// DESCRIPTION
                          Text(
                            bias["description"],
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              // ✅ Theme-aware description color
                              color: theme.textTheme.bodyMedium?.color ??
                                  Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 14),

                          /// EXAMPLE BOX
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              // ✅ Theme-aware example box
                              color:
                                  theme.scaffoldBackgroundColor == Colors.white
                                      ? _lightPurple
                                      : colorScheme.primaryContainer
                                          .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "💡 Example",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.titleSmall?.color ??
                                        _darkPurple,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  bias["example"],
                                  style: TextStyle(
                                    height: 1.5,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          /// RECOGNIZE BOX
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              // ✅ Theme-aware recognize box (warm tone)
                              color:
                                  theme.scaffoldBackgroundColor == Colors.white
                                      ? const Color(0xFFFFF4E6)
                                      : colorScheme.tertiaryContainer
                                          .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "🧠 How to recognize",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.scaffoldBackgroundColor ==
                                            Colors.white
                                        ? const Color(0xFF9C6644)
                                        : colorScheme.onTertiaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  bias["recognize"],
                                  style: TextStyle(
                                    height: 1.5,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String title) {
    switch (title) {
      case "Thinking & Decision Making":
        return Icons.psychology_rounded;
      case "Memory & Perception":
        return Icons.visibility_rounded;
      case "Social / Self":
        return Icons.people_alt_rounded;
      case "Risk & Loss":
        return Icons.trending_down_rounded;
      case "Attention & Recency":
        return Icons.center_focus_strong_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
