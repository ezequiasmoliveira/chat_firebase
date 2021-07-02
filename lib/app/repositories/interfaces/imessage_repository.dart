import 'dart:io';

import 'package:chat/app/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IMessageRepository {
  List<MessageModel> getMessages();

  Stream<QuerySnapshot<Map<String, dynamic>>> getStreamMessages();

  void senderMessage(Map<String, dynamic> data);

  Future<String> uploadFile(File file);
}
