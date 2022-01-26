import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ignite/pages/search_pages/detail_pages/lol_detail_page.dart';
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
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('board')
          .where('game', isEqualTo: 'pubg')
          .snapshots(),
      builder: (context, snapshot) {
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

  Widget _items(AsyncSnapshot<dynamic> data, String user, int index) {
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
              // onTap: () => Navigator.push(
              //   context,
              //   createRoute(
              //     DetailPostPage(
              //         data: data.data.docs[index],
              //         snapshot: snapshot,
              //         game: 'pubg'),
              //   ),
              // ),
              child: Container(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // SizedBox(
                        //   height: 20.0,
                        //   width: 20.0,
                        //   child: CircleAvatar(
                        //     backgroundImage: NetworkImage(
                        //         'https://ddragon.leagueoflegends.com/cdn/11.6.1/img/profileicon/${snapshot.data!['profileIconId']}.png'),
                        //   ),
                        // ),
                        // SizedBox(width: 8.0),
                        Text(
                          snapshot.data!['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 7.0),
                    Divider(height: 1.0),
                    SizedBox(height: 7.0),
                    Text(
                      data.data!.docs[index]['title'],
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.0),
                    Text(data.data!.docs[index]['content']),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _pubgTypeWidgets(data.data!.docs[index]['type']),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              decoration: BoxDecoration(
                                  gradient: _pubgTierColors(
                                      snapshot.data!['squadTier']),
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
                              child: snapshot.data!['squadTier'] != null
                                  ? Text(
                                      '${snapshot.data!['squadTier']} ${snapshot.data!['squadRank']}',
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
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else
          return SizedBox();
      },
    );
  }

  LinearGradient? _pubgTierColors(String? tier) {
    switch (tier) {
      case 'Bronze':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF4F1C0D),
            Color(0xFFA96A40),
          ],
        );
      case 'Silver':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF848482),
            Color(0xFFB0C4DE),
          ],
        );
      case 'Gold':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFDA9100),
            Color(0xFFFCC201),
          ],
        );
      case 'Platinum':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF209BBA),
            Color(0xFFA8D8DF),
          ],
        );
      case 'Diamond':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF4467C4),
            Color(0xFF8EC3E6),
          ],
        );
      case 'Master':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF7BC1FA),
            Color(0xFFFCC201),
          ],
        );
      case null:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF104730),
            Color(0xFF6D9775),
          ],
        );
    }
  }

  Widget _pubgTypeWidgets(String type) {
    switch (type) {
      case 'duo':
        return Icon(Icons.looks_two);
      case 'squad':
        return Icon(Icons.looks_4);
      default:
        return SizedBox();
    }
  }
}
