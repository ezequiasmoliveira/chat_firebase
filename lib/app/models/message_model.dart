import 'package:chat/app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final UserModel user;
  String text;
  String imageUrl;

  MessageModel(this.user, [this.text, this.imageUrl]);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'uid': this.user.uid,
      'senderName': this.user.displayName,
      'senderPhotoUrl': this.user.senderPhotoUrl,
      'time': Timestamp.now()
    };

    if (this.imageUrl != null) {
      data['imageUrl'];
    } else if (this.text != null) {
      data['text'];
    }

    return data;
  }
}
