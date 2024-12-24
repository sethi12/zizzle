import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '/model/message.dart';
import '/model/user.dart';
import '/services/auth_message_service.dart';
import '/services/database_service.dart';
import '/services/media_service.dart';
import '/services/storage_service.dart';
import 'dart:io';
import '../model/chat.dart';
import '../utils/utils.dart';

class ChatPage extends StatefulWidget {
  final User? chatuser;
  const ChatPage({super.key, required this.chatuser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late AuthService _authService;
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;
  ChatUser? currentuser, otheruser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    currentuser = ChatUser(
        id: _authService.getCurrentUser()!.uid,
        firstName: _authService.getCurrentUser()!.displayName);
    otheruser = ChatUser(
        id: widget.chatuser!.uid,
        firstName: widget.chatuser!.username,
        profileImage: widget.chatuser!.photourl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatuser!.username),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
        stream: _databaseService.getchatdata(currentuser!.id, otheruser!.id),
        builder: (context, snapshot) {
          Chat? chat = snapshot.data?.data();
          List<ChatMessage> messages = [];
          if (chat != null && chat.messages != null) {
            messages = _generateChatmessageslist(chat.messages!);
          }
          return DashChat(
              messageOptions: MessageOptions(
                  showOtherUsersAvatar: true,
                  showTime: true,
                  currentUserContainerColor: Colors.blue,
                  currentUserTextColor: Colors.white),
              inputOptions: InputOptions(
                  sendButtonBuilder: _buildSendButton,
                  autocorrect: true,
                  trailing: [_mediamessagebutton()],
                  inputTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.w500)),
              currentUser: currentuser!,
              onSend: _sendmessage,
              messages: messages);
        });
  }

  Widget _buildSendButton(void Function() onSend) {
    return IconButton(
      onPressed: onSend, // Use the provided onSend function to send the message
      icon: Icon(
        Icons.send,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  // Future<void> _sendmessage(ChatMessage chatMessage) async {
  //   if (chatMessage.medias?.isNotEmpty ?? false) {
  //     if (chatMessage.medias!.first.type == MediaType.image) {
  //       Message message = Message(
  //           senderid: chatMessage.user.id,
  //           content: chatMessage.medias!.first.url,
  //           messagetype: Messagetype.Image,
  //           sentat: Timestamp.fromDate(chatMessage.createdAt));
  //       await _databaseService.sendchatmessages(
  //           currentuser!.id, otheruser!.id, message);
  //     }
  //   } else {
  //     Message message = Message(
  //         senderid: currentuser!.id,
  //         content: chatMessage.text,
  //         messagetype: Messagetype.Text,
  //         sentat: Timestamp.fromDate(chatMessage.createdAt));
  //     await _databaseService.sendchatmessages(
  //         currentuser!.id, otheruser!.id, message);
  //   }
  // }
  Future<void> _sendmessage(ChatMessage chatMessage) async {
    String messageContent = '';
    Messagetype messageType;

    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        messageContent = '📷 Image';
        messageType = Messagetype.Image;
        Message message = Message(
          senderid: chatMessage.user.id,
          content: chatMessage.medias!.first.url,
          messagetype: messageType,
          sentat: Timestamp.fromDate(chatMessage.createdAt),
          lastmessage: messageContent,
        );
        await _databaseService.sendchatmessages(
            currentuser!.id, otheruser!.id, message);
      }
    } else {
      messageContent = chatMessage.text;
      messageType = Messagetype.Text;
      Message message = Message(
        senderid: currentuser!.id,
        content: messageContent,
        messagetype: messageType,
        sentat: Timestamp.fromDate(chatMessage.createdAt),
        lastmessage: messageContent,
      );
      await _databaseService.sendchatmessages(
          currentuser!.id, otheruser!.id, message);
    }

    // Update the chat document with the last message
    await _databaseService.updateChatLastMessage(
      currentuser!.id,
      otheruser!.id,
      messageContent,
      Timestamp.now(),
    );
  }

  List<ChatMessage> _generateChatmessageslist(List<Message> messages) {
    List<ChatMessage> chatmessages = messages.map((e) {
      if (e.messagetype == Messagetype.Image) {
        return ChatMessage(
            user: e.senderid == currentuser!.id ? currentuser! : otheruser!,
            createdAt: e.sentat!.toDate(),
            medias: [
              ChatMedia(url: e.content!, fileName: "", type: MediaType.image)
            ]);
      } else {
        return ChatMessage(
            user: e.senderid == currentuser!.id ? currentuser! : otheruser!,
            createdAt: e.sentat!.toDate(),
            text: e.content!);
      }
    }).toList();
    chatmessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatmessages;
  }

  Widget _mediamessagebutton() {
    return IconButton(
        onPressed: () async {
          File? file = await _mediaService.getimagefromgallery();
          if (file != null) {
            String chatid =
                generatechatid(uid1: currentuser!.id, uid2: otheruser!.id);
            String? downloadurl = await _storageService.uploadimagetochat(
                file: file, chatid: chatid);
            if (downloadurl != null) {
              ChatMessage chatMessage = ChatMessage(
                  user: currentuser!,
                  createdAt: DateTime.now(),
                  medias: [
                    ChatMedia(
                        url: downloadurl, fileName: "", type: MediaType.image)
                  ]);
              _sendmessage(chatMessage);
            }
          }
        },
        icon: Icon(
          Icons.image,
          color: Theme.of(context).colorScheme.primary,
        ));
  }
}
