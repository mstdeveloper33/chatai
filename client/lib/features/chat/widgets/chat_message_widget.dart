import 'package:client/design/app_colors.dart';
import 'package:client/features/chat/models/chat_message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessageModel message;
  
  const ChatMessageWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: message.role == "assistant" 
            ? AppColors.messageBgColor 
            : Colors.transparent,
      ),
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.only(bottom: 12, left: 0, right: 0, top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 2.0, left: 2.0),
            child: message.role == "user" 
                ? const Icon(Icons.person) 
                : Icon(Icons.person_2_sharp),
          ),
          Expanded(
            child: _buildMessageContent(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageContent(BuildContext context) {
    if (message.role == "user") {
      // Kullanıcı mesajları için düz metin
      return Text(
        message.content, 
        style: TextStyle(fontSize: 16),
      );
    } else {
      // Asistan mesajları için markdown desteği
      return Markdown(
        data: message.content,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(fontSize: 16, color: Colors.white),
          h1: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          h3: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          code: TextStyle(
            backgroundColor: Colors.black38,
            color: Colors.white,
            fontFamily: 'monospace',
          ),
          codeblockPadding: EdgeInsets.all(12),
          codeblockDecoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(8),
          ),
          blockSpacing: 16.0, // Bloklar arası boşluğu arttır
          listIndent: 24.0, // Liste girintilerini arttır
          tableColumnWidth: FlexColumnWidth(1.0), // Tablo sütunlarını genişlet
          textAlign: WrapAlignment.start, // Metni sola hizala
          h1Align: WrapAlignment.start, // Başlıkları sola hizala
          h2Align: WrapAlignment.start,
          h3Align: WrapAlignment.start,
          tableCellsPadding: EdgeInsets.all(4.0), // Tablo hücrelerinin iç boşluğunu arttır
          tableBorder: TableBorder.all(color: Colors.grey.shade700), // Tablo kenarlıklarını belirgin yap
        ),
        extensionSet: md.ExtensionSet(
          md.ExtensionSet.gitHubFlavored.blockSyntaxes,
          [md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
        ),
        builders: {
          'code': CodeBlockBuilder(),
        },
      );
    }
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String language = '';
    String code = element.textContent;
    
    // Dil bilgisini al
    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      if (lg.startsWith('language-')) {
        language = lg.substring(9);
      }
    }
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black38,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    language,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Kod kopyalama butonu
                  InkWell(
                    onTap: () {
                      // Kodu panoya kopyala
                      Clipboard.setData(ClipboardData(text: code)).then((_) {
                        // Başarılı kopyalama mesajı gösterilebilir
                      });
                    },
                    child: Icon(
                      Icons.copy,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            
            padding: EdgeInsets.all(0),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xff282c34),
                borderRadius: language.isNotEmpty 
                    ? BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      )
                    : BorderRadius.circular(8),
              ),
              width: 600, // Geniş kod bloğu
              child: HighlightView(
                code,
                language: language.isNotEmpty ? language : 'plaintext',
                theme: atomOneDarkTheme,
                textStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 