import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ignite/widgets/circular_progress_widget.dart';

class NoticePage extends StatefulWidget {
  NoticePage({Key? key}) : super(key: key);

  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('공지사항'),
      ),
      body: _bodyContainer(),
    );
  }

  Widget _bodyContainer() {
    return StreamBuilder(
      stream: firestore.collection('notice').orderBy('date').snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Text(snapshot.data!.docs[index]['title']),
                  ),
                ),
              );
            },
          );
        } else
          return CircularProgressWidget();
      },
    );
  }
}
