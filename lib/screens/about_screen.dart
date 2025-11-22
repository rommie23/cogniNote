import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? _openSectionId;

  final List<Map<String, String>> _sections = [
    {
      "id": "privacy",
      "title": "Privacy Policy",
      "content":
          "We respect your privacy. Your journal entries are stored locally on your device using SQLite database and are not sent to any external servers. We do not sell or share your personal data with third parties.",
    },
    {
      "id": "terms",
      "title": "Terms of Service",
      "content":
          "Cognitive Journal is provided as-is. By using the app you agree to use it responsibly. The developer is not liable for any consequences resulting from use of the app. You may export your data anytime and we recommend you create backups for important information.",
    },
    {
      "id": "data",
      "title": "Data Usage & Backups",
      "content":
          "The app stores text-based entries locally in SQLite database. Your data is stored securely on your device. You can manage your entries within the app and we recommend regular backups of important information.",
    },
    {
      "id": "cookies",
      "title": "Cookies & Local Storage",
      "content":
          "This mobile app does not use cookies. Local storage (SQLite) is used to keep your entries, settings and small metadata. Clearing app data or uninstalling the app will remove local storage and entries.",
    },
    {
      "id": "contact",
      "title": "Contact & Support",
      "content":
          "If you need help, report a bug, or want to request a feature, contact us at support@example.com. We aim to respond within a few business days.",
    },
  ];

  void _toggleSection(String id) {
    setState(() {
      if (_openSectionId == id) {
        _openSectionId = null;
      } else {
        _openSectionId = id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfaf7ff),
      appBar: AppBar(
        title: const Text('About Section'),
        backgroundColor: const Color(0xFF5a189a),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'About & Legal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5a189a),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Learn how your data is handled and how to get support.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6a4dbd),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Expandable Sections
              Expanded(
                child: ListView(
                  children: [
                    ..._sections
                        .map((section) => _buildAnimatedSectionCard(section)),

                    // Warning Message
                    _buildWarningMessage(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSectionCard(Map<String, String> section) {
    final isOpen = _openSectionId == section['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFf0e7fb)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          Material(
            color: const Color(0xFFf3d9ff),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: isOpen ? Radius.circular(0) : Radius.circular(12),
              bottomRight: isOpen ? Radius.circular(0) : Radius.circular(12),
            ),
            child: InkWell(
              onTap: () => _toggleSection(section['id']!),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: isOpen ? Radius.circular(0) : Radius.circular(12),
                bottomRight: isOpen ? Radius.circular(0) : Radius.circular(12),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        section['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5a189a),
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: isOpen ? 0.5 : 0,
                      child: const Icon(
                        Icons.expand_more,
                        size: 24,
                        color: Color(0xFF5a189a),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Animated Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isOpen ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isOpen ? 1 : 0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  section['content']!,
                  style: const TextStyle(
                    color: Color(0xFF3c096c),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 8, right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFfff5f5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFfeb2b2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber,
            size: 18,
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Warning: You will lose the data if you uninstall the app. Kindly read policy.',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
