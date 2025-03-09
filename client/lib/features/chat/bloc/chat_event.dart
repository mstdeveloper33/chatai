import 'package:flutter/material.dart';

@immutable
sealed class ChatEvent {}

class ChatNewPromptEvent extends ChatEvent {
  final String prompt;
  ChatNewPromptEvent({required this.prompt});
}

class ChatNewContentGeneratedEvent extends ChatEvent {
  final String content;
  ChatNewContentGeneratedEvent({required this.content});
}

