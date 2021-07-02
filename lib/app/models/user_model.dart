class UserModel {
  final String uid;
  final String displayName;
  final String senderPhotoUrl;

  UserModel({this.uid, this.displayName, this.senderPhotoUrl});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'uid': this.uid,
      'senderName': this.displayName,
      'senderPhotoUrl': this.senderPhotoUrl,
    };

    return data;
  }
}
