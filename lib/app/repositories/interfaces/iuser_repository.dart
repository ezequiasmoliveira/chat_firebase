import 'package:chat/app/models/user_model.dart';

abstract class IUserRepository {
  UserModel login();

  void logout();

  Future<UserModel> getCurrentUser();
}
