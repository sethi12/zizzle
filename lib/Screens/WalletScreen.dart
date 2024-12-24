import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/utils/utils.dart';
import '/widgets/text_feild_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/WalletScreenUi.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  var username; // Replace with your actual uid
  final TextEditingController UpiController = TextEditingController();
  double totalEarned = 0;
  String resu = "";
  var expirydate;
  bool max = false;
  @override
  void initState() {
    super.initState();
    getuid();
  }

  void getuid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
    print(DateTime.now());
    expirydate = DateTime.now().add(Duration(days: 30));
    print("Next Month = ${expirydate}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet"),
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection("reels").snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                totalEarned = 0; // Reset total each time data changes
                for (final reelData
                    in snapshot.data!.docs.map((doc) => doc.data())) {
                  if (reelData['username'] == username &&
                      reelData['Paid'] == "Not Paid" &&
                      reelData['views'] != null) {
                    totalEarned += reelData['views'] / 1000;
                    print("total = $totalEarned");
                    if (totalEarned > 300.0) {
                      totalEarned =
                          300.0; // Set it to the maximum limit if it exceeds 300.0
                      max = true;
                    }
                  }
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, index) {
                          final reelData = snapshot.data!.docs[index].data();
                          if (reelData['username'] == username &&
                              reelData['Paid'] == "Not Paid") {
                            return WalletScreenVideoUI(reelData: reelData);
                          } else {
                            // Return an empty container if the uid doesn't match
                            return Container();
                          }
                        },
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text("Total = ${totalEarned.toString()} CAD"),
                              max == true
                                  ? Text(
                                      "you have reached maximum limit",
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : SizedBox()
                            ],
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (totalEarned <= 50.0) {
                          showSnackBar(
                              "Minnimum withdrawl amount is 50 CAD", context);
                        } else {
                          if (totalEarned <= 300.0) {
                            setState(() {
                              totalEarned = 300.0;
                            });
                            totalEarned = 300.0;
                          }
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return SingleChildScrollView(
                                  child: Container(
                                    height: 300,
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(28.0),
                                          child: Text(
                                            "The current policy limits earnings to 300 CAD per month, fostering a structured approach. Future adjustments, including a potential increase to this limit, aim to accommodate both company sustainability and user satisfaction.",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: TextFeildInput(
                                              textInputType: TextInputType.text,
                                              textEditingController:
                                                  UpiController,
                                              hinttext: "Enter Your Upi Id "),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            if (UpiController.text.isEmpty) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                      backgroundColor: Colors
                                                          .black
                                                          .withOpacity(1.0),
                                                      child: ListView(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 16,
                                                                  horizontal:
                                                                      17),
                                                          shrinkWrap: true,
                                                          children: [
                                                            Text(
                                                                "Please Enter Your UPI ID")
                                                          ])));
                                            } else {
                                              print(UpiController.text);
                                              resu = await AddUpi();
                                              print(resu);
                                              if (resu == "Succses") {
                                                await FirebaseFirestore.instance
                                                    .collection("reels")
                                                    .where("username",
                                                        isEqualTo: username)
                                                    .get()
                                                    .then((QuerySnapshot
                                                        querySnapshot) {
                                                  querySnapshot.docs
                                                      .forEach((doc) {
                                                    // Update specific fields here
                                                    FirebaseFirestore.instance
                                                        .collection("reels")
                                                        .doc(doc.id)
                                                        .update({
                                                      "Paid": "Paid"
                                                      // Add more fields as needed
                                                    });
                                                  });
                                                });

                                                Navigator.of(context).pop();
                                              }
                                            }
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(top: 10),
                                            height: 40,
                                            color: Colors.blueAccent,
                                            width: double
                                                .infinity, // Set your desired color
                                            child: Center(
                                              child: Text(
                                                'Request Withdrawal',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        color: Colors.blueAccent,
                        width: double.infinity, // Set your desired color
                        child: Center(
                          child: Text(
                            'Request Withdrawal',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Row at the bottom
        ],
      ),
    );
  }

  Future<String> AddUpi() async {
    String res = "Some Error Occures";
    try {
      await FirebaseFirestore.instance
          .collection("Requests")
          .doc(username)
          .set({
        "username": username,
        "Amount": "CAD $totalEarned",
        "date of request": DateTime.now(),
        "status": "pending",
        "upi id": UpiController.text,
        "Expiry Date": expirydate
      });
      res = "Succses";
    } catch (e) {
      print(e.toString());
    }
    return res;
  }
}
