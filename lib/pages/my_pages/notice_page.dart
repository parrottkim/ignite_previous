import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ignite/services/service.dart';
import 'package:ignite/widgets/circular_progress_widget.dart';
import 'package:shimmer/shimmer.dart';

class NoticePage extends StatefulWidget {
  NoticePage({Key? key}) : super(key: key);

  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  static const PAGE_SIZE = 10;

  bool _allFetched = false;
  bool _isLoading = false;
  List<dynamic> _data = [];
  DocumentSnapshot? _lastDocument;

  Future<void> _fetchFirestoreData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final documents =
        await firestore.collection('notice').orderBy('date').get();
    final counts = documents.docs.length;

    if (_data.length < counts) {
      Query _query = firestore.collection('notice').orderBy('date');
      if (_lastDocument != null) {
        _query = _query.startAfterDocument(_lastDocument!).limit(PAGE_SIZE);
      } else {
        _query = _query.limit(PAGE_SIZE);
      }

      final List paginatedData = await _query.get().then((value) {
        if (value.docs.isNotEmpty) {
          _lastDocument = value.docs.last;
        } else {
          _lastDocument = null;
        }

        return value.docs.map((e) => e.data()).toList();
      });

      setState(() {
        _data.addAll(paginatedData);
        if (paginatedData.length < PAGE_SIZE) {
          _allFetched = true;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFirestoreData();
  }

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
    return NotificationListener<ScrollEndNotification>(
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: _data.length + (_allFetched ? 0 : 1),
        itemBuilder: (context, index) {
          if (index == _data.length) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Shimmer.fromColors(
                child: Container(
                  height: 20.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
                baseColor: Colors.grey.withOpacity(0.1),
                highlightColor: Colors.grey.withOpacity(0.3),
              ),
            );
          }

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _items(_data[index]),
              ),
            ),
          );
        },
      ),
      onNotification: (scrollEnd) {
        if (scrollEnd.metrics.atEdge && scrollEnd.metrics.pixels > 0) {
          _fetchFirestoreData();
        }
        return true;
      },
    );
  }

  Widget _items(Map<String, dynamic> data) {
    return FutureBuilder<Uint8List?>(
      future: storage.ref().child('Notice/${data['contentLink']}.md').getData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressWidget();
        }
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['title'],
                  style:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)),
              SizedBox(height: 2.0),
              Text(getDetailDate(data['date'].toDate())),
              SizedBox(height: 10.0),
              Markdown(
                shrinkWrap: true,
                styleSheet: MarkdownStyleSheet(
                  blockquotePadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.grey,
                        width: 5.0,
                      ),
                    ),
                  ),
                ),
                data: utf8.decode(snapshot.data!),
              ),
            ],
          ),
        );
      },
    );
  }
}
