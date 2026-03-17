import 'dart:io';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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
        trailing: [IconButton(onPressed: _sendMedia, icon: Icon(Icons.image))],
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
      List<Content> history = Messages.reversed.map((e) {
        if (e.medias != null) {
          for (var media in e.medias!) {
            Part.bytes(File(media.url).readAsBytesSync());
          }
        }
        return Content(
          parts: [Part.text(e.text)],
          role: e.user.id == '0' ? 'user' : 'model',
        );
      }).toList();
      gemini.streamChat(history).listen((value) {
        String chunk = value.output ?? "";
        setState(() {
          if (Messages.isNotEmpty && Messages.first.user == geminiUser.id) {
            Messages[0] = ChatMessage(
              user: geminiUser,
              createdAt: DateTime.now(),
              text: Messages.first.text + chunk,
            );
          } else {
            ChatMessage response = ChatMessage(
              user: geminiUser,
              createdAt: DateTime.now(),
              text: chunk,
            );
            Messages = [response, ...Messages];
          }
        });
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void _sendMedia() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: 'Describe this image',
        medias: [
          ChatMedia(url: file.path, fileName: '', type: MediaType.image),
        ],
      );
      _sendMessage(chatMessage);
    }
  }
}
