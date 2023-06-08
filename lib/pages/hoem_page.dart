import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/components/drawer.dart';
import 'package:social_app/components/text_field.dart';
import 'package:social_app/components/wall_post.dart';
import 'package:social_app/helper/helper_methods.dart';
import 'package:social_app/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textcontroller = TextEditingController();
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    if (textcontroller.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("Users Posts").add({
        'UserEmail': currentUser.email,
        'Message': textcontroller.text,
        'TimeStamp': Timestamp.now(),
        'Likes': []
      });
    }

    setState(() {
      textcontroller.clear();
    });
  }

  void goToProfile() {
    Navigator.pop(context);

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(
        onProfile: goToProfile,
        onSignOut: signOut,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("                   The Wall"),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Users Posts")
                        .orderBy("TimeStamp", descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final post = snapshot.data!.docs[index];
                            return WallPost(
                              time: formatdata(post['TimeStamp']),
                              message: post['Message'],
                              user: post['UserEmail'],
                              postId: post.id,
                              likes: List<String>.from(post['Likes'] ?? []),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text("Error " + snapshot.error.toString()),
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    })),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                      child: MyTextFiled(
                          controller: textcontroller,
                          hintText: "Write something on the wall",
                          obscuretext: false)),
                  IconButton(
                      onPressed: postMessage, icon: Icon(Icons.arrow_circle_up))
                ],
              ),
            ),
            Text(
              "You are logged in as " + currentUser.email!,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
