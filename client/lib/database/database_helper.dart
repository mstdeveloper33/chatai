import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:client/features/chat/models/conversation_model.dart';
import 'package:client/features/chat/models/chat_message_model.dart';

/// DatabaseHelper sınıfı, uygulama genelinde kullanılan SQLite veritabanı işlemlerini yönetir.
/// Singleton tasarım deseni kullanılarak oluşturulmuştur.
class DatabaseHelper {
  // Singleton yapısı
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  
  // Veritabanı instance
  static Database? _database;
  
  // Özel constructor
  DatabaseHelper._internal();

  /// Veritabanı nesnesini döndürür, eğer oluşturulmamışsa önce oluşturur.
  /// Bu lazy initialization yaklaşımı gereksiz veritabanı bağlantılarını önler.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Veritabanını ilk kez oluşturur ve yapılandırır.
  /// @return Oluşturulan Database nesnesi
  Future<Database> _initDatabase() async {
    // Veritabanı dosyası için geçerli bir dosya yolu oluşturma
    String path = join(await getDatabasesPath(), 'chat_database.db');
    
    // Veritabanını açma veya oluşturma
    return await openDatabase(
      path,
      version: 1, // Veritabanı şema versiyonu
      onCreate: _createDatabase, // Veritabanı ilk oluşturulduğunda çalışacak metod
    );
  }

  /// Veritabanı tabloları ve şemasını oluşturur
  /// @param db Veritabanı nesnesi
  /// @param version Veritabanı versiyon numarası
  Future<void> _createDatabase(Database db, int version) async {
    // Sohbetler tablosu
    await db.execute('''
      CREATE TABLE conversations (
        id INTEGER PRIMARY KEY AUTOINCREMENT, /* Benzersiz sohbet kimliği */
        title TEXT,                           /* Sohbet başlığı */
        created_at TEXT,                      /* Oluşturulma tarihi (ISO8601 formatında) */
        updated_at TEXT,                      /* Güncellenme tarihi (ISO8601 formatında) */
        is_archived INTEGER DEFAULT 0         /* Arşivlenme durumu (0: aktif, 1: arşivlenmiş) */
      )
    ''');

    // Mesajlar tablosu
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT, /* Benzersiz mesaj kimliği */
        conversation_id INTEGER,              /* İlişkili sohbet kimliği (foreign key) */
        role TEXT,                            /* Mesaj rolü (user, assistant) */
        content TEXT,                         /* Mesaj içeriği */
        created_at TEXT,                      /* Oluşturulma tarihi (ISO8601 formatında) */
        FOREIGN KEY (conversation_id) REFERENCES conversations (id) 
          ON DELETE CASCADE                   /* Sohbet silindiğinde ilişkili mesajlar da silinir */
      )
    ''');
  }

  // CRUD İŞLEMLERİ - Sohbetler
  
  /// Yeni bir sohbet oluşturur ve veritabanına kaydeder
  /// @param conversation Oluşturulacak sohbet modeli
  /// @return Oluşturulan sohbetin ID'si
  Future<int> createConversation(ConversationModel conversation) async {
    final db = await database;
    return await db.insert('conversations', conversation.toMap());
  }

  /// Aktif (arşivlenmemiş) tüm sohbetleri getirir
  /// @return Aktif sohbetlerin listesi
  Future<List<ConversationModel>> getActiveConversations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      where: 'is_archived = ?',
      whereArgs: [0],
      orderBy: 'updated_at DESC', // En son güncellenen sohbetler başta gösterilir
    );
    
    return List.generate(maps.length, (i) {
      return ConversationModel.fromMap(maps[i]);
    });
  }

  /// Arşivlenmiş tüm sohbetleri getirir
  /// @return Arşivlenmiş sohbetlerin listesi
  Future<List<ConversationModel>> getArchivedConversations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      where: 'is_archived = ?',
      whereArgs: [1],
      orderBy: 'updated_at DESC', // En son güncellenen sohbetler başta gösterilir
    );
    
    return List.generate(maps.length, (i) {
      return ConversationModel.fromMap(maps[i]);
    });
  }

  /// Sohbet bilgilerini günceller
  /// @param conversation Güncellenecek sohbet modeli
  /// @return Etkilenen satır sayısı
  Future<int> updateConversation(ConversationModel conversation) async {
    final db = await database;
    return await db.update(
      'conversations',
      conversation.toMap(),
      where: 'id = ?',
      whereArgs: [conversation.id],
    );
  }

  /// Bir sohbeti arşive taşır
  /// @param id Arşivlenecek sohbetin ID'si
  /// @return Etkilenen satır sayısı
  Future<int> archiveConversation(int id) async {
    final db = await database;
    return await db.update(
      'conversations',
      {'is_archived': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Bir sohbeti arşivden çıkarır
  /// @param id Arşivden çıkarılacak sohbetin ID'si
  /// @return Etkilenen satır sayısı
  Future<int> unarchiveConversation(int id) async {
    final db = await database;
    return await db.update(
      'conversations',
      {'is_archived': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Bir sohbeti ve ilişkili tüm mesajlarını siler
  /// @param id Silinecek sohbetin ID'si
  /// @return Etkilenen satır sayısı
  Future<int> deleteConversation(int id) async {
    final db = await database;
    
    try {
      // Transaction kullanarak atomik silme işlemi gerçekleştirme
      return await db.transaction<int>((txn) async {
        // Önce ilişkili mesajları silelim
        await txn.delete(
          'messages',
          where: 'conversation_id = ?',
          whereArgs: [id],
        );
        
        // Sonra sohbeti silelim
        return await txn.delete(
          'conversations',
          where: 'id = ?',
          whereArgs: [id],
        );
      });
    } catch (e) {
      // Hata durumunu loglama ve rethrow
      print('Sohbet silme hatası: $e');
      throw Exception('Sohbet silinirken bir hata oluştu: $e');
    }
  }

  // CRUD İŞLEMLERİ - Mesajlar
  
  /// Bir sohbete yeni mesaj ekler
  /// @param message Eklenecek mesaj modeli
  /// @param conversationId İlişkili sohbet ID'si
  /// @return Eklenen mesajın ID'si
  Future<int> insertMessage(ChatMessageModel message, int conversationId) async {
    final db = await database;
    final Map<String, dynamic> messageMap = message.toMap();
    messageMap['conversation_id'] = conversationId;
    messageMap['created_at'] = DateTime.now().toIso8601String();
    
    try {
      return await db.insert('messages', messageMap);
    } catch (e) {
      print('Mesaj ekleme hatası: $e');
      throw Exception('Mesaj eklenirken bir hata oluştu: $e');
    }
  }

  /// Bir sohbete ait tüm mesajları getirir
  /// @param conversationId İlgili sohbet ID'si
  /// @return Mesajların listesi, oluşturulma tarihine göre sıralanmış
  Future<List<ChatMessageModel>> getMessagesForConversation(int conversationId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC', // Mesajlar kronolojik sırada gösterilir
    );
    
    return List.generate(maps.length, (i) {
      final message = ChatMessageModel.fromMap(maps[i]);
      return message;
    });
  }
}