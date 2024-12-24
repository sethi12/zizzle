import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '/Screens/chat_screen.dart';
import '/services/alert_service.dart';
import '/services/auth_message_service.dart';
import '/services/database_service.dart';
import '/services/navigation_service.dart';
import '/utils/colors.dart';
import '../model/user.dart';
import '../widgets/chat_tile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late Navigationservice _navigationservice;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationservice = _getIt.get<Navigationservice>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  Future<Map<String, String?>> getChatIdsAndLastMessages() async {
    final String? myUid = _authService.getCurrentUser()?.uid;
    if (myUid == null) {
      print("User is not logged in");
      return {};
    }

    final QuerySnapshot chatSnapshot = await FirebaseFirestore.instance
        .collection("chats")
        .where("participants", arrayContains: myUid)
        .get();

    final Map<String, String?> chatData = {};
    for (var doc in chatSnapshot.docs) {
      final chatId = doc.id;
      final lastMessage = doc.data() as Map<String, dynamic>?;
      chatData[chatId] = lastMessage?['lastmessage'] as String?;
    }

    print("Chat Data: $chatData");
    return chatData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: mobileBackgroundColor,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: _chatsList(),
      ),
    );
  }

  Widget _chatsList() {
    return StreamBuilder<List<User>>(
      stream: _databaseService.getFollowingUsersStream(),
      builder: (context, AsyncSnapshot<List<User>> userSnapshot) {
        if (userSnapshot.hasError) {
          print("Snapshot has error: ${userSnapshot.error}");
          return Center(child: Text("Unable to load data"));
        }
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final combinedUsersList = userSnapshot.data;
        if (combinedUsersList != null && combinedUsersList.isNotEmpty) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("chats")
                .where("participants",
                    arrayContains: _authService.getCurrentUser()?.uid)
                .snapshots(),
            builder: (context, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (chatSnapshot.hasError) {
                print("Chat Snapshot error: ${chatSnapshot.error}");
                return Text("Error loading chat data");
              } else {
                final chatDocs = chatSnapshot.data?.docs ?? [];
                final chatData = {
                  for (var doc in chatDocs)
                    doc.id: (doc.data() as Map<String, dynamic>)['lastmessage']
                        as String?
                };

                return ListView.builder(
                  itemCount: combinedUsersList.length,
                  itemBuilder: (context, index) {
                    final user = combinedUsersList[index];
                    final chatId = chatData.keys.firstWhere(
                        (id) => chatData[id] != null && id.contains(user.uid),
                        orElse: () => '');
                    final lastMessage = chatData[chatId];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7.0),
                      child: ChatTile(
                        user: user,
                        senderid: user.uid,
                        ontap: () async {
                          final chatexists =
                              await _databaseService.checkchatexists(
                            _authService.getCurrentUser()!.uid,
                            user.uid,
                          );
                          if (!chatexists) {
                            await _databaseService.createchats(
                              _authService.getCurrentUser()!.uid,
                              user.uid,
                            );
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatPage(chatuser: user),
                            ),
                          );
                        },
                        chatIds: chatData.keys.toList(),
                        lastMessage: lastMessage,
                      ),
                    );
                  },
                );
              }
            },
          );
        } else {
          return Center(child: Text("No users found"));
        }
      },
    );
  }
}
