import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scrool2grow/features/home/model/HomeModel.dart';

class HomeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<HomeModel> getHomeData() async {
    // Get the currently logged-in Firebase user.
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception('No user is currently logged in.');
    }

    // Retrieve the document belonging to this user's UID.
    final document = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!document.exists) {
      throw Exception('User profile not found in Firestore.');
    }

    final data = document.data();

    if (data == null) {
      throw Exception('Unable to retrieve user profile.');
    }

    // Convert Firestore data into our model.
    return HomeModel.fromMap(
      firebaseUser.uid,
      data,
    );
  }
}