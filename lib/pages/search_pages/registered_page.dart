import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ignite/pages/search_pages/load_post_page.dart';
import 'package:ignite/pages/search_pages/write_post_page.dart';
import 'package:ignite/services/service.dart';

class RegisteredPage extends StatefulWidget {
  QuerySnapshot snapshot;
  RegisteredPage({Key? key, required this.snapshot}) : super(key: key);

  @override
  _RegisteredPageState createState() => _RegisteredPageState();
}

class _RegisteredPageState extends State<RegisteredPage> {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  Map _images = Map<String, Image>();
  bool _imageLoaded = false;

  int _selectedIndex = 0;
  late String _boardId;

  void changeRadioButtonIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future _preloadImages() async {
    await firestore.collection('gamelist').get().then((snapshots) {
      snapshots.docs.forEach((element) {
        _images.putIfAbsent(
            element.data()["id"],
            () => Image.asset(
                'assets/images/game_icons/${element.data()['id']}.png'));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _boardId = widget.snapshot.docs[_selectedIndex].id;
    _preloadImages().then((_) {
      _images.forEach((key, value) async {
        if (mounted) {
          await precacheImage(value.image, context).then((_) {
            setState(() {});
          });
          _imageLoaded = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _registeredPageAppBar(),
      body: _registeredPageBody(),
      floatingActionButton: _registeredFloatingActionButton(),
    );
  }

  Widget radioButton(QuerySnapshot<dynamic> snapshot, int index) {
    return FloatingActionButton(
      heroTag: null,
      onPressed: () {
        changeRadioButtonIndex(index);
        setState(() {
          _boardId = snapshot.docs[index].id;
        });
      },
      backgroundColor: _selectedIndex == index ? Colors.red : Colors.black26,
      child: Padding(
          padding: EdgeInsets.all(2.0),
          child: _images[snapshot.docs[index].id]),
    );
  }

  AppBar _registeredPageAppBar() {
    return AppBar(
      title: Text('동료 찾기'),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
          height: 60.0,
          alignment: Alignment.centerLeft,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: widget.snapshot.docs.length,
            itemBuilder: (context, index) {
              return radioButton(widget.snapshot, index);
            },
            separatorBuilder: (context, index) {
              return SizedBox(width: 4.0);
            },
          ),
        ),
      ),
    );
  }

  Widget _registeredPageBody() {
    return StreamBuilder(
      stream: firestore
          .collection('board')
          .where('game', isEqualTo: _boardId)
          .snapshots(),
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
                    child: _loadItems(snapshot, index),
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

  Widget? _registeredFloatingActionButton() {
    _boardId != null
        ? FloatingActionButton(
            heroTag: null,
            onPressed: () async {
              final result = await Navigator.push(context,
                  createRoute(WritePostPage(snapshot: widget.snapshot)));
              if (result != null) {
                changeRadioButtonIndex(result);
                setState(() {
                  _boardId = widget.snapshot.docs[result].id;
                });
              }
            },
            child: Icon(Icons.add),
          )
        : null;
  }

  Widget _loadItems(AsyncSnapshot<dynamic> snapshot, int index) {
    switch (_boardId) {
      case 'lol':
        return InkWell(
          child: ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  createRoute(LoadPostPage(
                      snapshot: snapshot.data.docs[index], game: 'lol')));
            },
            minLeadingWidth: 10,
            leading: Container(
                alignment: Alignment.centerLeft,
                width: 20.0,
                child: Image.asset(
                    'assets/images/game_icons/lol_lanes/${snapshot.data.docs[index]['lane']}.png',
                    fit: BoxFit.contain)),
            title: Text(snapshot.data.docs[index]['title'],
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(snapshot.data.docs[index]['content']),
          ),
        );
      case 'pubg':
        return InkWell(
          child: ListTile(
            onTap: () {},
            minLeadingWidth: 10,
            leading: snapshot.data.docs[index]['type'] == 'squad'
                ? const SizedBox(
                    height: double.infinity, child: Icon(Icons.looks_4))
                : const SizedBox(
                    height: double.infinity, child: Icon(Icons.looks_two)),
            title: Text(snapshot.data.docs[index]['title'],
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(snapshot.data.docs[index]['content']),
          ),
        );
      default:
        return SizedBox();
    }
  }
}
