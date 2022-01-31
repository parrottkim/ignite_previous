import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ignite/pages/search_pages/detail_pages/lol_detail_page.dart';
import 'package:ignite/provider/profile/lol_profile_provider.dart';
import 'package:ignite/services/service.dart';
import 'package:provider/provider.dart';

class LOLListView extends StatefulWidget {
  LOLListView({Key? key}) : super(key: key);

  @override
  _LOLListViewState createState() => _LOLListViewState();
}

class _LOLListViewState extends State<LOLListView> {
  late LOLProfileProvider _lolProfileProvider;

  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lolProfileProvider =
        Provider.of<LOLProfileProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestore
          .collection('board')
          .orderBy('date', descending: true)
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
    return FutureBuilder<DocumentSnapshot>(
      future: firestore
          .collection('user')
          .doc(user)
          .collection('accounts')
          .doc('lol')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                createRoute(
                  LOLDetailPage(
                      data: data.data.docs[index],
                      snapshot: snapshot,
                      game: 'lol'),
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.data!.docs[index]['title'],
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      data.data!.docs[index]['content'],
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                    ),
                    SizedBox(height: 14.0),
                    Row(
                      children: [
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
                        SizedBox(width: 6.0),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          width: 60.0,
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Color(0xFF2B2D42),
                                  Color(0xFF8D99AE),
                                ],
                              ),
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
                          child: Text(
                            _lolTypeWidgets(data.data!.docs[index]['type']),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.0),
                      ],
                    ),
                    SizedBox(height: 14.0),
                    Divider(height: 1.0),
                    SizedBox(height: 14.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 22.0,
                          child: Image.asset(
                              'assets/images/game_icons/lol_lanes/${data.data!.docs[index].data()['lane']}.png',
                              fit: BoxFit.contain),
                        ),
                        Row(
                          children: [
                            Text(
                              snapshot.data!['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.0,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            SizedBox(
                              height: 24.0,
                              width: 24.0,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    'https://ddragon.leagueoflegends.com/cdn/11.6.1/img/profileicon/${snapshot.data!['profileIconId']}.png'),
                              ),
                            ),
                          ],
                        )
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

  String _lolTypeWidgets(String type) {
    switch (type) {
      case 'solo':
        return 'SOLO';
      case 'flex':
        return 'FLEX';
      case 'normal':
        return 'NORMAL';
      case 'aram':
        return 'ARAM';
      default:
        return '';
    }
  }
}
