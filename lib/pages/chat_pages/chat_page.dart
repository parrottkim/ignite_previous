import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ignite/models/chat_user.dart';
import 'package:ignite/pages/chat_pages/detail_chat_page.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:ignite/services/service.dart';
import 'package:ignite/widgets/circular_progress_widget.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final firestore = FirebaseFirestore.instance;

  String _getDetailDate(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime justNow = now.subtract(Duration(minutes: 1));
    DateTime localDateTime = dateTime.toLocal();
    if (!localDateTime.difference(justNow).isNegative) {
      return 'Just now';
    }
    String roughTimeString = DateFormat('jm').format(dateTime);
    if (localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return roughTimeString;
    }
    DateTime yesterday = now.subtract(Duration(days: 1));
    if (localDateTime.day == yesterday.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return 'Yesterday, ' + roughTimeString;
    }
    if (now.difference(localDateTime).inDays < 4) {
      String weekday = DateFormat('EEEE').format(localDateTime);
      return '$weekday, $roughTimeString';
    }
    return '${DateFormat('yyyy.MM.dd').format(dateTime)}, $roughTimeString';
  }

  Future<ChatUser?> _getChatMembers(
      AuthenticationProvider value, List<dynamic> members) async {
    ChatUser? chatMember;

    for (var member in members) {
      await firestore.collection('user').doc(member).get().then((element) {
        if (member != value.currentUser!.uid) {
          return chatMember = ChatUser(
            id: element.id,
            username: element['username'],
            email: element['email'],
            avatar: element['avatar'],
          );
        }
      });
    }
    return chatMember;
  }

  Widget _loadItems(AuthenticationProvider value, QueryDocumentSnapshot query,
      ChatUser chatMembers) {
    return Card(
      elevation: 0,
      child: InkWell(
        child: ListTile(
          onTap: () {
            Navigator.push(
                context,
                createRoute(DetailChatPage(
                    chatMember: chatMembers, chatgroupId: query['id'])));
          },
          minLeadingWidth: 10,
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: chatMembers.avatar != ''
                ? NetworkImage(chatMembers.avatar!)
                : null,
            child: chatMembers.avatar != ''
                ? null
                : Icon(
                    Icons.person,
                    color: Colors.grey[400],
                  ),
          ),
          title: Text(chatMembers.username!,
              style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
            query['recentMessage']['messageText'],
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: StreamBuilder(
            stream: firestore
                .collection('chatgroup')
                .doc(query['id'])
                .collection('messages')
                .where('isRead', isEqualTo: false)
                .where('sentBy', isNotEqualTo: value.currentUser!.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                        query['modifiedAt'] != null
                            ? _getDetailDate(query['modifiedAt'].toDate())
                            : '',
                        style:
                            TextStyle(color: Colors.black38, fontSize: 12.0)),
                    SizedBox(height: 6.0),
                    Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          snapshot.data!.docs.length.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Text(
                  query['modifiedAt'] != null
                      ? _getDetailDate(query['modifiedAt'].toDate())
                      : '',
                  style: TextStyle(color: Colors.black38, fontSize: 12.0));
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('채팅')),
      body: _chatPageBody(),
    );
  }

  Widget _chatPageBody() {
    return Consumer<AuthenticationProvider>(
      builder: (context, value, child) {
        if (value.currentUser != null) {
          return Container(
            child: StreamBuilder(
                stream: firestore
                    .collection('chatgroup')
                    .where('members', arrayContains: value.currentUser!.uid)
                    .orderBy('modifiedAt', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: FutureBuilder(
                                future: _getChatMembers(value,
                                    snapshot.data!.docs[index]['members']),
                                builder: (context,
                                    AsyncSnapshot<ChatUser?> subSnapshot) {
                                  if (subSnapshot.hasData) {
                                    return _loadItems(
                                        value,
                                        snapshot.data!.docs[index],
                                        subSnapshot.data!);
                                  } else
                                    return SizedBox();
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else
                    return CircularProgressWidget();
                }),
          );
        } else
          return CircularProgressWidget();
      },
    );
  }
}
