import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:film_stacks/domain/film.dart';
import 'package:flutter/material.dart';

class FilmListModel extends ChangeNotifier {
  // final _userCollection = FirebaseFirestore.instance.collection('films');

  List<Film>? films;

  void fetchFilmList() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('films').get();

    final List<Film> films = snapshot.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      final String id = document.id;
      final String title = data['title'];
      final String watchingPlatform = data['watchingPlatform'];
      final String? imgURL = data['imgURL'];
      return Film(id, title, watchingPlatform, imgURL);
    }).toList();

    this.films = films;
    notifyListeners();
  }

  // Future delete(Film film) {
  //   // return FirebaseFirestore.instance.collection('films').doc(film.id).delete();
  // }
}
