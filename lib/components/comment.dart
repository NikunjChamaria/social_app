import 'package:flutter/material.dart';

class Comment1 extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  const Comment1(
      {super.key, required this.text, required this.user, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text),
          Row(
            children: [
              Text(
                user,
                style: TextStyle(color: Colors.grey[400]),
              ),
              Text(" . ", style: TextStyle(color: Colors.grey[400]))
            ],
          ),
          Text(time, style: TextStyle(color: Colors.grey[400]))
        ],
      ),
    );
  }
}
