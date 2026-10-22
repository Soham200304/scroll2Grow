import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scrool2grow/features/auth/models/UserModel.dart';


class SignUpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Listen to login/logout state
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  Future<UserModel> signup ({
    required String name,
    required String email,
    required String password,
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    final User? firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Unable to create account');
    }

    final user = UserModel(
      uid: firebaseUser.uid,
      name: name.trim(),
      email: email.trim(),
      createdAt: DateTime.now(),
    );

    //save user to firestore
    await _firestore.collection('users').doc(firebaseUser.uid).set(user.toMap());

    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final UserCredential userCredential =
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final User? firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      throw Exception('Unable to login.');
    }

    // Get the user's profile from Firestore
    final document = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!document.exists) {
      throw Exception('User profile not found.');
    }

    return UserModel.fromMap(document.data()!);
  }
}