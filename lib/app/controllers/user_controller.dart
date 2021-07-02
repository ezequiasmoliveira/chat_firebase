import 'package:chat/app/models/user_model.dart';
import 'package:chat/app/repositories/interfaces/iuser_repository.dart';
import 'package:chat/app/repositories/user_repository.dart';

class UserController {
  IUserRepository repository;

  UserController() {
    repository = UserRepository();
  }

  Future<UserModel> getCorrentUser() async {
    return await repository.getCurrentUser();
  }

  void logout() {
    repository.logout();
  }
}
