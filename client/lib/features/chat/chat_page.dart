import 'package:client/design/app_colors.dart';
import 'package:client/features/chat/bloc/chat_block.dart';
import 'package:client/features/chat/bloc/chat_event.dart';
import 'package:client/features/chat/bloc/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatBloc chatBloc = ChatBloc();
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatGPT"),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        bloc: chatBloc,
         listener: (BuildContext context, Object? state) {  },
        builder: (BuildContext context, state) { 
              return Container(
          child: Column(
            children: [
            Expanded(child: ListView.builder(
            padding: EdgeInsets.only(top: 12),
            itemCount: chatBloc.cachedMessages.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: chatBloc.cachedMessages[index].role == "assistant" ? AppColors.messageBgColor : Colors.transparent,
                ),
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.only(bottom: 8, left: 16, right: 16 , top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    chatBloc.cachedMessages[index].role == "user" ? const Icon(Icons.person) :  Icon(Icons.person_2_sharp),
                    Expanded(child: Text(chatBloc.cachedMessages[index].content , style: TextStyle(fontSize: 18),)),
                  ],
                ),
              
              );
            },),),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
                
              ),
              margin: EdgeInsets.only(bottom: 40,left: 16, right: 16, top: 6),
              child: Row(
                children: [
                  Expanded(child: TextField(
                    controller: controller,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide.none), filled: true,  ),
                  ),),
                  SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      if(controller.text.isNotEmpty){
                        String text = controller.text;
                        controller.clear();
                        chatBloc.add(ChatNewPromptEvent(prompt:text));
                      }
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    
                  ),),
                ],
              ),
            ),
          ],),
        );
         },
       
      
      ) ,
    );
  }
}