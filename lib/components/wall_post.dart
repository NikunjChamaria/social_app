import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/components/comment.dart';
import 'package:social_app/components/comment_button.dart';
import 'package:social_app/components/delete_button.dart';
import 'package:social_app/components/like_button.dart';
import 'package:social_app/helper/helper_methods.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final String time;
  final List<String> likes;
  //final String time;
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLikes() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('Users Posts').doc(widget.postId);

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection("Users Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now()
    });
  }

  void showCommentDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Add Comment"),
              content: TextField(
                controller: _commentTextController,
                decoration: InputDecoration(hintText: "Write a comment"),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _commentTextController.clear();
                    },
                    child: Text("Cancel")),
                TextButton(
                    onPressed: () {
                      addComment(_commentTextController.text);
                      Navigator.pop(context);
                      _commentTextController.clear();
                    },
                    child: Text("Post")),
              ],
            ));
  }

  void deletepost() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete Post"),
              content:
                  const Text("Are you sure you want ot delete this post??"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () async {
                      final commentDocs = await FirebaseFirestore.instance
                          .collection("Users Posts")
                          .doc(widget.postId)
                          .collection("Comments")
                          .get();

                      for (var doc in commentDocs.docs) {
                        await FirebaseFirestore.instance
                            .collection("Users Posts")
                            .doc(widget.postId)
                            .collection("Comments")
                            .doc(doc.id)
                            .delete();
                      }

                      FirebaseFirestore.instance
                          .collection("Users Posts")
                          .doc(widget.postId)
                          .delete()
                          .then((value) => print("post deleted"))
                          .catchError((error) => print(error.toString()));

                      Navigator.pop(context);
                    },
                    child: const Text("Delete"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.message),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        widget.user,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(" . ", style: TextStyle(color: Colors.grey[400]))
                    ],
                  ),
                  Text(widget.time, style: TextStyle(color: Colors.grey[400]))
                ],
              ),
              if (widget.user == currentUser.email)
                DeleteButton(onTap: deletepost)
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  LikeButton(isLiked: isLiked, onTap: toggleLikes),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  CommentButton(onTap: showCommentDialog),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "0",
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(("Users Posts"))
                  .doc(widget.postId)
                  .collection("Comments")
                  .orderBy("CommentTime", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc) {
                    final commentData = doc.data() as Map<String, dynamic>;
                    return Comment1(
                        text: commentData["CommentText"],
                        user: commentData["CommentedBy"],
                        time: formatdata(commentData["CommentTime"]));
                  }).toList(),
                );
              })
        ],
      ),
    );
  }
}
