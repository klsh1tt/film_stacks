import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddFilmModel extends ChangeNotifier {
  String? title;
  String? watchingPlatform;
  File? imageFile;
  bool isLoading = false;

  final picker = ImagePicker();

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

    void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future addFilm() async {
    //null or 空文字なら例外処理を実行する
    if (title == null || title == "") {
      throw '映画のタイトルが入力されていません';
    }

    if (watchingPlatform == null || watchingPlatform!.isEmpty) {
      throw '見た場所（サービス）が入力されていません';
    }

    final doc = FirebaseFirestore.instance.collection('films').doc();

    String? imgURL;
    if (imageFile != null) {
      // strageにアップロード
      final task = await FirebaseStorage.instance.ref('films/').putFile(imageFile!);
      imgURL = await task.ref.getDownloadURL();
    }

    // firestoreに追加
    // https://firebase.flutter.dev/docs/firestore/usage/#adding-documents
    
    await doc.set({
      'title': title,
      'watchingPlatform': watchingPlatform,
      'imgURL': imgURL,
    });
  }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }
}
