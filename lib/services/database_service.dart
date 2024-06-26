//Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fakir_chat/models/chat_message.dart';
import 'package:flutter/material.dart';

const String USER_COLLECTION = "Users";
const String CHAT_COLLECTION = "Chats";
const String MESSAGES_COLLECTION = "messages";

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService() {}

  Future<void> createUser(
      String _uid, String _email, String _name, String _imageURL) async {
    try {
      await _db.collection(USER_COLLECTION).doc(_uid).set(
        {
          "email": _email,
          "image": _imageURL,
          "last_active": DateTime.now().toUtc(),
          "name": _name,
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<DocumentSnapshot> getUser(String _uid) {
    return _db.collection(USER_COLLECTION).doc(_uid).get();
  }

  Future<QuerySnapshot> getUsers({String? name}) {
    Query _query = _db.collection(USER_COLLECTION);
    if (name != null) {
      _query = _query
          .where("name", isGreaterThanOrEqualTo: name)
          .where("name", isLessThanOrEqualTo: name + "z");
    }
    return _query.get();
  }

  Stream<QuerySnapshot> getChatsForUser(String _uid) {
    return _db
        .collection(CHAT_COLLECTION)
        .where('members', arrayContains: _uid)
        .snapshots();
  }

  Future<QuerySnapshot> getLastMessageForChat(String _chatID) {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(_chatID)
        .collection(MESSAGES_COLLECTION)
        .orderBy("sent_time", descending: true)
        .limit(1)
        .get();
  }

  Stream<QuerySnapshot> streamMessagesForChat(String _chatID) {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(_chatID)
        .collection(MESSAGES_COLLECTION)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  Future<void> addMessageToChat(String _chatID, ChatMessage _message) async {
    try {
      await _db
          .collection(CHAT_COLLECTION)
          .doc(_chatID)
          .collection(MESSAGES_COLLECTION)
          .add(
            _message.toJson(),
          );
      await updateUnreadMessageCount(_chatID);
    } catch (e) {
      print(e);
    }
  }

  Future<void> addMultipleMessagesToChat(
      String chatId, List<ChatMessage> messages) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Assuming CHAT_COLLECTION and MESSAGES_COLLECTION are constants representing collection names
      final collectionRef = FirebaseFirestore.instance
          .collection(CHAT_COLLECTION)
          .doc(chatId)
          .collection(MESSAGES_COLLECTION);

      for (var message in messages) {
        final docRef = collectionRef
            .doc(); // Generate a document reference for each message
        batch.set(
            docRef, message.toJson()); // Set the message data for each document
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error adding multiple messages to chat: $e');
      throw e; // Rethrow the error for handling at the calling site
    }
  }

  Future<void> updateChatData(
      String _chatID, Map<String, dynamic> _data) async {
    try {
      await _db.collection(CHAT_COLLECTION).doc(_chatID).update(_data);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserLastSeenTime(String _uid) async {
    try {
      await _db.collection(USER_COLLECTION).doc(_uid).update(
        {
          "last_active": DateTime.now().toUtc(),
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteChat(String _chatID) async {
    try {
      await _db.collection(CHAT_COLLECTION).doc(_chatID).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<DocumentReference?> createChat(Map<String, dynamic> _data) async {
    try {
      DocumentReference _chat =
          await _db.collection(CHAT_COLLECTION).add(_data);
      return _chat;
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateMessageReadStatus(String chatId) async {
    try {
      await _db
          .collection(CHAT_COLLECTION)
          .doc(chatId)
          .collection(MESSAGES_COLLECTION)
          .where('isRead', isEqualTo: false)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'isRead': true});
        });
      });
    } catch (e) {
      print('Error marking messages as read: $e');
      throw e;
    }
  }

  Future updateUnreadMessageCount(String chatId) async {
    try {
      // Query the messages collection for unread messages
      QuerySnapshot querySnapshot = await _db
          .collection(CHAT_COLLECTION)
          .doc(chatId)
          .collection(MESSAGES_COLLECTION)
          .where('isRead', isEqualTo: false)
          .get();

      // Get the number of unread messages
      int unreadCount = querySnapshot.size;

      // Update the unread message count in the chat document
      await _db
          .collection(CHAT_COLLECTION)
          .doc(chatId)
          .update({'unreadMessagesCount': unreadCount});
    } catch (e) {
      print('Error updating unread message count in Firebase: $e');
      throw e;
    }
  }
Stream<int> streamUnreadMessagesCount(String chatId) {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(chatId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['unreadMessagesCount'] ?? 0);
  }
}
