import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ignite/pages/search_pages/detail_pages/lol_detail_page.dart';
import 'package:ignite/services/service.dart';

class LOLListView extends StatefulWidget {
  const LOLListView({Key? key}) : super(key: key);

  @override
  _LOLListViewState createState() => _LOLListViewState();
}

class _LOLListViewState extends State<LOLListView> {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  late String? _selectedPosition = null;
  late String? _selectedType = null;

  late bool _isPositionSelected;
  final Map<String, String> _positions = {
    'Top': 'top',
    'Jungle': 'jungle',
    'Mid': 'mid',
    'Bottom': 'bottom',
    'Support': 'support'
  };

  late bool _isTypesSelected;
  final Map<String, String> _types = {
    'Solo': 'solo',
    'Flex': 'flex',
    'Normal': 'normal',
    'ARAM': 'aram'
  };

  @override
  void initState() {
    super.initState();
    _isPositionSelected = false;
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
                  .orderBy('date', descending: true)
                  .where('game', isEqualTo: 'lol')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot> items = [];
                  if (_isPositionSelected && _selectedPosition != null) {
                    if (_isTypesSelected && _selectedType != null) {
                      for (var element in snapshot.data!.docs) {
                        if (element['lane'] == _selectedPosition &&
                            element['type'] == _selectedType) {
                          items.add(element);
                        }
                      }
                    } else {
                      for (var element in snapshot.data!.docs) {
                        if (element['lane'] == _selectedPosition) {
                          items.add(element);
                        }
                      }
                    }
                  } else if (_isTypesSelected && _selectedType != null) {
                    if (_isPositionSelected && _selectedPosition != null) {
                      for (var element in snapshot.data!.docs) {
                        if (element['lane'] == _selectedPosition &&
                            element['type'] == _selectedType) {
                          items.add(element);
                        }
                      }
                    } else {
                      for (var element in snapshot.data!.docs) {
                        if (element['type'] == _selectedType) {
                          items.add(element);
                        }
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
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _items(List<QueryDocumentSnapshot> data, String user, int index) {
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
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                createRoute(
                  LOLDetailPage(data: data[index], snapshot: snapshot),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data[index]['title'],
                      style: const TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      data[index]['content'],
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                    ),
                    const SizedBox(height: 14.0),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                              gradient:
                                  _lolTierColors(snapshot.data!['soloTier']),
                              borderRadius: const BorderRadius.all(
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.0,
                                  ),
                                )
                              : const Text(
                                  'UNRANKED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.0,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
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
                              borderRadius: const BorderRadius.all(
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
                            _lolTypeWidgets(data[index]['type']),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4.0),
                      ],
                    ),
                    const SizedBox(height: 14.0),
                    const Divider(height: 1.0),
                    const SizedBox(height: 14.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 22.0,
                          child: Image.asset(
                              'assets/images/game_icons/lol_lanes/${data[index]['lane']}.png',
                              fit: BoxFit.contain),
                        ),
                        Row(
                          children: [
                            Text(
                              snapshot.data!['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.0,
                              ),
                            ),
                            const SizedBox(width: 8.0),
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
        } else {
          return const SizedBox();
        }
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
            if (flag == 0) {
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
                              'Main role filters',
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedPosition = null;
                                  _isPositionSelected = false;
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
                          itemCount: _positions.length,
                          itemBuilder: (context, index) {
                            String key = _positions.keys.elementAt(index);
                            return ListTile(
                              onTap: () {
                                setState(() => _isPositionSelected = true);
                                _selectedPosition = _positions[key];
                                Navigator.of(context).pop();
                              },
                              leading: Image.asset(
                                'assets/images/game_icons/lol_lanes/${_positions[key]}.png',
                                width: 24.0,
                                height: 24.0,
                              ),
                              title: Text(key),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
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
            }
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
            await _filterDialog(0);
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
                      !_isPositionSelected ? Colors.black : Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              color: !_isPositionSelected ? Colors.transparent : Colors.black,
            ),
            child: Text(
              'Main role',
              style: TextStyle(
                color: !_isPositionSelected ? Colors.black : Colors.white,
                fontSize: 14.0,
              ),
            ),
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
