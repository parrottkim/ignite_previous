import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ignite/models/chat_user.dart';
import 'package:ignite/provider/auth_provider.dart';
import 'package:ignite/services/service.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import 'package:http/http.dart' as http;

class ChatPage extends StatelessWidget {
  final ChatUser members;
  final String chatgroupId;
  const ChatPage({Key? key, required this.members, required this.chatgroupId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserInfoAppBar(
        members: members,
        chatgroupId: chatgroupId,
      ),
      body: ChatScreen(
        members: members,
        chatgroupId: chatgroupId,
      ),
    );
  }
}

class UserInfoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatUser members;
  final String chatgroupId;
  const UserInfoAppBar({
    Key? key,
    required this.members,
    required this.chatgroupId,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      titleSpacing: 0.0,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.grey[800]),
      title: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage:
                members.avatar != '' ? NetworkImage(members.avatar!) : null,
            child: members.avatar != ''
                ? null
                : Icon(
                    Icons.person,
                    color: Colors.grey[400],
                  ),
          ),
          SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                members.username!,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.9),
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.0),
              UserStatus(members: members),
            ],
          ),
        ],
      ),
    );
  }
}

class UserStatus extends StatefulWidget {
  final ChatUser members;
  UserStatus({Key? key, required this.members}) : super(key: key);

  @override
  State<UserStatus> createState() => _UserStatusState();
}

class _UserStatusState extends State<UserStatus> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('user').doc(widget.members.id).snapshots(),
      builder: (context, snapshot) {
        var isOnline = false;
        if (snapshot.hasData) {
          isOnline = snapshot.data!['isOnline'];
        } else {
          isOnline = false;
        }
        return Row(
          children: <Widget>[
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? Colors.green : Colors.red,
                  ),
                  child: Container(),
                ),
              ),
            ),
            SizedBox(width: 4.0),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: Colors.black.withOpacity(0.9),
                fontSize: 12.0,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ChatScreen extends StatelessWidget {
  final ChatUser members;
  final String chatgroupId;
  const ChatScreen({
    Key? key,
    required this.members,
    required this.chatgroupId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MessageList(
          members: members,
          chatgroupId: chatgroupId,
        ),
        MessageTextBox(
          members: members,
          chatgroupId: chatgroupId,
        ),
      ],
    );
  }
}

class MessageList extends StatefulWidget {
  final ChatUser members;
  final String chatgroupId;
  MessageList({
    Key? key,
    required this.members,
    required this.chatgroupId,
  }) : super(key: key);

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future _changeReadStatus() async {
    var currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser!;
    List<String> idList = [];

    await _firestore
        .collection('chatgroup')
        .doc(widget.chatgroupId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('sentBy', isNotEqualTo: currentUser.uid)
        .get()
        .then(
            (element) => element.docs.forEach((value) => idList.add(value.id)));

    idList.forEach((element) async {
      await _firestore
          .collection('chatgroup')
          .doc(widget.chatgroupId)
          .collection('messages')
          .doc(element)
          .set({'isRead': true}, SetOptions(merge: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chatgroup')
            .doc(widget.chatgroupId)
            .collection('messages')
            .orderBy('sentAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return WelcomeMessage();
          }
          _changeReadStatus().then((_) {});
          var grouped = groupBy(
              snapshot.data!.docs,
              (QueryDocumentSnapshot element) => element['sentAt'] != null
                  ? '${element['sentAt'].toDate().year}. ${element['sentAt'].toDate().month}. ${element['sentAt'].toDate().day}'
                  : '${DateTime.now().year}. ${DateTime.now().month}. ${DateTime.now().day}');

          return ListView.builder(
            shrinkWrap: true,
            reverse: true,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            itemCount: grouped.keys.length,
            itemBuilder: (context, index) {
              String date = grouped.keys.toList()[index];
              List? messages = grouped[date];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin:
                              const EdgeInsets.only(left: 10.0, right: 15.0),
                          child: Divider(
                            color: Colors.black38,
                            height: 50,
                          ),
                        ),
                      ),
                      Text(date,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black38)),
                      Expanded(
                        child: new Container(
                          margin:
                              const EdgeInsets.only(left: 15.0, right: 10.0),
                          child: Divider(
                            color: Colors.black38,
                            height: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                  MessageContainer(messages: messages),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class MessageContainer extends StatefulWidget {
  final List? messages;
  MessageContainer({Key? key, this.messages}) : super(key: key);

  @override
  State<MessageContainer> createState() => _MessageContainerState();
}

class _MessageContainerState extends State<MessageContainer> {
  @override
  Widget build(BuildContext context) {
    var currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser!;
    if (widget.messages != null) {
      return ListView.builder(
          shrinkWrap: true,
          reverse: true,
          primary: false,
          itemCount: widget.messages!.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
              child: Column(
                crossAxisAlignment:
                    widget.messages![index]['sentBy'] == currentUser.uid
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color:
                          widget.messages![index]['sentBy'] == currentUser.uid
                              ? Colors.red[700]
                              : Colors.grey[200],
                      borderRadius:
                          widget.messages![index]['sentBy'] == currentUser.uid
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                )
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0),
                                ),
                    ),
                    child: Text(
                      widget.messages![index]['messageText'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color:
                            widget.messages![index]['sentBy'] == currentUser.uid
                                ? Colors.white
                                : Colors.grey[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      widget.messages![index]['sentBy'] == currentUser.uid &&
                              widget.messages![index]['isRead']
                          ? Padding(
                              padding: EdgeInsets.only(right: 4.0),
                              child: Icon(Icons.check, size: 14.0),
                            )
                          : SizedBox.shrink(),
                      Text(
                        widget.messages![index]['sentAt'] != null
                            ? getDetailDate(
                                widget.messages![index]['sentAt'].toDate())
                            : '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
    } else {
      return Container();
    }
  }
}

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '(｡ ´∀` )ﾉ',
            style: TextStyle(
              color: Colors.black.withOpacity(0.2),
              fontSize: 48.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'There are no messages in this chat room now.\nSay hello to your partner first!',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class MessageTextBox extends StatefulWidget {
  final ChatUser members;
  final String chatgroupId;
  MessageTextBox({
    Key? key,
    required this.members,
    required this.chatgroupId,
  }) : super(key: key);

  @override
  State<MessageTextBox> createState() => _MessageTextBoxState();
}

class _MessageTextBoxState extends State<MessageTextBox> {
  final _firestore = FirebaseFirestore.instance;

  late TextEditingController _messageController;
  late FocusNode _messageFocusNode;

  Future _sendMessage(String message) async {
    var currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser!;
    String docId = _firestore
        .collection('chatgroup')
        .doc(widget.chatgroupId)
        .collection('messages')
        .doc()
        .id;
    await _firestore
        .collection('chatgroup')
        .doc(widget.chatgroupId)
        .collection('messages')
        .doc(docId)
        .set({
      'messageText': message,
      'sentAt': FieldValue.serverTimestamp(),
      'sentBy': currentUser.uid,
      'isRead': false,
    });
    await _firestore.collection('chatgroup').doc(widget.chatgroupId).set({
      'modifiedAt': FieldValue.serverTimestamp(),
      'recentMessage': {
        'messageText': message,
        'sentBy': currentUser.uid,
      },
    }, SetOptions(merge: true));
  }

  Future _sendNotifictaion(String message) async {
    var currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser!;
    print(widget.members.id);
    var user = await _firestore
        .collection('user')
        .doc(widget.members.id)
        .get()
        .then((value) {
      return value;
    });

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=${dotenv.env['server_token']!}',
        },
        body: jsonEncode({
          'to': user['token'],
          'priority': 'high',
          'notification': {
            'title': currentUser.displayName,
            'body': message,
            'sound': 'default'
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': user['fcmId'],
            'status': 'done'
          }
        }),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messageController.text = '';
    _messageFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      constraints: const BoxConstraints(maxHeight: 100),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(offset: Offset(0, 3), blurRadius: 5, color: Colors.grey)
        ],
      ),
      child: Material(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.add),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                maxLines: null,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            InkWell(
              onTap: () async {
                if (_messageController.text.isNotEmpty) {
                  var message = _messageController.text;
                  _messageController.clear();
                  await _sendMessage(message);
                  await _sendNotifictaion(message);
                }
              },
              child: Container(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
