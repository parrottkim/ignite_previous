import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ignite/pages/search_pages/detail_post_page.dart';
import 'package:ignite/services/service.dart';

class PUBGListView extends StatefulWidget {
  PUBGListView({Key? key}) : super(key: key);

  @override
  _PUBGListViewState createState() => _PUBGListViewState();
}

class _PUBGListViewState extends State<PUBGListView> {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestore
          .collection('board')
          .where('game', isEqualTo: 'pubg')
          .snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _items(
                        snapshot, snapshot.data!.docs[index]['user'], index),
                  ),
                ),
              );
            },
          );
        } else
          return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _items(AsyncSnapshot<dynamic> snapshot, String user, int index) {
    return FutureBuilder(
      future: firestore
          .collection('user')
          .doc(user)
          .collection('accounts')
          .doc('pubg')
          .get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                createRoute(
                  DetailPostPage(snapshot: snapshot.data![index], game: 'pubg'),
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'https://ddragon.leagueoflegends.com/cdn/11.6.1/img/profileicon/${snapshot.data!['profileIconId']}.png'),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            snapshot.data!['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                            // gradient:
                            //     _pubgTierColors(snapshot.data!['soloTier']),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 4,
                              ),
                            ]),
                        child: snapshot.data!['soloTier'] != null
                            ? Text(
                                '${snapshot.data!['soloTier']} ${snapshot.data!['soloRank']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.0,
                                ),
                              )
                            : Text(
                                'UNRANKED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.0,
                                ),
                              ),
                      ),
                    ])
                  ],
                ),
              ),
            ),
          );
        } else
          return Center(child: CircularProgressIndicator());
      },
    );
  }
}
