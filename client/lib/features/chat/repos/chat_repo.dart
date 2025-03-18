import 'dart:convert';
import 'package:client/features/chat/models/chat_message_model.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getChatResponse(String prompt) async {
  // Doğru IP adresi ve portu kullanın
  //final String baseUrl = 'http://10.0.2.2:3000'; // Android emülatör için
  // final String baseUrl = 'http://127.0.0.1:3000'; // iOS simülatör için
   final String baseUrl = 'http://192.168.1.201:3000'; // Fiziksel cihaz için
  // final String baseUrl = 'http://localhost:3000'; // Web için
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/generate_response'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "prompt": prompt
      })
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("API Hatası: ${response.statusCode} - ${response.body}");
      return {"error": "API hatası: ${response.statusCode}"};
    }
  } catch (e) {
    print("Bağlantı hatası: $e");
    return {"error": "Bağlantı hatası"};
  }
}

Stream<Map<String, dynamic>> getChatGptResponseRepo(
  List<ChatMessageModel> messages 
) async* {
  // Son kullanıcı mesajını al
  String lastUserMessage = "";
  for (int i = messages.length - 1; i >= 0; i--) {
    if (messages[i].role == "user") {
      lastUserMessage = messages[i].content;
      break;
    }
  }

  try {
    final responseData = await getChatResponse(lastUserMessage);
    yield responseData;
  } catch (e) {
    print("Hata: $e");
    yield {"error": "İşlem sırasında hata oluştu"};
  }
}