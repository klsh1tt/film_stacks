import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:film_stacks/add_film/add_film_page.dart';
import 'package:film_stacks/domain/film.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'film_list_model.dart';

class FilmListPage extends StatelessWidget {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('films').snapshots();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FilmListModel>(
      create: (_) => FilmListModel()..fetchFilmList(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('フィルム一覧'),
          actions: [
            IconButton(
              onPressed: () async {
                // if (FirebaseAuth.instance.currentUser != null) {
                //   print('ログインしている');
                //   await Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => MyPage(),
                //       fullscreenDialog: true, //遷移先の画面が下から上へ登ってくるように表示される
                //     ),
                //   );
                // } else {
                //   print('ログインしていない');
                //   await Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => LoginPage(),
                //       fullscreenDialog: true, //遷移先の画面が下から上へ登ってくるように表示される
                //     ),
                //   );
                // }
              },
              icon: Icon(Icons.person),
            ),
          ],
        ),
        body: Center(
          child: Consumer<FilmListModel>(builder: (context, model, child) {
            final List<Film>? films = model.films;

            if (films == null) {
              return CircularProgressIndicator();
            }

            final List<Widget> widgets = films
                .map(
                  (films) => ListTile(
                    title: Text(film.title),
                    subtitle: Text(film.watchingPlatform),
                  ),
                )
                .toList();
            return ListView(
              children: widgets,
            );
          }),
        ),
        floatingActionButton: Consumer<FilmListModel>(builder: (context, model, child) {
          return FloatingActionButton(
            onPressed: () async {
              //画面遷移
              final bool? added = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFilmPage(),
                  fullscreenDialog: true, //遷移先の画面が下から上へ登ってくるように表示される
                ),
              );

              if (added != null && added) {
                final snackBar = SnackBar(
                  backgroundColor: Colors.green,
                  content: Text("映画を追加しました"),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }

              model.fetchFilmList();
            },
            tooltip: 'Increment',
            child: Icon(Icons.add),
          );
        }),
      ),
    );
  }

  Future showConfirmDialog(
    BuildContext context,
    Film film,
    FilmListModel model,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: Text("削除の確認"),
          content: Text("「${film.title}」を削除しますか？"),
          actions: [
            TextButton(
              child: Text("いいえ"),
              onPressed: () => Navigator.pop(_scaffoldKey.currentContext!),
            ),
            TextButton(
              child: Text("はい"),
              onPressed: () async {
                //modelで削除
                await model.delete(film);
                Navigator.pop(_scaffoldKey.currentContext!);

                final snackBar = SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('${film.title}を削除しました'),
                );
                model.fetchFilmList();
                ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
              },
            ),
          ],
        );
      },
    );
  }
}
