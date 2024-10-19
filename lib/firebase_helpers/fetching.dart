import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FetchingData {
  Future<String?> getacctype() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('passengers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (doc.exists) {
      return doc['type'] as String?;
    } else {
      return null; 
    }
  }

  Future<String?> getemail() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('passengers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (doc.exists) {
      return doc['email'] as String?;
    } else {
      return null; 
    }
  }
}
