import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreUpdater {
  static bool isGlobalOptionEnabled = false;
  static Timer? globalOptionTimer;

  void enableGlobalOption(String docId) {
    isGlobalOptionEnabled = true;

    updateFirestore(docId); // Update Firestore when global option is enabled

    // Set a timer to disable the global option after 15 minutes
    globalOptionTimer = Timer(Duration(minutes: 15), () {
      disableGlobalOption(docId);
    });
  }

  void disableGlobalOption(String docId) {
    isGlobalOptionEnabled = false;
    if (globalOptionTimer != null && globalOptionTimer!.isActive) {
      globalOptionTimer!.cancel(); // Cancel the timer if active
    }
    updateFirestore(docId); // Update Firestore when global option is disabled
  }


  void updateFirestore(String docId) {
    FirebaseFirestore.instance.collection('Posts').doc(docId).update({
      'isGlobalOptionEnabled': isGlobalOptionEnabled,
    }).then((value) {
      print("Firestore updated successfully");
    }).catchError((error) {
      print("Error updating Firestore: $error");
    });
  }
  Future<void> updateGlobalOptionStatusForUser() async {
    final prefs = await SharedPreferences.getInstance();
   var username = prefs.getString('username');
    CollectionReference postsCollection = FirebaseFirestore.instance.collection('Posts');

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        QuerySnapshot querySnapshott = await postsCollection.where('username', isEqualTo: username).get();

        for (QueryDocumentSnapshot docSnapshot in querySnapshott.docs) {
          transaction.update(postsCollection.doc(docSnapshot.id), {'isGlobalOptionEnabled': false});
        }
      });

      print("Successfully updated documents for user: $username");
    } catch (e) {
      print("Error updating documents: $e");
    }
  }

}