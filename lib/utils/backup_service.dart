// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:sqflite/sqflite.dart';

// import '../database/database_helper.dart';
// import '../models/journal_entry.dart';

// class BackupService {
//   // ─────────────────────────────────────────────────────────────
//   // 📤 EXPORT AS JSON (Human-readable, shareable)
//   // ─────────────────────────────────────────────────────────────
//   static Future<void> exportAsJson(BuildContext context) async {
//     try {
//       final entries = await DatabaseHelper().getAllEntries();

//       final data = entries
//           .map((e) => {
//                 "id": e.id,
//                 "text": e.text,
//                 "biases": e.biases,
//                 "createdAt": e.createdAt.toIso8601String(),
//               })
//           .toList();

//       final jsonString = const JsonEncoder.withIndent('  ').convert(data);
//       final timestamp = DateTime.now().millisecondsSinceEpoch;

//       // ✅ Storage Access Framework (SAF) - works on Android 10+ without permissions
//       final savedPath = await FilePicker.platform.saveFile(
//         dialogTitle: 'Save Journal Backup',
//         fileName: 'cognitive_journal_backup_$timestamp.json',
//         type: FileType.custom,
//         allowedExtensions: ['json'],
//       );

//       if (savedPath == null) return; // User cancelled

//       await File(savedPath).writeAsString(jsonString);

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('✅ JSON backup saved! You can share this file.'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ Export failed: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // 📥 RESTORE FROM JSON
//   // ─────────────────────────────────────────────────────────────
//   static Future<void> restoreFromJson(BuildContext context) async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['json'],
//         withData: true, // ✅ Critical for Android SAF compatibility
//       );

//       if (result == null) return;

//       final pickedFile = result.files.single;
//       final String jsonString;

//       // ✅ Handle SAF: read from bytes if path is null (common on Android)
//       if (pickedFile.bytes != null) {
//         jsonString = utf8.decode(pickedFile.bytes!);
//       } else if (pickedFile.path != null) {
//         jsonString = await File(pickedFile.path!).readAsString();
//       } else {
//         throw Exception('Could not read file content');
//       }

//       final List<dynamic> decoded = jsonDecode(jsonString);
//       final existingIds =
//           (await DatabaseHelper().getAllEntries()).map((e) => e.id).toSet();

//       int restoredCount = 0;

//       for (final item in decoded) {
//         // Skip duplicates to avoid conflicts
//         if (existingIds.contains(item["id"])) continue;

//         final biases = (item["biases"] as List)
//             .map((e) => e.toString())
//             .where((e) => e.trim().isNotEmpty)
//             .toList();

//         final entry = JournalEntry(
//           id: item["id"],
//           text: item["text"],
//           biases: biases,
//           createdAt: DateTime.parse(item["createdAt"]),
//         );

//         await DatabaseHelper().insertEntry(entry);
//         restoredCount++;
//       }

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('✅ $restoredCount entries restored!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ Restore failed: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // 📤 EXPORT RAW DATABASE FILE (.db) - Full fidelity backup
//   // ─────────────────────────────────────────────────────────────
//   static Future<void> exportAsDatabaseFile(BuildContext context) async {
//     try {
//       final dbHelper = DatabaseHelper();
//       const dbName =
//           'cognitive_journal.db'; // Must match your openDatabase name

//       // ⚠️ CRITICAL: Close DB to flush WAL/journal and prevent corruption
//       await dbHelper.resetDatabase();

//       final dbPath = p.join(await getDatabasesPath(), dbName);
//       if (!await File(dbPath).exists()) {
//         throw Exception('Database file not found at $dbPath');
//       }

//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final savedPath = await FilePicker.platform.saveFile(
//         dialogTitle: 'Save Database Backup',
//         fileName: 'cognitive_journal_backup_$timestamp.db',
//         type: FileType.custom,
//         allowedExtensions: ['db'],
//       );

//       if (savedPath == null) {
//         // Reopen DB if user cancelled
//         await dbHelper.database; // Triggers reinit via getter
//         return;
//       }

//       // Copy the raw database file to user's chosen location
//       await File(dbPath).copy(savedPath);

//       // Reopen database for continued app use
//       await dbHelper.database;

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('✅ Database backup saved! Keep this file safe.'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       // Ensure DB is reopened even on failure
//       await DatabaseHelper().database;
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ Backup failed: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // 📥 RESTORE FROM RAW DATABASE FILE (.db)
//   // ─────────────────────────────────────────────────────────────
//   static Future<void> restoreFromDatabaseFile(BuildContext context) async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['db'],
//         withData: true, // ✅ Critical for Android SAF
//       );

//       if (result == null) return;

//       final pickedFile = result.files.single;
//       final Uint8List? fileBytes = pickedFile.bytes;
//       final String? sourcePath = pickedFile.path;

//       if (fileBytes == null && sourcePath == null) {
//         throw Exception('Could not read selected database file');
//       }

//       const dbName = 'cognitive_journal.db';
//       final targetPath = p.join(await getDatabasesPath(), dbName);

//       final dbHelper = DatabaseHelper();

//       // ⚠️ Close current DB before overwriting the file
//       await dbHelper.resetDatabase();

//       // Write the backup to the app's database location
//       if (fileBytes != null) {
//         await File(targetPath).writeAsBytes(fileBytes);
//       } else {
//         await File(sourcePath!).copy(targetPath);
//       }

//       // Reinitialize database - this loads the restored schema + data
//       await dbHelper.database;

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('✅ Database restored! Your data is ready.'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//           ),
//         );
//       }
//     } catch (e) {
//       // Reopen DB on failure to keep app functional
//       await DatabaseHelper().database;
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ Restore failed: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // 🔄 SHARE JSON BACKUP (Direct share to WhatsApp/GDrive/etc)
//   // ─────────────────────────────────────────────────────────────
//   static Future<void> shareJsonBackup(BuildContext context) async {
//     try {
//       final entries = await DatabaseHelper().getAllEntries();
//       final data = entries
//           .map((e) => {
//                 "id": e.id,
//                 "text": e.text,
//                 "biases": e.biases,
//                 "createdAt": e.createdAt.toIso8601String(),
//               })
//           .toList();

//       final jsonString = const JsonEncoder.withIndent('  ').convert(data);
//       final tempDir = await getTemporaryDirectory();
//       final file = File('${tempDir.path}/cognitive_journal_share.json');
//       await file.writeAsString(jsonString);

//       await Share.shareXFiles(
//         [XFile(file.path)],
//         text: 'My Cognitive Journal Backup 📔',
//       );
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ Share failed: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/journal_entry.dart';

class BackupService {
  // ─────────────────────────────────────────────────────────────
  // 📤 EXPORT AS JSON (Universal: works on Android 9.0+)
  // ─────────────────────────────────────────────────────────────
  static Future<void> exportAsJson(BuildContext context) async {
    try {
      final entries = await DatabaseHelper().getAllEntries();

      final data = entries
          .map((e) => {
                "id": e.id,
                "text": e.text,
                "biases": e.biases,
                "createdAt": e.createdAt.toIso8601String(),
              })
          .toList();

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'cognitive_journal_backup_$timestamp.json';

      // ✅ Create in temp directory (works on all Android versions)
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      // ✅ Use share sheet - universal, lets user pick destination
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Cognitive Journal Backup 📔',
        subject: 'Journal Backup',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Open the share sheet and choose where to save!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 📥 RESTORE FROM JSON (Android 9.0+ compatible)
  // ─────────────────────────────────────────────────────────────
  static Future<void> restoreFromJson(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // ✅ Ensures bytes are loaded on all Android versions
      );

      if (result == null) return;

      final pickedFile = result.files.single;
      final String jsonString;

      // ✅ Try path first (Android 9.0 often provides it), fallback to bytes
      if (pickedFile.path != null && await File(pickedFile.path!).exists()) {
        jsonString = await File(pickedFile.path!).readAsString();
      } else if (pickedFile.bytes != null) {
        jsonString = utf8.decode(pickedFile.bytes!);
      } else {
        throw Exception(
            'Could not read file. Please try selecting the file again.');
      }

      final List<dynamic> decoded = jsonDecode(jsonString);
      final existingIds =
          (await DatabaseHelper().getAllEntries()).map((e) => e.id).toSet();

      int restoredCount = 0;

      for (final item in decoded) {
        if (existingIds.contains(item["id"])) continue;

        final biases = (item["biases"] as List)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();

        final entry = JournalEntry(
          id: item["id"],
          text: item["text"],
          biases: biases,
          createdAt: DateTime.parse(item["createdAt"]),
        );

        await DatabaseHelper().insertEntry(entry);
        restoredCount++;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $restoredCount entries restored!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Restore failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 📤 EXPORT RAW DATABASE FILE (.db) - Android 9.0+ compatible
  // ─────────────────────────────────────────────────────────────
  static Future<void> exportAsDatabaseFile(BuildContext context) async {
    try {
      final dbHelper = DatabaseHelper();
      const dbName = 'cognitive_journal.db';

      // ⚠️ Close DB before copying to prevent corruption
      await dbHelper.resetDatabase();

      final dbPath = p.join(await getDatabasesPath(), dbName);
      if (!await File(dbPath).exists()) {
        throw Exception('Database file not found');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'cognitive_journal_backup_$timestamp.db';

      // ✅ Copy to temp directory first
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await File(dbPath).copy(tempFile.path);

      // ✅ Reopen database for app to continue working
      await dbHelper.database;

      // ✅ Share via system sheet (user picks destination)
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'My Full Journal Database Backup 🔐',
        subject: 'Journal DB Backup',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('✅ Choose where to save the .db file in the share sheet!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Ensure DB is reopened even on failure
      await DatabaseHelper().database;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Backup failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 📥 RESTORE FROM RAW DATABASE FILE (.db) - Android 9.0+ compatible
  // ─────────────────────────────────────────────────────────────
  static Future<void> restoreFromDatabaseFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
        withData: true,
      );

      if (result == null) return;

      final pickedFile = result.files.single;
      final Uint8List? fileBytes = pickedFile.bytes;
      final String? sourcePath = pickedFile.path;

      if (fileBytes == null &&
          (sourcePath == null || !await File(sourcePath).exists())) {
        throw Exception('Could not read selected file. Try again.');
      }

      const dbName = 'cognitive_journal.db';
      final targetPath = p.join(await getDatabasesPath(), dbName);
      final dbHelper = DatabaseHelper();

      // ⚠️ Close current DB before overwriting
      await dbHelper.resetDatabase();

      // ✅ Write backup to app's database location
      if (sourcePath != null && await File(sourcePath).exists()) {
        await File(sourcePath).copy(targetPath);
      } else if (fileBytes != null) {
        await File(targetPath).writeAsBytes(fileBytes);
      } else {
        throw Exception('Could not write backup file');
      }

      // ✅ Reinitialize database with restored data
      await dbHelper.database;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Database restored! Restarting app recommended.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Reopen DB on failure
      await DatabaseHelper().database;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Restore failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 🔄 SHARE JSON BACKUP (Alias for exportAsJson - kept for compatibility)
  // ─────────────────────────────────────────────────────────────
  static Future<void> shareJsonBackup(BuildContext context) async {
    return exportAsJson(context);
  }

  // ─────────────────────────────────────────────────────────────
// 💾 SAVE BACKUP TO DEVICE (Temp File → User Picks Location → Copy)
// ─────────────────────────────────────────────────────────────
  static Future<void> saveBackupToDevice(BuildContext context) async {
    try {
      // 1️⃣ CREATE BACKUP DATA
      final entries = await DatabaseHelper().getAllEntries();
      final data = entries
          .map((e) => {
                "id": e.id,
                "text": e.text,
                "biases": e.biases,
                "createdAt": e.createdAt.toIso8601String(),
              })
          .toList();

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 2️⃣ SAVE TO APP'S TEMP DIRECTORY (Always writable)
      final tempDir = await getTemporaryDirectory();
      final tempFile =
          File('${tempDir.path}/cognitive_journal_backup_$timestamp.json');
      await tempFile.writeAsString(jsonString);

      // 3️⃣ ASK USER WHERE TO SAVE (Storage Access Framework)
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Choose location to save backup',
        fileName: 'cognitive_journal_backup.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (savedPath == null) return; // User cancelled picker

      // 4️⃣ COPY TEMP FILE TO USER'S CHOSEN LOCATION
      // Using readAsBytes/writeAsBytes works on both real paths & content URIs
      final destination = File(savedPath);
      await destination.writeAsBytes(await tempFile.readAsBytes());

      // 5️⃣ CLEANUP TEMP FILE (Optional)
      await tempFile.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('✅ Backup saved successfully to your chosen location!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // ⚠️ FALLBACK: If direct save fails (rare file manager issue), use share sheet
      try {
        final entries = await DatabaseHelper().getAllEntries();
        final data = entries
            .map((e) => {
                  "id": e.id,
                  "text": e.text,
                  "biases": e.biases,
                  "createdAt": e.createdAt.toIso8601String(),
                })
            .toList();

        final jsonString = const JsonEncoder.withIndent('  ').convert(data);
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/cognitive_backup_fallback.json');
        await file.writeAsString(jsonString);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Cognitive Journal Backup',
        );
      } catch (shareError) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed to save: $shareError'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
