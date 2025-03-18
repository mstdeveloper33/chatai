import 'package:flutter/foundation.dart';
import 'package:client/database/database_helper.dart';
import 'package:client/features/chat/models/conversation_model.dart';
import 'package:client/features/chat/models/chat_message_model.dart';

class ConversationProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<ConversationModel> _activeConversations = [];
  List<ConversationModel> get activeConversations => _activeConversations;
  
  List<ConversationModel> _archivedConversations = [];
  List<ConversationModel> get archivedConversations => _archivedConversations;
  
  int? _currentConversationId;
  int? get currentConversationId => _currentConversationId;
  
  List<ChatMessageModel> _currentMessages = [];
  List<ChatMessageModel> get currentMessages => _currentMessages;
  
  ConversationProvider() {
    loadConversations();
  }
  
  Future<void> loadConversations() async {
    _activeConversations = await _dbHelper.getActiveConversations();
    _archivedConversations = await _dbHelper.getArchivedConversations();
    notifyListeners();
  }
  
  Future<int> createNewConversation(String firstMessageContent) async {
    final now = DateTime.now();
    
    // İlk mesajdan başlık oluştur (max 30 karakter)
    String title = firstMessageContent.length > 30 
        ? '${firstMessageContent.substring(0, 27)}...' 
        : firstMessageContent;
    
    final conversation = ConversationModel(
      title: title,
      createdAt: now,
      updatedAt: now,
    );
    
    final id = await _dbHelper.createConversation(conversation);
    _currentConversationId = id;
    
    final firstMessage = ChatMessageModel(
      role: 'user',
      content: firstMessageContent,
    );
    
    await _dbHelper.insertMessage(firstMessage, id);
    _currentMessages = [firstMessage];
    
    await loadConversations();
    return id;
  }
  
  Future<void> loadConversation(int conversationId) async {
    _currentConversationId = conversationId;
    _currentMessages = await _dbHelper.getMessagesForConversation(conversationId);
    
    // Sohbetin güncelleme tarihini yenile
    final conversation = _activeConversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => _archivedConversations.firstWhere(
        (c) => c.id == conversationId,
      ),
    );
    
    await _dbHelper.updateConversation(
      conversation.copyWith(updatedAt: DateTime.now()),
    );
    
    notifyListeners();
  }
  
  Future<void> addMessageToCurrentConversation(ChatMessageModel message) async {
    if (_currentConversationId == null) return;
    
    await _dbHelper.insertMessage(message, _currentConversationId!);
    _currentMessages.add(message);
    
    // Sohbetin güncelleme tarihini yenile
    final conversation = _activeConversations.firstWhere(
      (c) => c.id == _currentConversationId,
      orElse: () => _archivedConversations.firstWhere(
        (c) => c.id == _currentConversationId,
        orElse: () => throw Exception('Conversation not found'),
      ),
    );
    
    await _dbHelper.updateConversation(
      conversation.copyWith(updatedAt: DateTime.now()),
    );
    
    await loadConversations();
  }
  
  Future<void> archiveConversation(int conversationId) async {
    await _dbHelper.archiveConversation(conversationId);
    
    if (_currentConversationId == conversationId) {
      _currentConversationId = null;
      _currentMessages = [];
    }
    
    await loadConversations();
  }
  
  Future<void> unarchiveConversation(int conversationId) async {
    await _dbHelper.unarchiveConversation(conversationId);
    await loadConversations();
  }
  
  Future<void> deleteConversation(int conversationId) async {
    await _dbHelper.deleteConversation(conversationId);
    
    if (_currentConversationId == conversationId) {
      _currentConversationId = null;
      _currentMessages = [];
    }
    
    await loadConversations();
  }
  
  void clearCurrentConversation() {
    _currentConversationId = null;
    _currentMessages = [];
    notifyListeners();
  }
}