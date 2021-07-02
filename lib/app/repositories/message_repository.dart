import 'dart:io';

import 'package:chat/app/models/message_model.dart';
import 'package:chat/app/models/user_model.dart';
import 'package:chat/app/repositories/interfaces/imessage_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MessageRepository implements IMessageRepository {
  static const String messagesCollection = 'messages';
  static const String time = 'time';

  UserModel _userModel;

  MessageRepository() {
    _userModel = UserModel();
  }

  @override
  List<MessageModel> getMessages() {
    // TODO: implement getMessages
    throw UnimplementedError();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getStreamMessages() {
    Firebase.initializeApp();
    return FirebaseFirestore.instance
        .collection(messagesCollection)
        .orderBy(time)
        .snapshots();
  }

  @override
  Future<void> senderMessage(Map<String, dynamic> data) async {
    FirebaseFirestore.instance.collection(messagesCollection).add(data);
  }

  @override
  Future<String> uploadFile(File file) async {
    UploadTask task = FirebaseStorage.instance
        .ref()
        .child(
            _userModel.uid + DateTime.now().millisecondsSinceEpoch.toString())
        .putFile(file);

    return await task.snapshot.ref.getDownloadURL();
  }
}
