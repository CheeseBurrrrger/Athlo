import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());
class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
  static bool isInitialize = false;

  Future<void> initSignIn() async {
    if (!isInitialize){
      await _googleSignIn.initialize(
          serverClientId: "1077690826514-mso0hr42ikk2lgf70flue3jmmgmra9d4.apps.googleusercontent.com"
      );
    }
  }
  Future<UserCredential> signIn({
    required String email,
    required String password,
}) async {
    return await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }
  Future<UserCredential> googleSignIn() async {
  try{
    initSignIn();
    final GoogleSignInAccount googleSignInAccount = await _googleSignIn.authenticate();
    final idToken = googleSignInAccount.authentication.idToken;
    final authorizationClient = googleSignInAccount.authorizationClient;
    GoogleSignInClientAuthorization? authorization = await authorizationClient.authorizationForScopes(['email','profile']);
    final accessToken = authorization?.accessToken;
    if (accessToken==null){
      final authorization = await authorizationClient.authorizationForScopes(['email','profile'],);
      if (authorization!.accessToken == null){
        throw FirebaseAuthException(code: "error", message: "error");
      }
    }
    final credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: idToken,
    );
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = userCredential.user;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
    return userCredential;
  }catch(e){
    print(e.toString());
    rethrow;
  }
}
  Future<UserCredential> createAccount({
  required String email,
  required String password,
  }) async{
    return await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }
  Future<void>signOut() async{
    await firebaseAuth.signOut();
  }
  Future<void>resetPassword({
    required String email,
}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }
  Future<void> updateUsername({
    required String username,
}) async{
    await currentUser!.updateDisplayName(username);
  }
  Future<void>deleteAccount({
    required String email,
    required String password,
}) async{
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
  }
  Future<void>resetCurretPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
}) async{
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPassword);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }
}
