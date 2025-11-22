import 'package:flutter/material.dart';

class HamburgerMenu extends StatelessWidget {
  final List<HamburgerMenuItem> options;

  const HamburgerMenu({Key? key, required this.options}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<HamburgerMenuItem>(
      icon: const Icon(
        Icons.menu,
        color: Color(0xFF5a189a),
      ),
      itemBuilder: (BuildContext context) {
        return options.map((HamburgerMenuItem item) {
          return PopupMenuItem<HamburgerMenuItem>(
            value: item,
            child: Row(
              children: [
                Icon(item.icon, color: const Color(0xFF5a189a), size: 20),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: const TextStyle(
                    color: Color(0xFF5a189a),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (HamburgerMenuItem item) {
        item.onPress();
      },
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class HamburgerMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onPress;

  HamburgerMenuItem({
    required this.label,
    required this.icon,
    required this.onPress,
  });
}
