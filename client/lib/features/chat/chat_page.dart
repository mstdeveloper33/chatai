import 'package:client/design/app_colors.dart';
import 'package:client/features/chat/models/chat_message_model.dart';
import 'package:client/features/chat/models/conversation_model.dart';
import 'package:client/features/chat/providers/chat_provider.dart';
import 'package:client/features/chat/providers/conversation_provider.dart';
import 'package:client/features/chat/widgets/chat_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showArchived = false;
  
  @override
  void initState() {
    super.initState();
    // Sohbet geçmişini yükle
    Future.delayed(Duration.zero, () {
      Provider.of<ConversationProvider>(context, listen: false).loadConversations();
    });
    
    // ChatProvider'dan gelen yanıtları dinlemek için listener ekle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupChatListener();
    });
  }
  
  void _setupChatListener() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    // Listener'ı kuruyoruz
    chatProvider.addListener(() {
      if (chatProvider.status == ChatStatus.loaded && 
          chatProvider.cachedMessages.isNotEmpty && 
          chatProvider.cachedMessages.last.role == 'assistant') {
        
        final convProvider = Provider.of<ConversationProvider>(context, listen: false);
        
        // Yanıtı veritabanına ekle
        final assistantMessage = chatProvider.cachedMessages.last;
        if (assistantMessage.content.isNotEmpty && convProvider.currentConversationId != null) {
          print("Assistant mesajı ekleniyor: ${assistantMessage.content}");
          convProvider.addMessageToCurrentConversation(assistantMessage);
        }
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("CustomGPT"),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Yeni Sohbet',
            onPressed: () {
              // Yeni sohbet başlat
              Provider.of<ConversationProvider>(context, listen: false).clearCurrentConversation();
              Provider.of<ChatProvider>(context, listen: false).cachedMessages.clear();
              Provider.of<ChatProvider>(context, listen: false).notifyListeners();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Consumer2<ChatProvider, ConversationProvider>(
        builder: (context, chatProvider, conversationProvider, child) {
          // Hangi mesajları göstereceğimizi seçelim
          List<ChatMessageModel> messagesToShow = [];
          
          if (conversationProvider.currentConversationId != null) {
            // Mevcut bir sohbet varsa, onun mesajlarını göster
            messagesToShow = conversationProvider.currentMessages;
            print("Showing conversation messages: ${messagesToShow.length}");
          } else {
            // Yeni sohbet başlatılmışsa ChatProvider'dan mesajları göster
            messagesToShow = chatProvider.cachedMessages;
            print("Showing chat provider messages: ${messagesToShow.length}");
          }
          
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: messagesToShow.length,
                  itemBuilder: (context, index) {
                    return ChatMessageWidget(
                      message: messagesToShow[index],
                    );
                  },
                ),
              ),
              if (chatProvider.status == ChatStatus.loading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              if (chatProvider.status == ChatStatus.error)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    chatProvider.errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Color(0xFF343541)
                ),
                margin: EdgeInsets.only(bottom: 10, left: 1, right: 1, top: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        controller: controller,
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          filled: true,
                          hintText: 'Mesajınızı yazın...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.grey, width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ), 
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    InkWell(
                      onTap: () async {
                        if (controller.text.isNotEmpty) {
                          String text = controller.text;
                          controller.clear();
                          
                          final convProvider = Provider.of<ConversationProvider>(context, listen: false);
                          final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                          
                          // Yeni sohbet oluştur veya mevcut sohbete mesaj ekle
                          if (convProvider.currentConversationId == null) {
                            // Yeni sohbet
                            final id = await convProvider.createNewConversation(text);
                            print("Yeni sohbet oluşturuldu: ID=$id");
                            
                            // Yeni sohbetin başlatıldığını bildirmek için
                            setState(() {});
                            
                            // API isteği yap
                            chatProvider.sendPrompt(text);
                          } else {
                            // Mevcut sohbete mesaj ekle
                            final userMessage = ChatMessageModel(role: "user", content: text);
                            await convProvider.addMessageToCurrentConversation(userMessage);
                            print("Mevcut sohbete mesaj ekleniyor: $text");
                            
                            // API isteği yap
                            chatProvider.sendPrompt(text);
                          }
                        }
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildDrawer() {
    return Drawer(
      child: Consumer<ConversationProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Drawer Header
              Container(
                padding: EdgeInsets.only(top: 50, bottom: 20),
                color: AppColors.messageBgColor,
                width: double.infinity,
                child: Column(
                  children: [
                    Icon(Icons.chat, size: 50, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'Sohbet Geçmişi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Sohbet Modu Seçimi (Aktif/Arşiv)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black12,
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _showArchived = false;
                          });
                        },
                        child: Text(
                          'Aktif Sohbetler',
                          style: TextStyle(
                            color: !_showArchived ? Colors.blue : Colors.grey,
                            fontWeight: !_showArchived ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _showArchived = true;
                          });
                        },
                        child: Text(
                          'Arşiv',
                          style: TextStyle(
                            color: _showArchived ? Colors.blue : Colors.grey,
                            fontWeight: _showArchived ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Yeni Sohbet Butonu (Sadece aktif sohbetlerde göster)
              if (!_showArchived)
                ListTile(
                  leading: Icon(Icons.add_circle, color: Colors.green),
                  title: Text('Yeni Sohbet Başlat'),
                  onTap: () {
                    provider.clearCurrentConversation();
                    Provider.of<ChatProvider>(context, listen: false).cachedMessages.clear();
                    Provider.of<ChatProvider>(context, listen: false).notifyListeners();
                    Navigator.pop(context); // Drawer'ı kapat
                  },
                ),
              
              // Sohbet Listesi
              Expanded(
                child: _showArchived 
                    ? _buildConversationList(provider.archivedConversations, true)
                    : _buildConversationList(provider.activeConversations, false),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildConversationList(List<ConversationModel> conversations, bool isArchived) {
    if (conversations.isEmpty) {
      return Center(
        child: Text(
          isArchived ? 'Arşivlenmiş sohbet yok' : 'Henüz sohbet yok',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        final dateFormat = DateFormat('dd MMM, HH:mm');
        
        return Dismissible(
          key: Key(conversation.id.toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Sohbeti Sil'),
                content: Text('Bu sohbeti silmek istediğinize emin misiniz?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('İptal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Sil'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            Provider.of<ConversationProvider>(context, listen: false)
                .deleteConversation(conversation.id!);
          },
          child: ListTile(
            title: Text(
              conversation.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              dateFormat.format(conversation.updatedAt),
              style: TextStyle(fontSize: 12),
            ),
            leading: Icon(Icons.chat_bubble_outline),
            trailing: IconButton(
              icon: Icon(
                isArchived ? Icons.unarchive : Icons.archive,
                color: Colors.grey,
              ),
              onPressed: () {
                if (isArchived) {
                  Provider.of<ConversationProvider>(context, listen: false)
                      .unarchiveConversation(conversation.id!);
                } else {
                  Provider.of<ConversationProvider>(context, listen: false)
                      .archiveConversation(conversation.id!);
                }
              },
            ),
            onTap: () {
              Provider.of<ConversationProvider>(context, listen: false)
                  .loadConversation(conversation.id!);
              Navigator.pop(context); // Drawer'ı kapat
            },
          ),
        );
      },
    );
  }
}