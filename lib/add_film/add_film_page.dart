import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_film_model.dart';

class AddFilmPage extends StatelessWidget {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('films').snapshots();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddFilmModel>(
      create: (_) => AddFilmModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '本を追加',
          ),
        ),
        body: Center(
          child: Consumer<AddFilmModel>(builder: (context, model, child) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      GestureDetector(
                          child: SizedBox(
                            width: 100,
                            height: 160,
                            child: model.imageFile != null
                                ? Image.file(model.imageFile!)
                                : Container(
                                    color: Colors.grey,
                                  ),
                          ),
                          onTap: () async {
                            await model.pickImage();
                          }),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '本のタイトル',
                        ),
                        onChanged: (text) {
                          model.title = text;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '本の著者',
                        ),
                        onChanged: (text) {
                          model.author = text;
                        },
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          //追加の処理
                          try {
                            model.startLoading();
                            await model.addFilm();
                            Navigator.of(context).pop(true);
                          } catch (e) {
                            print(e);
                            //エラー時、SnackBarを表示
                            final snackBar = SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(e.toString()),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          } finally {
                            model.endLoading();
                          }
                        },
                        child: Text('追加する'),
                      ),
                    ],
                  ),
                ),
                if (model.isLoading)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
              ],
            );
          }),
        ),
      ),
    );
  }
}
