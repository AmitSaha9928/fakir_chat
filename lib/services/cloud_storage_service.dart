import 'dart:io';

//Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class CloudStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CloudStorageService();

  Future<String?> saveUserImageToStorage(
      String _uid, PlatformFile _file) async {
    try {
      if (_file.path == null) {
        throw ArgumentError('File path cannot be null.');
      }
      Reference _ref =
          _storage.ref().child('images/users/$_uid/profile.${_file.extension}');
      UploadTask _task = _ref.putFile(
        File(_file.path!),
      );
      TaskSnapshot snapshot = await _task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error saving user image: $e');
      return null;
    }
  }

  Future<String?> saveChatImageToStorage(
      String _chatID, String _userID, PlatformFile _file) async {
    try {
      if (_file.path == null) {
        throw ArgumentError('File path cannot be null.');
      }
      Reference _ref = _storage.ref().child(
          'images/chats/$_chatID/${_userID}_${Timestamp.now().millisecondsSinceEpoch}.${_file.extension}');
      UploadTask _task = _ref.putFile(
        File(_file.path!),
      );
      TaskSnapshot snapshot = await _task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error saving chat image: $e');
      return null;
    }
  }

  Future<String?> saveChatFileToStorage(
      String _chatID, String _userID, PlatformFile _file) async {
    try {
      if (_file.path == null) {
        throw ArgumentError('File path cannot be null.');
      }
      Reference _ref = _storage.ref().child(
          'docs/chats/$_chatID/${_userID}_${Timestamp.now().millisecondsSinceEpoch}.${_file.extension}');
      UploadTask _task = _ref.putFile(
        File(_file.path!),
      );
      TaskSnapshot snapshot = await _task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error saving chat file: $e');
      return null;
    }
  }
}
