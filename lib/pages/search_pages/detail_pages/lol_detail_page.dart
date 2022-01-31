import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ignite/models/chat_user.dart';
import 'package:ignite/pages/chat_pages/detail_chat_page.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:ignite/provider/profile/lol_profile_provider.dart';
import 'package:ignite/services/service.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class LOLDetailPage extends StatefulWidget {
  final QueryDocumentSnapshot<Object> data;
  final AsyncSnapshot<DocumentSnapshot> snapshot;
  final String game;
  LOLDetailPage(
      {Key? key,
      required this.data,
      required this.snapshot,
      required this.game})
      : super(key: key);

  @override
  _LOLDetailPageState createState() => _LOLDetailPageState();
}

class _LOLDetailPageState extends State<LOLDetailPage> {
  late LOLProfileProvider _lolProfileProvider;
  late AuthenticationProvider _authenticationProvider;

  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  Map _images = Map<String, Image>();
  bool _imageLoaded = false;

  String? _bannerImage;

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
        widget.data['user']
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
        .where('members', arrayContains: widget.data['user'])
        .get()
        .then((value) async {
      value.docs.forEach((element) async {
        if (unorderedEquality(element.data()['members'],
            [_authenticationProvider.currentUser!.uid, widget.data['user']])) {
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
    _lolProfileProvider =
        Provider.of<LOLProfileProvider>(context, listen: false);
    _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    _lolProfileProvider.loadUserMastery(widget.snapshot.data!['name']).then(
        (_) => setState(() => _bannerImage =
            'http://ddragon.leagueoflegends.com/cdn/img/champion/splash/${_lolProfileProvider.userMastery}_0.jpg'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar(),
      body: _bodyContainer(),
      floatingActionButton: _floatingActionButton(),
    );
  }

  AppBar _appBar() {
    return AppBar(
      foregroundColor: _bannerImage != null ? Colors.white : Colors.black,
    );
  }

  Widget _bodyContainer() {
    return Consumer<LOLProfileProvider>(builder: (context, value, widget) {
      return SingleChildScrollView(
        child: Column(
          children: [
            _userInformation(),
            SizedBox(height: 100.0),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _description(),
                  SizedBox(height: 14.0),
                  Divider(height: 1.0),
                  SizedBox(height: 14.0),
                  _userReputation(),
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  Widget? _floatingActionButton() {
    return widget.data['user'] != _authenticationProvider.currentUser!.uid
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _bannerImage != null
            ? Container(
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      _bannerImage!,
                    ),
                  ),
                ),
              )
            : SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Shimmer.fromColors(
                  child: Container(
                    color: Colors.white,
                  ),
                  baseColor: Colors.grey.withOpacity(0.1),
                  highlightColor: Colors.grey.withOpacity(0.3),
                ),
              ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.25 - 44.0,
          left: 20.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: CircleAvatar(
                  radius: 40.0,
                  backgroundImage: NetworkImage(
                      'https://ddragon.leagueoflegends.com/cdn/11.6.1/img/profileicon/${widget.snapshot.data!['profileIconId']}.png'),
                  child: Text(
                    '${widget.snapshot.data!['summonerLevel']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6.0),
              Row(
                children: [
                  Text(
                    widget.snapshot.data!['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22.0,
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 20.0,
                    child: Image.asset(
                      'assets/images/game_icons/lol_lanes/${widget.data['lane']}.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              Opacity(
                opacity: 0.4,
                child: widget.snapshot.data!['soloTier'] != null &&
                        widget.snapshot.data!['soloRank'] != null
                    ? Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${widget.snapshot.data!['soloTier']} ${widget.snapshot.data!['soloRank']}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0,
                              ),
                            ),
                            TextSpan(
                                text: ' | ', style: TextStyle(fontSize: 16.0)),
                            TextSpan(
                              text:
                                  '${widget.snapshot.data!['soloLeaguePoints']}LP',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        'UNRANKED',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _description() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.data['title'],
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          widget.data['content'],
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget _userReputation() {
    return FutureBuilder<DocumentSnapshot>(
      future: firestore
          .collection('user')
          .doc(_authenticationProvider.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(child: CircularProgressIndicator()));
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: snapshot.data!['manners'].toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  TextSpan(
                    text: ' manners',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.0),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: snapshot.data!['skill'].toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  TextSpan(
                    text: ' skills',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
