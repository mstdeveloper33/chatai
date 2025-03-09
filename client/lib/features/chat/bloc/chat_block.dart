import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:client/features/chat/bloc/chat_event.dart';
import 'package:client/features/chat/bloc/chat_state.dart';
import 'package:client/features/chat/models/chat_message_model.dart';

import '../repos/chat_repo.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
   on<ChatNewPromptEvent>(chatNewPromptEvent);
   on<ChatNewContentGeneratedEvent>(chatNewContentGeneratedEvent);
  }

  StreamSubscription<Map<String, dynamic>>? _subscription; 
  List<ChatMessageModel> cachedMessages = [];
  
  FutureOr<void> chatNewPromptEvent(ChatNewPromptEvent event, Emitter<ChatState> emit) {
    emit(ChatNewMessageGeneratingLoadingState());

    try {
      ChatMessageModel newMessage = ChatMessageModel(role: "user", content: event.prompt);
      cachedMessages.add(newMessage);
      emit(ChatNewMessageGeneratedState());
      cachedMessages.add(ChatMessageModel(role: "assistant", content: ""));
      
      _subscription?.cancel();
      _subscription = getChatGptResponseRepo(cachedMessages).listen(
        (data) {
          log("API Yanıtı: $data");
          
          try {
            if (data.containsKey('success') && data['success'] == true && 
                data.containsKey('data') && data['data'].containsKey('message')) {
              String message = data['data']['message'];
              // Yeni satır karakterlerini temizle
              message = message.replaceAll('\n', ' ');
              add(ChatNewContentGeneratedEvent(content: message));
            } else if (data.containsKey('error')) {
              emit(ChatNewMessageGeneratingErrorState());
            }
          } catch (e) {
            log("Yanıt işleme hatası: $e");
            emit(ChatNewMessageGeneratingErrorState());
          }
        },
        onError: (error) {
          log("Stream hatası: $error");
          emit(ChatNewMessageGeneratingErrorState());
        }
      );
    } catch (e) {
      log("Genel hata: $e");
      emit(ChatNewMessageGeneratingErrorState());
    }
  }
  
  FutureOr<void> chatNewContentGeneratedEvent(ChatNewContentGeneratedEvent event, Emitter<ChatState> emit) {
    ChatMessageModel modelMessage = cachedMessages.last;
    String content = event.content;
    cachedMessages.last = ChatMessageModel(role: "assistant", content: content);
    emit(ChatNewMessageGeneratedState());
  }
  
  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}