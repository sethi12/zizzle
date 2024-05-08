import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newapp/Screens/Add_post_screen_details.dart';
import 'package:newapp/Screens/profile_screen.dart';

import '../utils/colors.dart';
import '../widgets/CircleTickIconSearch.dart';
class CollabScreen extends StatefulWidget {
  const CollabScreen({super.key});
  @override
  State<CollabScreen> createState() => _CollabScreenState();
}

class _CollabScreenState extends State<CollabScreen> {
  final TextEditingController searchController = TextEditingController();
  var isMonetized;
 static var collabusername;
    @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: TextFormField(
          controller: searchController,
          decoration: InputDecoration(labelText: "Search for user"),
      onFieldSubmitted: (String s) {
      print(searchController.text);

      },
      ),
      ),
      body:FutureBuilder(
      future: getUsers(searchController.text),
      builder: (context, snapshot) {
      if (!snapshot.hasData) {
      return const Center(
      child: CircularProgressIndicator(),
      );
      }
      return ListView.builder(
      itemCount: (snapshot.data! as dynamic).docs.length,
      itemBuilder: (context, index) {
      isMonetized = (snapshot.data! as dynamic).docs[index]['Monetization'];
      print(isMonetized);
      return InkWell(
      onTap: () {
      collabusername =(snapshot.data as dynamic).docs[index]['username'];
      print(collabusername);
      Navigator.of(context).pop(collabusername);



      },
      child: ListTile(
      leading: CircleAvatar(
      backgroundImage: NetworkImage((snapshot.data! as dynamic).docs[index]['photourl']),
      ),
      title: Row(
      children: [
      Text((snapshot.data! as dynamic).docs[index]['username']),
      const SizedBox(),
      isMonetized == "Monitized" ? CircleTickIconSearch() : const SizedBox(),
      ],
      ),
      ),
      );
      },
      );
      },
      )
      );
  }
  Future<QuerySnapshot?> getUsers(String searchTerm) async {
    try {
      return await FirebaseFirestore.instance.collection("users").where('username', isGreaterThanOrEqualTo: searchTerm).get();
    } catch (error) {
      print("Error fetching users: $error");
      // Handle the error as needed, e.g., log it or show a message to the user.
      return null; // Return null or another appropriate value indicating an error.
    }
  }
}
