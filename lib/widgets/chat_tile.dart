import 'package:flutter/material.dart';
import '../model/user.dart';

class ChatTile extends StatelessWidget {
  final User user;
  final Function ontap;
  final List<String> chatIds;
  final String? senderid;
  final String? lastMessage;

  const ChatTile(
      {Key? key,
      required this.user,
      required this.ontap,
      required this.chatIds,
      this.lastMessage,
      this.senderid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        ontap();
      },
      dense: false,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.photourl),
      ),
      title: Text(user.username),
      subtitle: lastMessage != null
          ? Row(
              children: [
                // Text(
                //   "${senderid}", // Example timestamp
                //   style: TextStyle(fontSize: 12, color: Colors.grey),
                // ),
                Expanded(
                  child: Text(
                    lastMessage!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                // Icon(Icons.check, size: 16, color: Colors.grey), // Example icon
              ],
            )
          : null,
    );
  }
}
