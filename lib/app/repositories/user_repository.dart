import 'package:chat/app/models/user_model.dart';
import 'package:chat/app/repositories/interfaces/iuser_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserRepository implements IUserRepository {
  User _correntUser;
  FirebaseAuth _firebaseAuth;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  UserRepository() {
    _init();
  }

  Future _init() async {
    FirebaseApp defaultApp = await Firebase.initializeApp();
    _firebaseAuth = FirebaseAuth.instanceFor(app: defaultApp);

    _firebaseAuth.authStateChanges().listen((user) {
      _correntUser = user;
    });
  }

  @override
  UserModel login() {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  void logout() {
    _firebaseAuth.signOut();
    _googleSignIn.signOut();
  }

  @override
  Future<UserModel> getCurrentUser() async {
    if (_correntUser != null) return _getCorrentUser(_correntUser);

    try {
      // Trigger the Google Authentication flow.
      final GoogleSignInAccount signInAccount = await _googleSignIn.signIn();
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

      return _getCorrentUser(googleUserCredential.user);
    } catch (error) {
      return null;
    }
  }

  UserModel _getCorrentUser(User user) {
    return UserModel(
        uid: user.uid,
        displayName: user.displayName,
        senderPhotoUrl: user.photoURL);
  }
}
