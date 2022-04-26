import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ignite/models/filters.dart';
import 'package:ignite/pages/search_pages/detail_pages/lol_detail_page.dart';
import 'package:ignite/pages/search_pages/detail_pages/pubg_detail_page.dart';
import 'package:ignite/services/service.dart';
import 'package:shimmer/shimmer.dart';

class PUBGListView extends StatefulWidget {
  PUBGListView({Key? key}) : super(key: key);

  @override
  _PUBGListViewState createState() => _PUBGListViewState();
}

class _PUBGListViewState extends State<PUBGListView> {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  final Filters _servers = Filters(
    title: 'Server filters',
    filter: {
      'Steam': 'steam',
      'Kakao': 'kakao',
    },
    isSelected: false,
    selectedFilter: null,
  );

  final Filters _types = Filters(
    title: 'Queue type filters',
    filter: {
      'Duos': 'duos',
      'Duos FPP': 'duos-fpp',
      'Squads': 'squads',
      'Squads FPP': 'squads-fpp',
      'Ranked': 'ranked',
      'Ranked FPP': 'ranked-fpp',
    },
    isSelected: false,
    selectedFilter: null,
  );

  static const PAGE_SIZE = 10;

  bool _allFetched = false;
  bool _isLoading = false;
  List<dynamic> _data = [];
  DocumentSnapshot? _lastDocument;

  Future<void> _fetchFirestoreData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final documents = await firestore
        .collection('board')
        .where('game', isEqualTo: 'lol')
        .get();
    final counts = documents.docs.length;

    if (_data.length < counts) {
      Query _query = firestore
          .collection('board')
          .orderBy('date', descending: true)
          .where('game', isEqualTo: 'pubg');
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

        var items = [];
        if (_servers.isSelected && _servers.selectedFilter != null) {
          if (_types.isSelected && _types.selectedFilter != null) {
            for (var element in value.docs) {
              if (element['userinfo']['server'] == _servers.selectedFilter &&
                  element['type'] == _types.selectedFilter) {
                items.add(element);
              }
            }
          } else {
            for (var element in value.docs) {
              if (element['userinfo']['server'] == _servers.selectedFilter) {
                items.add(element);
              }
            }
          }
        } else if (_types.isSelected && _types.selectedFilter != null) {
          if (_servers.isSelected && _servers.selectedFilter != null) {
            for (var element in value.docs) {
              if (element['userinfo']['server'] == _servers.selectedFilter &&
                  element['type'] == _types.selectedFilter) {
                items.add(element);
              }
            }
          } else {
            for (var element in value.docs) {
              if (element['type'] == _types.selectedFilter) {
                items.add(element);
              }
            }
          }
        } else {
          items = value.docs.toList();
        }

        return items.map((e) => e.data()).toList();
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
    _servers.isSelected = false;
    _types.isSelected = false;
    _fetchFirestoreData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _filterButton(),
        SizedBox(height: 6.0),
        _listWidget(),
      ],
    );
  }

  Widget _items(
    Map<String, dynamic> data,
    String user,
  ) {
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
                  PUBGDetailPage(data: data, snapshot: snapshot),
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'],
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.0),
                    Text(data['content']),
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
                            _pubgTypeWidgets(data['type']),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 20.0,
                          child: Image.asset(
                            'assets/images/server_icons/${data['userinfo']['server']}.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              data['userinfo']['username'],
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.0,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            SizedBox(
                              height: 24.0,
                              width: 24.0,
                              child: data['userinfo']['profileImage'] != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          data['userinfo']['profileImage']),
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
          return const SizedBox();
      },
    );
  }

  Widget _listWidget() {
    return Expanded(
      child: NotificationListener<ScrollEndNotification>(
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

            var items = _data[index];

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _items(items, items['user']),
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
      ),
    );
  }

  _filterDialog(Filters filter) {
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
                                filter.selectedFilter = null;
                                filter.isSelected = false;

                                _data.clear();
                                _lastDocument = null;
                                _fetchFirestoreData();
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
                        itemCount: filter.filter.length,
                        itemBuilder: (context, index) {
                          String key = filter.filter.keys.elementAt(index);
                          return ListTile(
                            onTap: () {
                              setState(() {
                                filter.selectedFilter = filter.filter[key];
                                filter.isSelected = true;

                                _data.clear();
                                _lastDocument = null;
                                _fetchFirestoreData();
                              });

                              Navigator.of(context).pop();
                            },
                            leading: filter.filter.keys.first == 'Steam'
                                ? Image.asset(
                                    'assets/images/server_icons/${filter.filter[key]}.png',
                                    width: 24.0,
                                    height: 24.0,
                                  )
                                : null,
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
            await _filterDialog(_servers);
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
                  color:
                      !_servers.isSelected ? Colors.black : Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              color: !_servers.isSelected ? Colors.transparent : Colors.black,
            ),
            child: Text(
              'Server',
              style: TextStyle(
                color: !_servers.isSelected ? Colors.black : Colors.white,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
        SizedBox(width: 4.0),
        InkWell(
          onTap: () async {
            await _filterDialog(_types);
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
                  color:
                      !_types.isSelected ? Colors.black : Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              color: !_types.isSelected ? Colors.transparent : Colors.black,
            ),
            child: Text(
              'Queue type',
              style: TextStyle(
                color: !_types.isSelected ? Colors.black : Colors.white,
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
