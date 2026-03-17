import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> Messages = [];
  ChatUser currentUser = ChatUser(id: '0', firstName: 'User');
  ChatUser geminiUser = ChatUser(
    id: '1',
    firstName: 'Gemini',
    profileImage:
        'https://images.seeklogo.com/logo-png/62/1/google-gemini-icon-logo-png_seeklogo-623016.png',
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Gemini Chat',
          style: GoogleFonts.poppins(color: Colors.black),
        ),
      ),
      body: _BuildUI(),
    );
  }

  Widget _BuildUI() {
    return DashChat(
      inputOptions: InputOptions(
        trailing: [IconButton(onPressed: () {}, icon: Icon(Icons.image))],
      ),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: Messages,
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      Messages = [chatMessage, ...Messages];
    });
    try {
      List<Content> history = Messages.reversed
          .map(
            (e) => Content(
              parts: [Part.text(e.text)],
              role: e.user.id == '0' ? 'user' : 'model',
            ),
          )
          .toList();
      gemini.streamChat(history).listen((value) {
        String responseChunk = value.output ?? "";
        setState(() {
          if (Messages.isNotEmpty && Messages.first.user.id == geminiUser.id) {
            Messages[0] = ChatMessage(
              user: geminiUser,
              createdAt: DateTime.now(),
              text: Messages.first.text + responseChunk,
            );
          } else {
            ChatMessage response = ChatMessage(
              user: geminiUser,
              createdAt: DateTime.now(),
              text: responseChunk,
            );
            Messages = [response, ...Messages];
          }
        });
      });
    } catch (e) {
      print(e);
    }
  }
}
