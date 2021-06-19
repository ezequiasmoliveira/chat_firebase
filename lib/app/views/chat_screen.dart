import 'dart:io';

import 'package:chat/app/components/chat_message.dart';
import 'package:chat/app/components/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googlSignIn = GoogleSignIn();

  FirebaseAuth _auth;
  User _correntUser;

  @override
  void initState() {
    super.initState();
    initApp();

    _auth.authStateChanges().listen((user) {
      setState(() {
        _correntUser = user;
      });
    });
  }

  void initApp() async {
    FirebaseApp defaultApp = await Firebase.initializeApp();
    _auth = FirebaseAuth.instanceFor(app: defaultApp);
  }

  Future<User> _getUser() async {
    if (_correntUser != null) return _correntUser;

    try {
      // Trigger the Google Authentication flow.
      final GoogleSignInAccount signInAccount = await googlSignIn.signIn();
      // Obtain the auth details from the request.
      final GoogleSignInAuthentication authentication =
          await signInAccount.authentication;
      // Create a new credential.
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential].
      final UserCredential googleUserCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return googleUserCredential.user;
    } catch (error) {
      return null;
    }
  }

  void _sendMessage({String text, File imageFile}) async {
    final User user = await _getUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Não foi possivel fazer o login. Tente novamente!'"),
        backgroundColor: Colors.red,
      ));
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoURL
    };

    if (imageFile != null) {
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imageFile);
      var url = await task.snapshot.ref.getDownloadURL();
      data['imageUrl'] = url;
    }

    if (text != null) data['text'] = text;
    FirebaseFirestore.instance.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_correntUser != null
            ? 'Olá, ${_correntUser.displayName}'
            : 'Chat App'),
        centerTitle: true,
        elevation: 0,
        actions: [
          _correntUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    _auth.signOut();
                    googlSignIn.signOut();
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
            stream: FirebaseFirestore.instance
                .collection('messages')
                .orderBy('time')
                .snapshots(),
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
                        return ChatMessage(
                          data: docs[index].data(),
                          mine: true,
                        );
                      });
              }
            },
          )),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
