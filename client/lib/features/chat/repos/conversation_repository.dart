import 'package:client/database/database_helper.dart';
import 'package:client/features/chat/models/conversation_model.dart';
import 'package:client/features/chat/models/chat_message_model.dart';
import 'package:client/features/chat/repos/i_conversation_repository.dart';

/// ConversationRepository, veritabanı işlemleri için bir soyutlama katmanı sağlar.
/// Bu sınıf, Repository Pattern'i kullanarak, veritabanı erişimini ve
/// iş mantığını birbirinden ayırır ve daha iyi test edilebilirlik sağlar.
class ConversationRepository implements IConversationRepository {
  final DatabaseHelper _dbHelper;
  
  /// Yapıcı metod - varsayılan olarak bir DatabaseHelper instance'ı kullanır
  /// Dependency Injection için alternatif bir DatabaseHelper sağlanabilir
  ConversationRepository({DatabaseHelper? dbHelper}) 
      : _dbHelper = dbHelper ?? DatabaseHelper();
  
  /// Aktif (arşivlenmemiş) tüm sohbetleri getirir
  /// @return Aktif sohbetlerin listesi
  @override
  Future<List<ConversationModel>> getActiveConversations() async {
    try {
      return await _dbHelper.getActiveConversations();
    } catch (e) {
      print('Repository: Aktif sohbetleri getirme hatası: $e');
      throw Exception('Aktif sohbetler getirilirken bir hata oluştu: $e');
    
    }
  }
  
  /// Arşivlenmiş tüm sohbetleri getirir
  /// @return Arşivlenmiş sohbetlerin listesi
  @override
  Future<List<ConversationModel>> getArchivedConversations() async {
    try {
      return await _dbHelper.getArchivedConversations();
    } catch (e) {
      print('Repository: Arşivlenmiş sohbetleri getirme hatası: $e');
      throw Exception('Arşivlenmiş sohbetler getirilirken bir hata oluştu: $e');
    }
  }
  
  /// Bir sohbete ait tüm mesajları getirir
  /// @param conversationId İlgili sohbet ID'si
  /// @return Mesajların listesi
  @override
  Future<List<ChatMessageModel>> getMessagesForConversation(int conversationId) async {
    try {
      return await _dbHelper.getMessagesForConversation(conversationId);
    } catch (e) {
      print('Repository: Sohbet mesajlarını getirme hatası: $e');
      throw Exception('Sohbet mesajları getirilirken bir hata oluştu: $e');
    }
  }
  
  /// Yeni bir sohbet oluşturur
  /// @param conversation Oluşturulacak sohbet modeli
  /// @return Oluşturulan sohbetin ID'si
  @override
  Future<int> createConversation(ConversationModel conversation) async {
    try {
      return await _dbHelper.createConversation(conversation);
    } catch (e) {
      print('Repository: Sohbet oluşturma hatası: $e');
      throw Exception('Sohbet oluşturulurken bir hata oluştu: $e');
    }
  }
  
  /// Bir sohbete yeni mesaj ekler
  /// @param message Eklenecek mesaj modeli
  /// @param conversationId İlişkili sohbet ID'si
  /// @return Eklenen mesajın ID'si
  @override
  Future<int> addMessage(ChatMessageModel message, int conversationId) async {
    try {
      return await _dbHelper.insertMessage(message, conversationId);
    } catch (e) {
      print('Repository: Mesaj ekleme hatası: $e');
      throw Exception('Mesaj eklenirken bir hata oluştu: $e');
    }
  }
  
  /// Sohbet bilgilerini günceller
  /// @param conversation Güncellenecek sohbet modeli
  /// @return Etkilenen satır sayısı
  @override
  Future<int> updateConversation(ConversationModel conversation) async {
    try {
      return await _dbHelper.updateConversation(conversation);
    } catch (e) {
      print('Repository: Sohbet güncelleme hatası: $e');
      throw Exception('Sohbet güncellenirken bir hata oluştu: $e');
    }
  }
  
  /// Bir sohbeti arşive taşır
  /// @param conversationId Arşivlenecek sohbetin ID'si
  /// @return Etkilenen satır sayısı
  @override
  Future<int> archiveConversation(int conversationId) async {
    try {
      return await _dbHelper.archiveConversation(conversationId);
    } catch (e) {
      print('Repository: Sohbeti arşivleme hatası: $e');
      throw Exception('Sohbet arşivlenirken bir hata oluştu: $e');
    }
  }
  
  /// Bir sohbeti arşivden çıkarır
  /// @param conversationId Arşivden çıkarılacak sohbetin ID'si
  /// @return Etkilenen satır sayısı
  @override
  Future<int> unarchiveConversation(int conversationId) async {
    try {
      return await _dbHelper.unarchiveConversation(conversationId);
    } catch (e) {
      print('Repository: Sohbeti arşivden çıkarma hatası: $e');
      throw Exception('Sohbet arşivden çıkarılırken bir hata oluştu: $e');
    }
  }
  
  /// Bir sohbeti tamamen siler
  /// @param conversationId Silinecek sohbetin ID'si
  /// @return Etkilenen satır sayısı
  @override
  Future<int> deleteConversation(int conversationId) async {
    try {
      return await _dbHelper.deleteConversation(conversationId);
    } catch (e) {
      print('Repository: Sohbeti silme hatası: $e');
      throw Exception('Sohbet silinirken bir hata oluştu: $e');
    }
  }
} 