import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'cognitive_journal.db');

    return await openDatabase(
      path,
      version: 2, // ⬅️ bump version so older users get new table
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // TABLE: Journal entries
    await db.execute('''
      CREATE TABLE entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        biases TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // TABLE: Consent status
    await db.execute('''
      CREATE TABLE consent(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        status INTEGER
      )
    ''');

    // Insert default consent = 0 (not accepted)
    await db.insert("consent", {"status": 0});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // If upgrading from version 1 → 2, create the consent table
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS consent(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          status INTEGER
        )
      ''');

      // Ensure default row exists
      final check = await db.query("consent", limit: 1);
      if (check.isEmpty) {
        await db.insert("consent", {"status": 0});
      }
    }
  }

  // -----------------------------------------------------------------------------
  // CONSENT FUNCTIONS
  // -----------------------------------------------------------------------------

  Future<bool> getConsent() async {
    final db = await database;
    final result = await db.query("consent", limit: 1);

    if (result.isEmpty) {
      await db.insert("consent", {"status": 0});
      return false;
    }

    return result.first["status"] == 1;
  }

  Future<void> setConsent(bool value) async {
    final db = await database;
    await db.update(
      "consent",
      {"status": value ? 1 : 0},
      where: "id = 1",
    );
  }

  // -----------------------------------------------------------------------------
  // ENTRY FUNCTIONS
  // -----------------------------------------------------------------------------

  Future<int> insertEntry(JournalEntry entry) async {
    final db = await database;
    return await db.insert('entries', entry.toMap());
  }

  Future<List<JournalEntry>> getAllEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('entries', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) {
      return JournalEntry.fromMap(maps[i]);
    });
  }

  Future<List<JournalEntry>> getTodaysEntries() async {
    final allEntries = await getAllEntries();
    final today = DateTime.now();

    return allEntries.where((entry) {
      final entryDate = entry.createdAt;
      return entryDate.year == today.year &&
          entryDate.month == today.month &&
          entryDate.day == today.day;
    }).toList();
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateEntry(JournalEntry entry) async {
    final db = await database;
    return await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }
}
