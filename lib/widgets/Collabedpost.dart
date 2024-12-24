import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class Collabedpost extends StatelessWidget {
  final snap;
  const Collabedpost({super.key,required this.snap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
               backgroundImage: NetworkImage(snap['profimage']),
                radius: 22,
              ),
              SizedBox(width: 20,),
              Align(
                alignment: Alignment.topLeft,
                  child: Text(snap['username'],style: TextStyle(fontSize: 19),)),
            ],
          ),
          SizedBox(height: 13,),
          Image.network(snap['posturl'])
          , Align(
        alignment: Alignment.topLeft,
        child: Text("${snap['username']} wants to Collaborate with you ${snap['collabusername']}",style: TextStyle(fontSize: 17,color: Colors.white60),)),
          Row(
            children: [
              TextButton(onPressed:(){
              print(snap['postid']);
              FirebaseFirestore.instance.collection("Posts").doc(snap['postid']).update({
                "collabreqacc":true
              });
              FirebaseFirestore.instance.collection("CollabRequests").doc(snap['postid']).delete();
              }, child:Text("Accept")),
              TextButton(onPressed:(){
                FirebaseFirestore.instance.collection("CollabRequests").doc(snap['postid']).delete();
              }, child:Text("Decline")),
            ],
          )
        ],
      ),
    );
  }
}
