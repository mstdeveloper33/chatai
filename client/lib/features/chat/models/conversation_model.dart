import 'dart:convert';
import 'package:client/features/chat/models/chat_message_model.dart';

/// ConversationModel, bir sohbet oturumunu temsil eden veri modelidir.
/// Bu model, sohbetin başlığını, oluşturulma ve güncellenme zamanlarını, 
/// arşivlenme durumunu ve sohbete ait mesajları içerir.
class ConversationModel {
  /// Sohbet ID'si (veritabanında otomatik oluşturulur)
  final int? id;
  
  /// Sohbet başlığı
  final String title;
  
  /// Sohbetin oluşturulma tarihi
  final DateTime createdAt;
  
  /// Sohbetin son güncellenme tarihi
  final DateTime updatedAt;
  
  /// Sohbetin arşivlenme durumu
  final bool isArchived;
  
  /// Sohbete ait mesajların listesi (opsiyonel)
  final List<ChatMessageModel>? messages;

  /// Yapıcı metod - yeni bir sohbet nesnesi oluşturur
  /// @param id Sohbet ID'si (opsiyonel)
  /// @param title Sohbet başlığı
  /// @param createdAt Oluşturulma tarihi
  /// @param updatedAt Son güncellenme tarihi
  /// @param isArchived Arşivlenme durumu (varsayılan: false)
  /// @param messages Sohbet mesajları (opsiyonel)
  ConversationModel({
    this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.messages,
  });

  /// Model nesnesini Map yapısına dönüştürür (veritabanına kayıt için)
  /// @return Map olarak sohbet verileri
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_archived': isArchived ? 1 : 0,
    };
  }

  /// Map yapısından model nesnesi oluşturur (veritabanından okuma için)
  /// @param map Sohbet verilerini içeren Map yapısı
  /// @return Oluşturulan ConversationModel nesnesi
  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'],
      title: map['title'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isArchived: map['is_archived'] == 1,
    );
  }
  
  /// Model nesnesini JSON formatına dönüştürür (API iletişimi için)
  /// @return JSON formatında sohbet verileri
  String toJson() => json.encode(toMap());

  /// JSON formatından model nesnesi oluşturur (API iletişimi için)
  /// @param source JSON formatında sohbet verileri
  /// @return Oluşturulan ConversationModel nesnesi
  factory ConversationModel.fromJson(String source) => 
      ConversationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Mevcut sohbetin bir kopyasını, belirtilen parametreleri değiştirerek oluşturur
  /// @param id Yeni ID değeri (opsiyonel)
  /// @param title Yeni başlık değeri (opsiyonel)
  /// @param createdAt Yeni oluşturulma tarihi (opsiyonel)
  /// @param updatedAt Yeni güncellenme tarihi (opsiyonel)
  /// @param isArchived Yeni arşivlenme durumu (opsiyonel)
  /// @param messages Yeni mesaj listesi (opsiyonel)
  /// @return Yeni ConversationModel nesnesi
  ConversationModel copyWith({
    int? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    List<ChatMessageModel>? messages,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      messages: messages ?? this.messages,
    );
  }
  
  /// Sohbetin ne kadar süre önce güncellendiğini insan tarafından okunabilir formatta döndürür
  /// @return Zaman bilgisi (örn: "5 dakika önce", "2 saat önce", "1 gün önce")
  String get lastUpdatedText {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
  
  @override
  String toString() => 'ConversationModel(id: $id, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, isArchived: $isArchived)';
}