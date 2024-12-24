import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreReelUpdater {
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
    FirebaseFirestore.instance.collection('reels').doc(docId).update({
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
    CollectionReference reelsCollection = FirebaseFirestore.instance.collection('reels');

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        QuerySnapshot querySnapshott = await reelsCollection.where('username', isEqualTo: username).get();

        for (QueryDocumentSnapshot docSnapshot in querySnapshott.docs) {
          transaction.update(reelsCollection.doc(docSnapshot.id), {'isGlobalOptionEnabled': false});
        }
      });

      print("Successfully updated documents for user: $username");
    } catch (e) {
      print("Error updating documents: $e");
    }
  }

}