import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ignite/pages/search_pages/write_pages/lol_write_page.dart';
import 'package:ignite/pages/search_pages/write_pages/pubg_write_page.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:ignite/services/service.dart';
import 'package:provider/provider.dart';

class WritePostPage extends StatefulWidget {
  QuerySnapshot snapshot;
  WritePostPage({Key? key, required this.snapshot}) : super(key: key);

  @override
  _WritePostPageState createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage>
    with SingleTickerProviderStateMixin {
  late AuthenticationProvider _authenticationProvider;

  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  Map _games = Map<String, String>();
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
      for (var element in snapshots.docs) {
        _games.putIfAbsent(
            element.data()['id'], () => element.data()['name'].toString());
        _images.putIfAbsent(
            element.data()['id'],
            () => Image.asset(
                'assets/images/game_icons/${element.data()['id']}.png'));
      }
    });
  }

  _navigate(String id) {
    if (id == 'lol')
      return Navigator.push(
        context,
        createRoute(
          LOLWritePage(),
        ),
      );
    if (id == 'pubg')
      return Navigator.push(
        context,
        createRoute(
          PUBGWritePage(),
        ),
      );
  }

  @override
  void initState() {
    super.initState();
    _boardId = widget.snapshot.docs[_selectedIndex].id;
    _preloadImages().then((_) {
      _images.forEach((key, value) async {
        await precacheImage(value.image, context).then((_) {
          setState(() {});
        });
        _imageLoaded = true;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _bodyContainer(),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Text('New post'),
    );
  }

  Widget _bodyContainer() {
    return _imageLoaded
        ? Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(
                horizontal: widget.snapshot.docs.length <= 2
                    ? 120 / widget.snapshot.docs.length
                    : 16.0),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: widget.snapshot.docs.length,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.snapshot.docs.length <= 3
                    ? widget.snapshot.docs.length
                    : 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                return _items(
                    _images[widget.snapshot.docs[index].id],
                    index,
                    widget.snapshot.docs.length <= 3
                        ? widget.snapshot.docs.length
                        : 3);
              },
            ),
          )
        : SizedBox();
  }

  Widget _items(Image image, int index, int count) {
    return Card(
      elevation: 0.4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(0.0),
        onTap: () => _navigate(widget.snapshot.docs[index].id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            image,
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Divider(height: 10.0)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                _games[widget.snapshot.docs[index].id],
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontSize: count <= 2 ? 21.0 - count * 3 : 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radioButton(Image image, int index) {
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
            _boardId = widget.snapshot.docs[index].id;
          });
        },
        child: image,
      ),
    );
  }
}
