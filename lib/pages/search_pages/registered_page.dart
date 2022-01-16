import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ignite/pages/search_pages/list_pages/lol_listview.dart';
import 'package:ignite/pages/search_pages/list_pages/pubg_listview.dart';
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
            element.data()['id'],
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
      appBar: _appBar(),
      body: _bodyContainer(),
      floatingActionButton: _floatingActionButton(),
    );
  }

  Widget radioButton(QuerySnapshot<dynamic> snapshot, int index) {
    return SizedBox(
      width: 50.0,
      height: 50.0,
      child: MaterialButton(
        padding: EdgeInsets.all(4.0),
        color: _selectedIndex == index ? Colors.white : Colors.white60,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        onPressed: () {
          changeRadioButtonIndex(index);
          setState(() {
            _boardId = snapshot.docs[index].id;
          });
        },
        child: _images[snapshot.docs[index].id],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      elevation: 0.0,
      backgroundColor: Theme.of(context).primaryColor,
      title: Text('Discover'),
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

  Widget _bodyContainer() {
    if (_boardId == 'lol')
      return LOLListView();
    else if (_boardId == 'pubg')
      return PUBGListView();
    else
      return Center(child: CircularProgressIndicator());
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      heroTag: null,
      onPressed: () async {
        final result = await Navigator.push(
            context, createRoute(WritePostPage(snapshot: widget.snapshot)));
        if (result != null) {
          changeRadioButtonIndex(result);
          setState(() {
            _boardId = widget.snapshot.docs[result].id;
          });
        }
      },
      child: Icon(Icons.add),
    );
  }
}
