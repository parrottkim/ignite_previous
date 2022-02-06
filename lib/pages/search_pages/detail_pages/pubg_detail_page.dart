import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ignite/models/chat_user.dart';
import 'package:ignite/pages/chat_pages/detail_chat_page.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:ignite/provider/profile/pubg_profile_provider.dart';
import 'package:ignite/services/service.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class PUBGDetailPage extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> data;
  final AsyncSnapshot<DocumentSnapshot> snapshot;
  PUBGDetailPage({Key? key, required this.data, required this.snapshot})
      : super(key: key);

  @override
  State<PUBGDetailPage> createState() => _PUBGDetailPageState();
}

class _PUBGDetailPageState extends State<PUBGDetailPage> {
  late AuthenticationProvider _authenticationProvider;
  late PUBGProfileProvider _pubgProfileProvider;

  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _pubgProfileProvider =
        Provider.of<PUBGProfileProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _bodyContainer(),
      floatingActionButton: _floatingActionButton(),
    );
  }

  AppBar _appBar() {
    return AppBar();
  }

  Widget _bodyContainer() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _userInformation(),
            SizedBox(height: 10.0),
            SizedBox(height: 20.0),
            _description(),
            SizedBox(height: 14.0),
            Divider(height: 1.0),
            SizedBox(height: 14.0),
            _userReputation(),
          ],
        ),
      ),
    );
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
    return Row(
      children: [
        widget.snapshot.data!['profileImage'] != null
            ? CircleAvatar(
                radius: 40.0,
                backgroundImage:
                    NetworkImage(widget.snapshot.data!['profileImage']),
              )
            : CircleAvatar(
                radius: 40.0,
              ),
        SizedBox(width: 10.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    'assets/images/server_icons/${widget.snapshot.data!['server']}.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            Opacity(
              opacity: 0.4,
              child: widget.snapshot.data!['squadTier'] != null &&
                      widget.snapshot.data!['squadRank'] != null
                  ? Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${widget.snapshot.data!['squadTier']} ${widget.snapshot.data!['squadRank']}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                            ),
                          ),
                          TextSpan(
                              text: ' | ', style: TextStyle(fontSize: 16.0)),
                          TextSpan(
                            text: '${widget.snapshot.data!['squadPoints']}',
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
            fontSize: 18.0,
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
