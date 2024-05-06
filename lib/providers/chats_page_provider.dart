import 'dart:async';

//Packages
import 'package:fakir_chat/models/chat.dart';
import 'package:fakir_chat/models/chat_message.dart';
import 'package:fakir_chat/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/database_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
class ChatsPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;

  late DatabaseService _db;

  List<Chat>? chats;

  late StreamSubscription _chatsStream;
  late StreamSubscription _unreadCountStream;

  ChatsPageProvider(this._auth) {
    _db = GetIt.instance.get<DatabaseService>();
    getChats();
  }

  @override
  void dispose() {
    _chatsStream.cancel();
    super.dispose();
  }

  void getChats() async {
    try {
      _chatsStream =
          _db.getChatsForUser(_auth.user.uid).listen((_snapshot) async {
        chats = await Future.wait(
          _snapshot.docs.map(
            (_d) async {
              Map<String, dynamic> _chatData =
                  _d.data() as Map<String, dynamic>;
              // Get Users In Chat
              List<ChatUser> _members = [];
              for (var _uid in _chatData["members"]) {
                DocumentSnapshot _userSnapshot = await _db.getUser(_uid);
                Map<String, dynamic> _userData =
                    _userSnapshot.data() as Map<String, dynamic>;
                _userData["uid"] = _userSnapshot.id;
                _members.add(
                  ChatUser.fromJSON(_userData),
                );
              }
              // Get Last Message For Chat
              List<ChatMessage> _messages = [];
              QuerySnapshot _chatMessage =
                  await _db.getLastMessageForChat(_d.id);
              if (_chatMessage.docs.isNotEmpty) {
                Map<String, dynamic> _messageData =
                    _chatMessage.docs.first.data()! as Map<String, dynamic>;
                ChatMessage _message = ChatMessage.fromJSON(_messageData);
                _messages.add(_message);
              }
              // Listen for unread message count

              // Return Chat Instance
              return Chat(
                uid: _d.id,
                currentUserUid: _auth.user.uid,
                members: _members,
                messages: _messages,
                activity: _chatData["is_activity"],
                group: _chatData["is_group"],
              );
            },
          ).toList(),
        );
        // calculateUnreadMessagesCount();
        notifyListeners();
      });
    } catch (e) {
      print("Error getting chats.");
      print(e);
    }
  }

  Future<void> markMessagesAsRead(Chat chat) async {
    List<ChatMessage> unreadMessages = chat.messages
        .where(
            (message) => !message.isRead && message.senderID != _auth.user.uid)
        .toList();
    if (unreadMessages.isNotEmpty) {
      for (ChatMessage message in unreadMessages) {
        message.isRead = true;
        await _db.updateMessageReadStatus(chat.uid);
        await _db.updateUnreadMessageCount(chat.uid);
      }
    }
    //calculateUnreadMessagesCount(); // Update unread count after marking messages as read
    notifyListeners();
  }

  // Stream listener to listen for changes in unreadMessagesCount
  void listenToUnreadMessagesCount(String chatId) {
    _db.streamUnreadMessagesCount(chatId).listen((int count) {
      // Update the unreadMessagesCount property for the chat with the new value
      Chat? chat = chats?.firstWhere((chat) => chat.uid == chatId);
      if (chat != null) {
        chat.unreadMessagesCount = count;
        notifyListeners(); // Notify listeners to update the UI
      } else {
        print(
            'Chat with ID $chatId not found.'); // Handle the case where chat is not found
      }
    });
  }
}


  // void calculateUnreadMessagesCount() {
  //   if (chats != null) {
  //     for (Chat chat in chats!) {
  //       int unreadCount =
  //           chat.messages.where((message) => !message.isRead).length;
  //       _db.updateUnreadMessageCount(chat.uid);
  //     }
  //     notifyListeners();
  //   }
  // }
