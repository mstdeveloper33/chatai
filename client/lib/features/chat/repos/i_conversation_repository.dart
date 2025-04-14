import 'package:client/features/chat/models/conversation_model.dart';
import 'package:client/features/chat/models/chat_message_model.dart';

/// IConversationRepository, sohbet verilerine erişim için gerekli metotları tanımlayan arayüz.
/// Bu arayüz, Dependency Inversion Principle (SOLID) uygulanarak,
/// yüksek seviyeli modüllerin (örn. Provider) düşük seviyeli modüllere (örn. Repository)
/// doğrudan bağımlı olmasını önler.
abstract class IConversationRepository {
  /// Aktif (arşivlenmemiş) tüm sohbetleri getirir
  Future<List<ConversationModel>> getActiveConversations();
  
  /// Arşivlenmiş tüm sohbetleri getirir
  Future<List<ConversationModel>> getArchivedConversations();
  
  /// Bir sohbete ait tüm mesajları getirir
  Future<List<ChatMessageModel>> getMessagesForConversation(int conversationId);
  
  /// Yeni bir sohbet oluşturur
  Future<int> createConversation(ConversationModel conversation);
  
  /// Bir sohbete yeni mesaj ekler
  Future<int> addMessage(ChatMessageModel message, int conversationId);
  
  /// Sohbet bilgilerini günceller
  Future<int> updateConversation(ConversationModel conversation);
  
  /// Bir sohbeti arşive taşır
  Future<int> archiveConversation(int conversationId);
  
  /// Bir sohbeti arşivden çıkarır
  Future<int> unarchiveConversation(int conversationId);
  
  /// Bir sohbeti tamamen siler
  Future<int> deleteConversation(int conversationId);
} 