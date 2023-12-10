import 'dart:io';

import 'package:chat_app/widget/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chat")
          // ensure lates message is bottom
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionTask) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          // if snapshot has no data and docs of collection is empty
          return const Center(
            child: Text("No messages found"),
          );
        }

        if (chatSnapshot.hasError) {
          return const Center(
            child: Text("Something went wrong..."),
          );
        }

        final loadedMessages = chatSnapshot.data!.docs;

        return ListView.builder(
            padding: const EdgeInsets.only(bottom: 40, right: 13, left: 13),
            itemCount: loadedMessages.length,
            reverse: true, // first item is last item on list using this
            itemBuilder: (ctx, index) {
              final chatMessage = loadedMessages[index].data();
              // print("list index: $index");
              // print("list index: $chatMessage");
              // if there is a next message get the next chatMessage else return null
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;

              final currentMessageUserId = chatMessage["userId"];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage["userId"] : null;
              final nextUserIsSame = nextMessageUserId == currentMessageUserId;

              if (nextUserIsSame) {
                return MessageBubble.next(
                  message: chatMessage["text"],
                  isMe: authenticatedUser.uid == currentMessageUserId,
                );
              } else {
                return MessageBubble.first(
                  userImage: chatMessage["userImage"],
                  username: chatMessage["username"],
                  message: chatMessage["text"],
                  isMe: authenticatedUser.uid == currentMessageUserId,
                );
              }
            });
      },
    );
  }
}
