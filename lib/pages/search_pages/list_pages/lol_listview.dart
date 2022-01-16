import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ignite/pages/search_pages/detail_post_page.dart';
import 'package:ignite/services/service.dart';

class LOLListView extends StatefulWidget {
  LOLListView({Key? key}) : super(key: key);

  @override
  _LOLListViewState createState() => _LOLListViewState();
}

class _LOLListViewState extends State<LOLListView> {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestore
          .collection('board')
          .where('game', isEqualTo: 'lol')
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

  Widget _items(AsyncSnapshot<dynamic> data, String user, int index) {
    return FutureBuilder(
      future: firestore
          .collection('user')
          .doc(user)
          .collection('accounts')
          .doc('lol')
          .get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                createRoute(
                  DetailPostPage(snapshot: snapshot.data![index], game: 'lol'),
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                              gradient:
                                  _lolTierColors(snapshot.data!['soloTier']),
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
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Divider(height: 1.0, color: Colors.grey),
                    SizedBox(height: 10.0),
                    Text(
                      data.data!.docs[index]['title'],
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.0),
                    Text(data.data!.docs[index]['content']),
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

  LinearGradient? _lolTierColors(String? tier) {
    switch (tier) {
      case 'IRON':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF423730),
            Color(0xFF848482),
          ],
        );
      case 'BRONZE':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF4F1C0D),
            Color(0xFFA96A40),
          ],
        );
      case 'SILVER':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF848482),
            Color(0xFFB0C4DE),
          ],
        );
      case 'GOLD':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFDA9100),
            Color(0xFFFCC201),
          ],
        );
      case 'PLATINUM':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF209BBA),
            Color(0xFFA8D8DF),
          ],
        );
      case 'DIAMOND':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF4467C4),
            Color(0xFF8EC3E6),
          ],
        );
      case 'MASTER':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF5F31A9),
            Color(0xFFCEA7DE),
          ],
        );
      case 'GRANDMASTER':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF4B505A),
            Color(0xFFDE3E25),
          ],
        );
      case 'CHALLENGER':
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
}
