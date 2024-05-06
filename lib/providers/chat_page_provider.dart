import 'dart:async';

//Packages
import 'package:fakir_chat/models/chat_message.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

//Services
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models

class ChatPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;

  AuthenticationProvider _auth;
  ScrollController _messagesListViewController;

  String _chatId;
  List<ChatMessage>? messages;

  late StreamSubscription _messagesStream;
  late StreamSubscription _keyboardVisibilityStream;
  late KeyboardVisibilityController _keyboardVisibilityController;

  String? _message;

  String get message {
    return message;
  }

  void set message(String _value) {
    _message = _value;
  }

  ChatPageProvider(this._chatId, this._auth, this._messagesListViewController) {
    _db = GetIt.instance.get<DatabaseService>();
    _storage = GetIt.instance.get<CloudStorageService>();
    _media = GetIt.instance.get<MediaService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _keyboardVisibilityController = KeyboardVisibilityController();
    listenToMessages();
    listenToKeyboardChanges();
  }

  @override
  void dispose() {
    _messagesStream.cancel();
    super.dispose();
  }

  void listenToMessages() {
    try {
      _messagesStream = _db.streamMessagesForChat(_chatId).listen(
        (_snapshot) {
          List<ChatMessage> _messages = _snapshot.docs.map(
            (_m) {
              Map<String, dynamic> _messageData =
                  _m.data() as Map<String, dynamic>;
              return ChatMessage.fromJSON(_messageData);
            },
          ).toList();
          messages = _messages;
          notifyListeners();
          WidgetsBinding.instance!.addPostFrameCallback(
            (_) {
              if (_messagesListViewController.hasClients) {
                _messagesListViewController.jumpTo(
                    _messagesListViewController.position.maxScrollExtent);
              }
            },
          );
        },
      );
    } catch (e) {
      print("Error getting messages.");
      print(e);
    }
  }

  void listenToKeyboardChanges() {
    _keyboardVisibilityStream = _keyboardVisibilityController.onChange.listen(
      (_event) {
        _db.updateChatData(_chatId, {"is_activity": _event});
      },
    );
  }

  void sendTextMessage() {
    if (_message != null) {
      ChatMessage _messageToSend = ChatMessage(
        content: _message!,
        type: MessageType.TEXT,
        senderID: _auth.user.uid,
        sentTime: DateTime.now(),
      );
      _db.addMessageToChat(_chatId, _messageToSend);
    }
  }

  void sendImageMessage(XFile imageFile) async {
    try {
      // Convert XFile to PlatformFile
      PlatformFile file = PlatformFile(
        name: imageFile.name,
        size: await imageFile.length(),
        path: imageFile.path,
      );

      // Use the converted file to save to storage
      String? _downloadURL =
          await _storage.saveChatImageToStorage(_chatId, _auth.user.uid, file);
      if (_downloadURL != null) {
        ChatMessage _messageToSend = ChatMessage(
          content: _downloadURL,
          type: MessageType.IMAGE,
          senderID: _auth.user.uid,
          sentTime: DateTime.now(),
        );
        _db.addMessageToChat(_chatId, _messageToSend);
      }
    } catch (e) {
      print("Error sending image message.");
      print(e);
    }
  }

  void sendMultipleImageMessages(List<PlatformFile> files) async {
    try {
      List<String> downloadURLs = [];

      for (PlatformFile file in files) {
        String? downloadURL = await _storage.saveChatImageToStorage(
            _chatId, _auth.user.uid, file);
        if (downloadURL != null) {
          downloadURLs.add(downloadURL);
        }
      }

      if (downloadURLs.isNotEmpty) {
        List<ChatMessage> messagesToSend = downloadURLs.map((url) {
          return ChatMessage(
            content: url,
            type: MessageType.IMAGE,
            senderID: _auth.user.uid,
            sentTime: DateTime.now(),
          );
        }).toList();

        _db.addMultipleMessagesToChat(_chatId, messagesToSend);
      }
    } catch (e) {
      print("Error sending multiple image messages.");
      print(e);
    }
  }

  void sendMultipleFileMessages(List<PlatformFile> files) async {
    try {
      List<Map<String, String>> fileDataList = [];

      for (PlatformFile file in files) {
        String fileName = file.name;
        String? fileURL = await _storage.saveChatFileToStorage(
            _chatId, _auth.user.uid, file); // Change to nullable type
        if (fileURL != null) {
          fileDataList.add({
            'fileName': fileName,
            'fileURL': fileURL,
          });
        }
      }

      if (fileDataList.isNotEmpty) {
        List<ChatMessage> messagesToSend = fileDataList.map((fileData) {
          String fileName = fileData['fileName'] ?? ''; // Get the file name
          String fileURL = fileData['fileURL'] ?? ''; // Get the file URL

          return ChatMessage(
            content: fileName, // Set the content to be the file name
            type: MessageType.FILE,
            senderID: _auth.user.uid,
            sentTime: DateTime.now(),
            url: fileURL, // Set the URL
          );
        }).toList();

        _db.addMultipleMessagesToChat(_chatId, messagesToSend);
      }
    } catch (e) {
      print("Error sending multiple file messages.");
      print(e);
    }
  }

  void deleteChat() {
    goBack();
    _db.deleteChat(_chatId);
  }

  void goBack() {
    _navigation.goBack();
  }

  void markMessagesAsRead(List<ChatMessage> messages) async {
    for (ChatMessage message in messages) {
      if (!message.isRead) {
        message.isRead = true;
        // Update the message in the database
        await _db.updateMessageReadStatus(
            _chatId); // You need to implement this method in the DatabaseService
      }
    }
  }

  void updateCount() {
    _db.updateUnreadMessageCount(_chatId);
  }
}
