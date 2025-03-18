import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:client/features/chat/models/chat_message_model.dart';
import 'package:client/features/chat/repos/chat_repo.dart';

enum ChatStatus {
  initial,
  loading,
  loaded,
  error,
}

class ChatProvider extends ChangeNotifier {
  ChatStatus _status = ChatStatus.initial;
  ChatStatus get status => _status;
  
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  
  List<ChatMessageModel> cachedMessages = [];
  StreamSubscription<Map<String, dynamic>>? _subscription;

  void sendPrompt(String prompt) {
    _status = ChatStatus.loading;
    notifyListeners();
    
    try {
      ChatMessageModel newMessage = ChatMessageModel(role: "user", content: prompt);
      cachedMessages.add(newMessage);
      notifyListeners();
      
      cachedMessages.add(ChatMessageModel(role: "assistant", content: ""));
      notifyListeners();
      
      _subscription?.cancel();
      _subscription = getChatGptResponseRepo(cachedMessages).listen(
        (data) {
          log("API Yanıtı: $data");
          
          try {
            if (data.containsKey('success') && data['success'] == true && 
                data.containsKey('data') && data['data'].containsKey('message')) {
              String message = data['data']['message'];
              updateAssistantMessage(message);
            } else if (data.containsKey('error')) {
              _status = ChatStatus.error;
              _errorMessage = data['error'] ?? 'Bilinmeyen hata';
              notifyListeners();
            }
          } catch (e) {
            log("Yanıt işleme hatası: $e");
            _status = ChatStatus.error;
            _errorMessage = 'Yanıt işleme hatası: $e';
            notifyListeners();
          }
        },
        onError: (error) {
          log("Stream hatası: $error");
          _status = ChatStatus.error;
          _errorMessage = 'Stream hatası: $error';
          notifyListeners();
        }
      );
    } catch (e) {
      log("Genel hata: $e");
      _status = ChatStatus.error;
      _errorMessage = 'Genel hata: $e';
      notifyListeners();
    }
  }
  
  void updateAssistantMessage(String content) {
  // Son mesajı güncelle (bu assistant mesajı olmalı)
  cachedMessages.last = ChatMessageModel(role: "assistant", content: content);
  _status = ChatStatus.loaded;
  notifyListeners();
}
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}