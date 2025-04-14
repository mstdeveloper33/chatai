import 'package:flutter/foundation.dart';
import 'package:client/features/chat/models/conversation_model.dart';
import 'package:client/features/chat/models/chat_message_model.dart';
import 'package:client/features/chat/repos/i_conversation_repository.dart';
import 'package:client/features/chat/repos/conversation_repository.dart';

/// ConversationProvider, MVVM mimarisindeki ViewModel katmanını temsil eder.
/// Sohbet verilerini yönetir, repository üzerinden veritabanı işlemlerini gerçekleştirir 
/// ve UI bileşenlerine veri sunar, böylece UI ile veri katmanı arasındaki
/// bağlantıyı sağlar.
class ConversationProvider extends ChangeNotifier {
  /// Repository arayüzü, veritabanı işlemlerini gerçekleştirir
  final IConversationRepository _repository;
  
  // Durum (State) değişkenleri
  
  /// Aktif (arşivlenmemiş) sohbetlerin listesi
  List<ConversationModel> _activeConversations = [];
  
  /// Arşivlenmiş sohbetlerin listesi
  List<ConversationModel> _archivedConversations = [];
  
  /// Şu anda seçili olan sohbetin ID'si
  int? _currentConversationId;
  
  /// Şu anda seçili olan sohbetin mesajları
  List<ChatMessageModel> _currentMessages = [];
  
  // Getters - UI bileşenleri için veri sağlayıcıları
  
  /// Aktif sohbetlerin listesini döndürür
  List<ConversationModel> get activeConversations => _activeConversations;
  
  /// Arşivlenmiş sohbetlerin listesini döndürür
  List<ConversationModel> get archivedConversations => _archivedConversations;
  
  /// Şu anda seçili olan sohbetin ID'sini döndürür
  int? get currentConversationId => _currentConversationId;
  
  /// Şu anda seçili olan sohbetin mesajlarını döndürür
  List<ChatMessageModel> get currentMessages => _currentMessages;
  
  /// Aktif veya arşivlenen bir sohbetin seçili olup olmadığını kontrol eder
  bool get hasSelectedConversation => _currentConversationId != null;
  
  /// Yapıcı metod - sınıf oluşturulduğunda sohbetleri yükler
  /// Dependency Injection için repository parametresi alabilir
  ConversationProvider({IConversationRepository? repository}) 
      : _repository = repository ?? ConversationRepository() {
    loadConversations();
  }
  
  /// Veritabanından tüm sohbetleri yükler ve state'i günceller
  Future<void> loadConversations() async {
    try {
      _activeConversations = await _repository.getActiveConversations();
      _archivedConversations = await _repository.getArchivedConversations();
      notifyListeners();
    } catch (e) {
      print('ViewModel: Sohbetleri yükleme hatası: $e');
      // Hata durumunu UI'a iletmek için özelleştirilmiş bir hata yönetimi eklenebilir
    }
  }
  
  /// Yeni bir sohbet oluşturur ve ilk mesajı ekler
  /// @param firstMessageContent İlk mesaj içeriği (kullanıcıdan)
  /// @return Oluşturulan sohbetin ID'si
  Future<int> createNewConversation(String firstMessageContent) async {
    try {
      final now = DateTime.now();
      
      // İlk mesajdan başlık oluştur (max 30 karakter)
      String title = firstMessageContent.length > 30 
          ? '${firstMessageContent.substring(0, 27)}...' 
          : firstMessageContent;
      
      // Yeni sohbet modeli oluşturma
      final conversation = ConversationModel(
        title: title,
        createdAt: now,
        updatedAt: now,
      );
      
      // Repository üzerinden veritabanına kaydetme
      final id = await _repository.createConversation(conversation);
      _currentConversationId = id;
      
      // İlk mesajı ekleme
      final firstMessage = ChatMessageModel(
        role: 'user',
        content: firstMessageContent,
      );
      
      await _repository.addMessage(firstMessage, id);
      _currentMessages = [firstMessage];
      
      // UI'ı güncellemek için sohbetleri yeniden yükleme
      await loadConversations();
      return id;
    } catch (e) {
      print('ViewModel: Yeni sohbet oluşturma hatası: $e');
      throw Exception('Sohbet oluşturulurken bir hata oluştu: $e');
    }
  }
  
  /// Var olan bir sohbeti ve mesajlarını yükler
  /// @param conversationId Yüklenecek sohbetin ID'si
  Future<void> loadConversation(int conversationId) async {
    try {
      _currentConversationId = conversationId;
      _currentMessages = await _repository.getMessagesForConversation(conversationId);
      
      // Sohbetin güncelleme tarihini yenile
      final conversation = _findConversationById(conversationId);
      
      await _repository.updateConversation(
        conversation.copyWith(updatedAt: DateTime.now()),
      );
      
      notifyListeners();
    } catch (e) {
      print('ViewModel: Sohbet yükleme hatası: $e');
      throw Exception('Sohbet yüklenirken bir hata oluştu: $e');
    }
  }
  
  /// Mevcut sohbete yeni bir mesaj ekler
  /// @param message Eklenecek mesaj modeli
  Future<void> addMessageToCurrentConversation(ChatMessageModel message) async {
    if (_currentConversationId == null) {
      throw Exception('Mesaj eklemek için aktif bir sohbet seçilmemiş');
    }
    
    try {
      await _repository.addMessage(message, _currentConversationId!);
      _currentMessages.add(message);
      
      // Sohbetin güncelleme tarihini yenile
      final conversation = _findConversationById(_currentConversationId!);
      
      await _repository.updateConversation(
        conversation.copyWith(updatedAt: DateTime.now()),
      );
      
      await loadConversations();
      notifyListeners();
    } catch (e) {
      print('ViewModel: Mesaj ekleme hatası: $e');
      throw Exception('Mesaj eklenirken bir hata oluştu: $e');
    }
  }
  
  /// Bir sohbeti arşive taşır
  /// @param conversationId Arşivlenecek sohbetin ID'si
  Future<void> archiveConversation(int conversationId) async {
    try {
      await _repository.archiveConversation(conversationId);
      
      if (_currentConversationId == conversationId) {
        _currentConversationId = null;
        _currentMessages = [];
      }
      
      await loadConversations();
    } catch (e) {
      print('ViewModel: Sohbeti arşivleme hatası: $e');
      throw Exception('Sohbet arşivlenirken bir hata oluştu: $e');
    }
  }
  
  /// Bir sohbeti arşivden çıkarır
  /// @param conversationId Arşivden çıkarılacak sohbetin ID'si
  Future<void> unarchiveConversation(int conversationId) async {
    try {
      await _repository.unarchiveConversation(conversationId);
      await loadConversations();
    } catch (e) {
      print('ViewModel: Sohbeti arşivden çıkarma hatası: $e');
      throw Exception('Sohbet arşivden çıkarılırken bir hata oluştu: $e');
    }
  }
  
  /// Bir sohbeti tamamen siler
  /// @param conversationId Silinecek sohbetin ID'si
  Future<void> deleteConversation(int conversationId) async {
    try {
      await _repository.deleteConversation(conversationId);
      
      if (_currentConversationId == conversationId) {
        _currentConversationId = null;
        _currentMessages = [];
      }
      
      await loadConversations();
    } catch (e) {
      print('ViewModel: Sohbeti silme hatası: $e');
      throw Exception('Sohbet silinirken bir hata oluştu: $e');
    }
  }
  
  /// Seçili sohbeti temizler
  void clearCurrentConversation() {
    _currentConversationId = null;
    _currentMessages = [];
    notifyListeners();
  }
  
  /// Sohbet ID'sine göre sohbet modelini bulur
  /// @param conversationId Aranacak sohbetin ID'si
  /// @return Bulunan ConversationModel nesnesi
  /// @throws Exception Sohbet bulunamazsa
  ConversationModel _findConversationById(int conversationId) {
    return _activeConversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => _archivedConversations.firstWhere(
        (c) => c.id == conversationId,
        orElse: () => throw Exception('Sohbet bulunamadı: ID $conversationId'),
      ),
    );
  }
}