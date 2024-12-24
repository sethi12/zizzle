import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/Controllers/comment_controller.dart';
import 'package:timeago/timeago.dart' as tago;

class CommentReelScreen extends StatelessWidget {
  final String id;
  CommentReelScreen({super.key, required this.id});
  final TextEditingController _commmentcontroller = TextEditingController();
  CommentController commentController = Get.put(CommentController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    commentController.updatepostid(id);
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Column(
            children: [
              Expanded(child: Obx(() {
                return ListView.builder(
                  itemCount: commentController.comments.length,
                  itemBuilder: (context, index) {
                    final comment = commentController.comments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black,
                        backgroundImage: NetworkImage(comment.profilephoto),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                              text: comment.username,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.red),
                            ),
                            TextSpan(
                              text: '  ${comment.comment}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ])),
                          // Text(
                          //   '${comment.username} ',
                          //   style: const TextStyle(
                          //     fontSize: 20,
                          //     color: Colors.red,
                          //     fontWeight: FontWeight.w700,
                          //   ),
                          // ),
                          // Flexible(
                          //   child: Text(
                          //     comment.comment,
                          //     style: const TextStyle(
                          //       fontSize: 12,
                          //       color: Colors.white,
                          //       fontWeight: FontWeight.w500,
                          //     ),
                          //     overflow: TextOverflow.ellipsis,
                          //     softWrap: true,
                          //   ),
                          // ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            tago.format(comment.datepublished.toDate()),
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${comment.likes.length} likes',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                      trailing: InkWell(
                        onTap: () => commentController.likecomment(
                            comment.id, comment.username),
                        child: Icon(
                          Icons.favorite,
                          size: 25,
                          color: comment.likes.contains(comment.username)
                              ? Colors.red
                              : Colors.white,
                        ),
                      ),
                    );
                  },
                );
              })),
              const Divider(),
              ListTile(
                title: TextFormField(
                  controller: _commmentcontroller,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                      labelText: 'Comment',
                      labelStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      )),
                ),
                trailing: TextButton(
                  onPressed: () {
                    commentController.postcomment(_commmentcontroller.text);
                    _commmentcontroller.text = "";
                  },
                  child: const Text(
                    'Post',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
