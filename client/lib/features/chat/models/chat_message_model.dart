import 'dart:convert';

/// ChatMessageModel, bir sohbet mesajını temsil eden veri modelidir.
/// Bu model, mesajın rolünü (kullanıcı veya asistan) ve içeriğini tutar.
class ChatMessageModel {
  /// Mesajın rolü: 'user' (kullanıcı) veya 'assistant' (yapay zeka)
  final String role;
  
  /// Mesajın metin içeriği
  final String content;
  
  /// Yapıcı metod - yeni bir mesaj nesnesi oluşturur
  /// @param role Mesaj rolü ('user' veya 'assistant')
  /// @param content Mesaj metni
  ChatMessageModel({
    required this.role,
    required this.content,
  });

  /// Model nesnesini Map yapısına dönüştürür (veritabanına kayıt için)
  /// @return Map olarak mesaj verileri
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'role': role,
      'content': content,
    };
  }

  /// Map yapısından model nesnesi oluşturur (veritabanından okuma için)
  /// @param map Mesaj verilerini içeren Map yapısı
  /// @return Oluşturulan ChatMessageModel nesnesi
  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      role: map['role'] as String,
      content: map['content'] as String,
    );
  }

  /// Model nesnesini JSON formatına dönüştürür (API iletişimi için)
  /// @return JSON formatında mesaj verileri
  String toJson() => json.encode(toMap());

  /// JSON formatından model nesnesi oluşturur (API iletişimi için)
  /// @param source JSON formatında mesaj verileri
  /// @return Oluşturulan ChatMessageModel nesnesi
  factory ChatMessageModel.fromJson(String source) => 
      ChatMessageModel.fromMap(json.decode(source) as Map<String, dynamic>);
      
  /// Mevcut mesajın bir kopyasını oluşturur
  /// @param role Opsiyonel yeni rol değeri
  /// @param content Opsiyonel yeni içerik değeri
  /// @return Yeni ChatMessageModel nesnesi
  ChatMessageModel copyWith({
    String? role,
    String? content,
  }) {
    return ChatMessageModel(
      role: role ?? this.role,
      content: content ?? this.content,
    );
  }
  
  /// Mesajın kullanıcıdan gelip gelmediğini kontrol eder
  /// @return Mesaj kullanıcıdan gelmişse true, değilse false
  bool get isUserMessage => role == 'user';
  
  /// Mesajın asistandan gelip gelmediğini kontrol eder
  /// @return Mesaj asistandan gelmişse true, değilse false
  bool get isAssistantMessage => role == 'assistant';
  
  @override
  String toString() => 'ChatMessageModel(role: $role, content: $content)';
}
