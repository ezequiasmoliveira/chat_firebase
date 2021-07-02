import 'dart:io';

import 'package:chat/app/models/message_model.dart';
import 'package:chat/app/repositories/interfaces/imessage_repository.dart';
import 'package:chat/app/repositories/interfaces/iuser_repository.dart';
import 'package:chat/app/repositories/message_repository.dart';
import 'package:chat/app/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageController {
  IMessageRepository _repository;
  IUserRepository _userRepository;

  MessageController() {
    _repository = MessageRepository();
    _userRepository = UserRepository();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStreamMessages() {
    return _repository.getStreamMessages();
  }

  Future<void> senderMessage([String text, File imageFile]) async {
    var message = MessageModel(await _userRepository.getCurrentUser());

    if (imageFile != null) {
      message.imageUrl = await _repository.uploadFile(imageFile);
    } else if (text != null) {
      message.text = text;
    }

    _repository.senderMessage(message.toMap());
  }
}
