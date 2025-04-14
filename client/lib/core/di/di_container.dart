import 'package:client/database/database_helper.dart';
import 'package:client/features/chat/repos/i_conversation_repository.dart';
import 'package:client/features/chat/repos/conversation_repository.dart';
import 'package:client/features/chat/providers/conversation_provider.dart';
import 'package:client/features/chat/providers/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// DependencyInjection sınıfı, uygulama genelindeki bağımlılıkları yönetir.
/// Singleton tasarım deseni kullanarak, tüm bağımlılıkları merkezi bir yerden sağlar.
/// Bu yaklaşım, bağımlılıkların test edilebilirliğini ve yönetimini kolaylaştırır.
class DependencyInjection {
  static final DependencyInjection _instance = DependencyInjection._internal();
  factory DependencyInjection() => _instance;
  
  DependencyInjection._internal();
  
  /// Veritabanı yardımcısı
  late final DatabaseHelper _databaseHelper;
  
  /// Sohbet repository'si
  late final IConversationRepository _conversationRepository;
  
  /// Uygulamanın dependency injection sistemini başlatır
  Future<void> init() async {
    // Singleton örneklerin oluşturulması
    _databaseHelper = DatabaseHelper();
    _conversationRepository = ConversationRepository(dbHelper: _databaseHelper);
  }
  
  /// Provider paketinin kullanacağı provider listesini döndürür
  List<SingleChildWidget> get providers => [
    // Repository Provider'ları
    Provider<IConversationRepository>.value(value: _conversationRepository),
    
    // ChangeNotifier Provider'lar
    ChangeNotifierProvider<ConversationProvider>(
      create: (_) => ConversationProvider(repository: _conversationRepository),
    ),
    ChangeNotifierProvider<ChatProvider>(
      create: (_) => ChatProvider(),
    ),
  ];
  
  // Getter'lar
  DatabaseHelper get databaseHelper => _databaseHelper;
  IConversationRepository get conversationRepository => _conversationRepository;
} 