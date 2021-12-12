import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ignite/models/chat_user.dart';
import 'package:ignite/pages/chat_pages/detail_chat_page.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:ignite/services/service.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class LoadPostPage extends StatefulWidget {
  final QueryDocumentSnapshot<Object> snapshot;
  final String game;
  LoadPostPage({Key? key, required this.snapshot, required this.game})
      : super(key: key);

  @override
  _LoadPostPageState createState() => _LoadPostPageState();
}

class _LoadPostPageState extends State<LoadPostPage> {
  late AuthenticationProvider _authenticationProvider;

  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  Map _images = Map<String, Image>();
  bool _imageLoaded = false;

  Future<ChatUser?> _getChatMembers(List<dynamic> members) async {
    ChatUser? chatMember;

    for (var member in members) {
      await firestore.collection('user').doc(member).get().then((element) {
        if (member != _authenticationProvider.currentUser!.uid)
          chatMember = new ChatUser(
            id: element.id,
            username: element['username'],
            email: element['email'],
            avatar: element['avatar'],
          );
      });
    }
    return chatMember;
  }

  Future _createChatGroup() async {
    String docId = firestore.collection('chatgroup').doc().id;

    await firestore.collection('chatgroup').doc(docId).set({
      'createdAt': Timestamp.now(),
      'modifiedAt': Timestamp.now(),
      'createdBy': _authenticationProvider.currentUser!.uid,
      'id': docId,
      'isPrivate': true,
      'members': [
        _authenticationProvider.currentUser!.uid,
        widget.snapshot['user']
      ],
      'recentMessage': {
        'messageText': '',
        'sentAt': Timestamp.now(),
        'sentBy': '',
      }
    });

    final snapshot = await firestore.collection('chatgroup').doc(docId).get();
    ChatUser? chatMember = await _getChatMembers(snapshot['members']);

    Navigator.push(
        context,
        createRoute(
            DetailChatPage(chatMember: chatMember!, chatgroupId: docId)));
  }

  Future _enterChatGroup() async {
    Function unorderedEquality =
        const DeepCollectionEquality.unordered().equals;

    await firestore
        .collection('chatgroup')
        .where('members', arrayContains: widget.snapshot['user'])
        .get()
        .then((value) async {
      value.docs.forEach((element) async {
        if (unorderedEquality(element.data()['members'], [
          _authenticationProvider.currentUser!.uid,
          widget.snapshot['user']
        ])) {
          ChatUser? chatMember = await _getChatMembers(element['members']);
          Navigator.push(
              context,
              createRoute(DetailChatPage(
                  chatMember: chatMember!, chatgroupId: element.id)));
        } else {
          await _createChatGroup();
          return;
        }
      });
      if (value.docs.isEmpty) await _createChatGroup();
    });
  }

  Future _preloadImages() async {
    await firestore.collection('gamelist').get().then((snapshots) {
      snapshots.docs.forEach((element) {
        _images.putIfAbsent(element.data()['id'],
            () => Image.network(element.data()['imageLink']));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _preloadImages().then((_) {
      _images.forEach((key, value) async {
        await precacheImage(value.image, context).then((_) {
          if (mounted) setState(() {});
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _loadPostPageAppBar(),
      body: _loadPostPageBody(),
      floatingActionButton: _loadPostPageFloatingActionButton(),
    );
  }

  AppBar _loadPostPageAppBar() {
    return AppBar(
      title: Text('게시물 보기'),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
          height: 60.0,
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              FloatingActionButton(
                onPressed: null,
                child: Padding(
                  padding: EdgeInsets.all(2.0),
                  child: _imageLoaded
                      ? _images['lol']
                      : CircularProgressIndicator(),
                ),
              ),
              SizedBox(width: 10.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.snapshot['title'],
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(widget.snapshot['content'],
                      style: TextStyle(color: Colors.white)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadPostPageBody() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '주 포지션',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            ListTile(
              leading: Container(
                  alignment: Alignment.centerLeft,
                  width: 30.0,
                  child: Image.asset(
                      'assets/images/game_icons/lol_lanes/${widget.snapshot['lane']}.png',
                      fit: BoxFit.contain)),
              title: Text(widget.snapshot['lane']),
            ),
            Divider(height: 1.0),
            SizedBox(height: 20.0),
            Text(
              '작성자 계정',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            _userInformation(),
            _userReputation(),
          ],
        ),
      ),
    );
  }

  Widget? _loadPostPageFloatingActionButton() {
    return widget.snapshot['user'] != _authenticationProvider.currentUser!.uid
        ? FloatingActionButton(
            heroTag: null,
            onPressed: () async {
              await _enterChatGroup();
            },
            child: Icon(Icons.chat_bubble),
          )
        : null;
  }

  Widget _userInformation() {
    return FutureBuilder(
      future: firestore
          .collection('user')
          .doc(widget.snapshot['user'])
          .collection('accounts')
          .doc(widget.game)
          .get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListTile(
            leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://ddragon.leagueoflegends.com/cdn/11.6.1/img/profileicon/${snapshot.data!['profileIconId']}.png'),
                child: Text('${snapshot.data!['summonerLevel']}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            title: Text(snapshot.data!['name'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: snapshot.data!['soloTier'] != null &&
                    snapshot.data!['soloRank'] != null
                ? Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text:
                                '${snapshot.data!['soloTier']} ${snapshot.data!['soloRank']}',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        TextSpan(text: ' | '),
                        TextSpan(
                            text: '${snapshot.data!['soloLeaguePoints']}LP',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                : Text('UNRANKED',
                    style: TextStyle(fontWeight: FontWeight.w500)),
          );
        }

        return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _userReputation() {
    return FutureBuilder(
      future: firestore
          .collection('user')
          .doc(_authenticationProvider.currentUser!.uid)
          .get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData)
          return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(child: CircularProgressIndicator()));
        return ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
              leading: Tooltip(
                message: '매너',
                child: Icon(Icons.thumb_up),
              ),
              title: Text(
                snapshot.data!['manners'].toString(),
              ),
            ),
            ListTile(
              leading: Tooltip(
                message: '게임 스킬',
                child: Icon(Icons.sports_esports),
              ),
              title: Text(
                snapshot.data!['skill'].toString(),
              ),
            ),
          ],
        );
      },
    );
  }
}
