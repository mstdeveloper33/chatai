import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:client/features/chat/models/conversation_model.dart';
import 'package:client/features/chat/models/chat_message_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  
  static Database? _database;
  
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE conversations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_archived INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id INTEGER,
        role TEXT,
        content TEXT,
        created_at TEXT,
        FOREIGN KEY (conversation_id) REFERENCES conversations (id) 
          ON DELETE CASCADE
      )
    ''');
  }

  // Yeni bir sohbet oluştur
  Future<int> createConversation(ConversationModel conversation) async {
    final db = await database;
    return await db.insert('conversations', conversation.toMap());
  }

  // Bir mesaj ekle
  Future<int> insertMessage(ChatMessageModel message, int conversationId) async {
    final db = await database;
    final Map<String, dynamic> messageMap = message.toMap();
    messageMap['conversation_id'] = conversationId;
    messageMap['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('messages', messageMap);
  }

  // Tüm aktif sohbetleri getir
  Future<List<ConversationModel>> getActiveConversations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      where: 'is_archived = ?',
      whereArgs: [0],
      orderBy: 'updated_at DESC',
    );
    
    return List.generate(maps.length, (i) {
      return ConversationModel.fromMap(maps[i]);
    });
  }

  // Arşivlenmiş sohbetleri getir
  Future<List<ConversationModel>> getArchivedConversations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      where: 'is_archived = ?',
      whereArgs: [1],
      orderBy: 'updated_at DESC',
    );
    
    return List.generate(maps.length, (i) {
      return ConversationModel.fromMap(maps[i]);
    });
  }

  // Bir sohbete ait tüm mesajları getir
  Future<List<ChatMessageModel>> getMessagesForConversation(int conversationId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC',
    );
    
    return List.generate(maps.length, (i) {
      final message = ChatMessageModel.fromMap(maps[i]);
      return message;
    });
  }

  // Sohbeti güncelle
  Future<int> updateConversation(ConversationModel conversation) async {
    final db = await database;
    return await db.update(
      'conversations',
      conversation.toMap(),
      where: 'id = ?',
      whereArgs: [conversation.id],
    );
  }

  // Sohbeti arşivle
  Future<int> archiveConversation(int id) async {
    final db = await database;
    return await db.update(
      'conversations',
      {'is_archived': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Sohbeti arşivden çıkar
  Future<int> unarchiveConversation(int id) async {
    final db = await database;
    return await db.update(
      'conversations',
      {'is_archived': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Sohbeti sil
  Future<int> deleteConversation(int id) async {
    final db = await database;
    
    // Önce ilişkili mesajları silelim
    await db.delete(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [id],
    );
    
    // Sonra sohbeti silelim
    return await db.delete(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}