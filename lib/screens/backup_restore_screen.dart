import 'package:flutter/material.dart';
import '../utils/backup_service.dart';

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5a189a),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Backup & Restore"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            const Text(
              "Keep Your Journal Safe",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5a189a),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Create a backup to keep your data safe, or restore from a saved file anytime.",
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 28),

            /// 📤 SHARE BACKUP
            _buildCard(
              context: context,
              icon: Icons.share_rounded,
              title: "Share Backup",
              subtitle:
                  "Send backup to Google Drive, WhatsApp, Email, or save locally.",
              color: const Color(0xFF7b2cbf),
              onTap: () async {
                _showLoadingDialog(context, "Preparing backup...");
                await BackupService.exportAsJson(context);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 18),

            /// 📥 RESTORE BACKUP
            _buildCard(
              context: context,
              icon: Icons.restore_rounded,
              title: "Restore Backup",
              subtitle:
                  "Import your journal data from a previously saved backup file.",
              color: const Color(0xFFc77dff),
              onTap: () async {
                final confirm = await _showConfirmDialog(
                  context,
                  "Restore Backup",
                  "This will merge entries from your backup file into the app. Continue?",
                );
                if (confirm != true) return;
                _showLoadingDialog(context, "Restoring data...");
                await BackupService.restoreFromJson(context);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 30),

            /// 💡 INFO BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFe0c3fc)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF7b2cbf)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "• Backups are safe JSON files.\n• You can share them anywhere or keep them locally.\n• Restoring merges new entries without deleting existing ones.",
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ───────────────── CARD ─────────────────
  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            /// ICON
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 18),

            /// TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: color.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  /// ───────────────── LOADING DIALOG ─────────────────
  void _showLoadingDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Row(
            children: [
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xFF7b2cbf),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ───────────────── CONFIRMATION DIALOG ─────────────────
  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7b2cbf),
                foregroundColor: Colors.white,
              ),
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import '../utils/backup_service.dart';

// class BackupRestoreScreen extends StatelessWidget {
//   const BackupRestoreScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF5a189a),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: const Text("Backup & Restore"),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// HEADER
//             const Text(
//               "Keep Your Journal Safe",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF5a189a),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Backup your observations and restore them anytime — on the same device or a new one.",
//               style: TextStyle(
//                 fontSize: 15,
//                 height: 1.5,
//                 color: Theme.of(context)
//                     .colorScheme
//                     .onSurface
//                     .withValues(alpha: 0.7),
//               ),
//             ),
//             const SizedBox(height: 28),

//             /// 📤 EXPORT AS JSON
//             _buildCard(
//               context: context,
//               icon: Icons.file_download_rounded,
//               title: "Export as JSON",
//               subtitle:
//                   "Human-readable backup. Good for sharing or partial restores.",
//               color: const Color(0xFF7b2cbf),
//               onTap: () async {
//                 _showLoadingDialog(context, "Creating JSON backup...");
//                 await BackupService.exportAsJson(context);
//                 if (context.mounted) Navigator.pop(context);
//               },
//             ),
//             const SizedBox(height: 18),

//             /// 💾 SAVE TO DEVICE
//             _buildCard(
//               context: context,
//               icon: Icons.save_alt_rounded,
//               title: "Save Backup to Device",
//               subtitle:
//                   "Create file → Choose folder (Downloads, Documents, etc.)",
//               color: const Color(0xFF7b2cbf),
//               onTap: () async {
//                 _showLoadingDialog(context, "Preparing backup file...");
//                 await BackupService.saveBackupToDevice(context);
//                 if (context.mounted) Navigator.pop(context);
//               },
//             ),

//             /// 📤 EXPORT AS DATABASE FILE (.db)
//             _buildCard(
//               context: context,
//               icon: Icons.file_download_rounded,
//               title: "Export Full Backup (.db)",
//               subtitle:
//                   "Complete database file. Best for uninstall recovery or device migration.",
//               color: const Color(0xFF9d4edd),
//               onTap: () async {
//                 final confirm = await _showConfirmDialog(
//                   context,
//                   "Export Database File",
//                   "This will create a full copy of your journal database. Keep this file safe — it contains all your data.",
//                 );
//                 if (confirm != true) return;
//                 _showLoadingDialog(context, "Creating database backup...");
//                 await BackupService.exportAsDatabaseFile(context);
//                 if (context.mounted) Navigator.pop(context);
//               },
//             ),
//             const SizedBox(height: 18),

//             /// 🔄 SHARE VIA WHATSAPP/GDRIVE
//             _buildCard(
//               context: context,
//               icon: Icons.share_rounded,
//               title: "Share via WhatsApp / GDrive",
//               subtitle: "Send a JSON backup directly to any app.",
//               color: const Color(0xFFc77dff),
//               onTap: () async {
//                 _showLoadingDialog(context, "Preparing backup...");
//                 await BackupService.shareJsonBackup(context);
//                 if (context.mounted) Navigator.pop(context);
//               },
//             ),
//             const SizedBox(height: 28),

//             /// 📥 RESTORE SECTION HEADER
//             const Text(
//               "Restore Data",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF5a189a),
//               ),
//             ),
//             const SizedBox(height: 12),

//             /// 📥 RESTORE FROM JSON
//             _buildCard(
//               context: context,
//               icon: Icons.file_upload_rounded,
//               title: "Restore from JSON",
//               subtitle:
//                   "Merge entries from a JSON backup file. Skips duplicates.",
//               color: const Color(0xFF7b2cbf),
//               onTap: () async {
//                 final confirm = await _showConfirmDialog(
//                   context,
//                   "Restore from JSON",
//                   "This will add entries from the backup file. Existing entries with the same ID will be skipped.",
//                 );
//                 if (confirm != true) return;
//                 _showLoadingDialog(context, "Restoring backup...");
//                 await BackupService.restoreFromJson(context);
//                 if (context.mounted) Navigator.pop(context);
//               },
//             ),
//             const SizedBox(height: 18),

//             /// 📥 RESTORE FROM DATABASE FILE (.db)
//             _buildCard(
//               context: context,
//               icon: Icons.restore_rounded,
//               title: "Restore Full Backup (.db)",
//               subtitle:
//                   "Replace all data with a complete database backup. ⚠️ This cannot be undone.",
//               color: const Color(0xFFe040fb),
//               onTap: () async {
//                 final confirm = await _showConfirmDialog(
//                   context,
//                   "⚠️ Full Restore Warning",
//                   "This will REPLACE all your current journal data with the backup file. This action cannot be undone. Continue?",
//                   isDestructive: true,
//                 );
//                 if (confirm != true) return;
//                 _showLoadingDialog(context, "Restoring database...");
//                 await BackupService.restoreFromDatabaseFile(context);
//                 if (context.mounted) Navigator.pop(context);
//               },
//             ),
//             const SizedBox(height: 30),

//             /// 💡 INFO BOX
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surface,
//                 borderRadius: BorderRadius.circular(18),
//                 border: Border.all(color: const Color(0xFFe0c3fc)),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Icon(Icons.info_outline, color: Color(0xFF7b2cbf)),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       "• Use JSON backups for sharing or partial restores.\n• Use .db backups for full app migration or uninstall recovery.\n• Always keep at least one backup in a safe location.",
//                       style: TextStyle(
//                         fontSize: 14,
//                         height: 1.5,
//                         color: Theme.of(context)
//                             .colorScheme
//                             .onSurface
//                             .withValues(alpha: 0.75),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// ───────────────── CARD ─────────────────
//   Widget _buildCard({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(22),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 220),
//         width: double.infinity,
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.surface,
//           borderRadius: BorderRadius.circular(22),
//           border: Border.all(color: color.withValues(alpha: 0.18)),
//           boxShadow: [
//             BoxShadow(
//               color: color.withValues(alpha: 0.08),
//               blurRadius: 18,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             /// ICON
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: color.withValues(alpha: 0.12),
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: Icon(icon, color: color, size: 30),
//             ),
//             const SizedBox(width: 18),

//             /// TEXT
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: color,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 14,
//                       height: 1.5,
//                       color: Theme.of(context)
//                           .colorScheme
//                           .onSurface
//                           .withValues(alpha: 0.7),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 10),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 18,
//               color: color.withValues(alpha: 0.7),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// ───────────────── LOADING DIALOG ─────────────────
//   void _showLoadingDialog(BuildContext context, String text) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           content: Row(
//             children: [
//               const SizedBox(
//                 width: 26,
//                 height: 26,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 3,
//                   color: Color(0xFF7b2cbf),
//                 ),
//               ),
//               const SizedBox(width: 18),
//               Expanded(
//                 child: Text(
//                   text,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   /// ───────────────── CONFIRMATION DIALOG ─────────────────
//   Future<bool?> _showConfirmDialog(
//     BuildContext context,
//     String title,
//     String message, {
//     bool isDestructive = false,
//   }) {
//     return showDialog<bool>(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           title: Text(title),
//           content: Text(
//             message,
//             style: TextStyle(
//               color: isDestructive ? Colors.red[700] : null,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context, true),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     isDestructive ? Colors.red : const Color(0xFF7b2cbf),
//                 foregroundColor: Colors.white,
//               ),
//               child: Text(isDestructive ? "Yes, Restore" : "Continue"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
