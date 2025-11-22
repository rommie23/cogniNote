// lib/component/consent_dialog.dart
import 'package:flutter/material.dart';

class ConsentDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConsentDialog({Key? key, required this.onConfirm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFfaf7ff),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF7b2cbf), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF7b2cbf),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Important Notice',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5a189a),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your entries are stored only on your device using secure local storage.\n\n'
                '• This design is intentional for your privacy — your journal data never leaves your phone and is never uploaded to any server.\n'
                '• This also means that if your device is lost, reset, damaged or the app is uninstalled,your data cannot be recovered by us because we never have access to it.\n'
                '• By continuing, you acknowledge that your privacy and data security are fully in your control, and you agree to our Terms & Privacy Policy.'
                '• If you want more details, please visit the About page before using the app.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3c096c),
                  height: 1.4,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7b2cbf),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'I Understand & Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
