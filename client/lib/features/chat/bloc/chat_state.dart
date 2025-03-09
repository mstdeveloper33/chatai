import 'package:flutter/material.dart';

@immutable
sealed class ChatState {}

// Başlangıç durumu, chat henüz başlamamış
final class ChatInitial extends ChatState {}

// Yüklenme durumu, bir işlem devam ediyor
class ChatNewMessageGeneratingLoadingState extends ChatState {}

class ChatNewMessageGeneratingErrorState extends ChatState {}

class ChatNewMessageGeneratedState extends ChatState {}









// Yükleme tamamlandı, chat yanıtı alındı
class ChatLoaded extends ChatState {
  final String response;
  ChatLoaded({required this.response});
}

// Hata durumu, bir şeyler yanlış gitti
class ChatError extends ChatState {
  final String message;
  ChatError({required this.message});
} 