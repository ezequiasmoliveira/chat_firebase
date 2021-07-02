import 'dart:io';

import 'package:chat/app/components/chat_message.dart';
import 'package:chat/app/components/text_composer.dart';
import 'package:chat/app/controllers/message_controller.dart';
import 'package:chat/app/controllers/user_controller.dart';
import 'package:chat/app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  UserModel _userModel;
  MessageController _messageController;
  UserController _userController;
  bool _isLoading = false;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    initApp();
  }

  void initApp() async {
    _userController = UserController();
    _messageController = MessageController();
    _userModel = await _userController.getCorrentUser();
  }

  void _sendMessage({String text, File imageFile}) async {
    if (_userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Não foi possivel fazer o login. Tente novamente!"),
        backgroundColor: Colors.red,
      ));
    }

    _messageController.senderMessage(text, imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _userModel != null ? 'Olá, ${_userModel.displayName}' : 'Chat App'),
        centerTitle: true,
        elevation: 0,
        actions: [
          _userModel != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    _userController.logout();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Você saiu com sucesso!"),
                      backgroundColor: Colors.red,
                    ));
                  })
              : Container()
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: _messageController.getStreamMessages(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  List<DocumentSnapshot> docs =
                      snapshot.data.docs.reversed.toList();
                  return ListView.builder(
                      itemCount: docs.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data = docs[index].data();
                        return ChatMessage(
                          data: data,
                          mine: data['uid'] == _userModel?.uid,
                        );
                      });
              }
            },
          )),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
