import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ignite/pages/search_pages/detail_pages/lol_detail_page.dart';
import 'package:ignite/pages/search_pages/detail_pages/pubg_detail_page.dart';
import 'package:ignite/services/service.dart';

class PUBGListView extends StatefulWidget {
  PUBGListView({Key? key}) : super(key: key);

  @override
  _PUBGListViewState createState() => _PUBGListViewState();
}

class _PUBGListViewState extends State<PUBGListView> {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  late String? _selectedType = null;

  late bool _isTypesSelected;
  final Map<String, String> _types = {
    'Duos': 'duos',
    'Duos FPP': 'duos-fpp',
    'Squads': 'squads',
    'Squads FPP': 'squads-fpp',
    'Ranked': 'ranked',
    'Ranked FPP': 'ranked-fpp'
  };

  @override
  void initState() {
    super.initState();
    _isTypesSelected = false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _filterButton(),
            SizedBox(height: 6.0),
            StreamBuilder<QuerySnapshot<Object?>>(
              stream: firestore
                  .collection('board')
                  .where('game', isEqualTo: 'pubg')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot> items = [];
                  if (_isTypesSelected && _selectedType != null) {
                    for (var element in snapshot.data!.docs) {
                      if (element['type'] == _selectedType) {
                        items.add(element);
                      }
                    }
                  } else {
                    items = snapshot.data!.docs.toList();
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _items(items, items[index]['user'], index),
                          ),
                        ),
                      );
                    },
                  );
                } else
                  return Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _items(List<QueryDocumentSnapshot> data, String user, int index) {
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
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                createRoute(
                  PUBGDetailPage(data: data[index], snapshot: snapshot),
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data[index]['title'],
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.0),
                    Text(data[index]['content']),
                    SizedBox(height: 14.0),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                              gradient:
                                  _pubgTierColors(snapshot.data!['squadTier']),
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
                        SizedBox(width: 6.0),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          width: 80.0,
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
                            _pubgTypeWidgets(data[index]['type']),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.0),
                    Divider(height: 1.0),
                    SizedBox(height: 14.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                              child: snapshot.data!['profileImage'] != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          snapshot.data!['profileImage']),
                                    )
                                  : CircleAvatar(),
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

  _filterDialog(int flag) {
    return showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 26.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Queue type filters',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedType = null;
                                _isTypesSelected = false;
                              });
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _types.length,
                        itemBuilder: (context, index) {
                          String key = _types.keys.elementAt(index);
                          return ListTile(
                            onTap: () {
                              setState(() => _isTypesSelected = true);
                              _selectedType = _types[key];
                              Navigator.of(context).pop();
                            },
                            title: Text(key),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterButton() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune, size: 16.0),
              SizedBox(width: 4.0),
              Text('Filters', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        SizedBox(width: 4.0),
        InkWell(
          onTap: () async {
            await _filterDialog(1);
            setState(() {});
          },
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(
                  width: 0.5,
                  color: !_isTypesSelected ? Colors.black : Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              color: !_isTypesSelected ? Colors.transparent : Colors.black,
            ),
            child: Text(
              'Queue type',
              style: TextStyle(
                color: !_isTypesSelected ? Colors.black : Colors.white,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      ],
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

  String _pubgTypeWidgets(String type) {
    switch (type) {
      case 'duos':
        return 'DUOS';
      case 'duos-fpp':
        return 'DUOS FPP';
      case 'squads':
        return 'SQUADS';
      case 'squads-fpp':
        return 'SQUADS FPP';
      case 'ranked':
        return 'RANKED';
      case 'ranked-fpp':
        return 'RANKED FPP';
      default:
        return '';
    }
  }
}
