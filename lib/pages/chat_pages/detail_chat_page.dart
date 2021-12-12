import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ignite/models/chat_user.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class DetailChatPage extends StatefulWidget {
  final ChatUser chatMember;
  final String chatgroupId;
  DetailChatPage(
      {Key? key, required this.chatMember, required this.chatgroupId})
      : super(key: key);

  @override
  _DetailChatPageState createState() => _DetailChatPageState();
}

class _DetailChatPageState extends State<DetailChatPage> {
  late AuthenticationProvider _authenticationProvider;

  late TextEditingController _messageController;
  late FocusNode _messageFocusNode;

  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  String _getDetailDate(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime justNow = now.subtract(Duration(minutes: 1));
    DateTime localDateTime = dateTime.toLocal();
    if (!localDateTime.difference(justNow).isNegative) {
      return 'Just now';
    }
    String roughTimeString = DateFormat('jm').format(dateTime);
    return '$roughTimeString';
  }

  Future _sendMessage() async {
    String docId = firestore
        .collection('chatgroup')
        .doc(widget.chatgroupId)
        .collection('messages')
        .doc()
        .id;
    await firestore
        .collection('chatgroup')
        .doc(widget.chatgroupId)
        .collection('messages')
        .doc(docId)
        .set({
      'messageText': _messageController.text,
      'sentAt': FieldValue.serverTimestamp(),
      'sentBy': _authenticationProvider.currentUser!.uid,
      'isRead': false,
    });
    await firestore.collection('chatgroup').doc(widget.chatgroupId).set({
      'modifiedAt': FieldValue.serverTimestamp(),
      'recentMessage': {
        'messageText': _messageController.text,
        'sentBy': _authenticationProvider.currentUser!.uid,
      },
    }, SetOptions(merge: true));
    _messageController.clear();
  }

  Future _changeReadStatus() async {
    List<String> idList = [];

    await firestore
        .collection('chatgroup')
        .doc(widget.chatgroupId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('sentBy', isNotEqualTo: _authenticationProvider.currentUser!.uid)
        .get()
        .then(
            (element) => element.docs.forEach((value) => idList.add(value.id)));

    idList.forEach((element) async {
      await firestore
          .collection('chatgroup')
          .doc(widget.chatgroupId)
          .collection('messages')
          .doc(element)
          .set({'isRead': true}, SetOptions(merge: true));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
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
    return Scaffold(
      appBar: _detailChatPageAppBar(),
      body: _detailChatPageBody(),
    );
  }

  AppBar _detailChatPageAppBar() {
    return AppBar(
      leadingWidth: 30,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.grey[800]),
      title: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: widget.chatMember.avatar != ''
                ? NetworkImage(widget.chatMember.avatar!)
                : null,
            child: widget.chatMember.avatar != ''
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
                widget.chatMember.username!,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.9),
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.0),
              Row(
                children: <Widget>[
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25), // border color
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(2), // border width
                      child: Container(
                        // or ClipRRect if you need to clip the content
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green, // inner circle color
                        ),
                        child: Container(), // inner content
                      ),
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    'Online',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.9),
                      fontSize: 12.0,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _messageContainer(List? messages) {
    return ListView.builder(
      shrinkWrap: true,
      reverse: true,
      primary: false,
      itemCount: messages!.length,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
          child: Column(
            crossAxisAlignment: messages[index]['sentBy'] ==
                    _authenticationProvider.currentUser!.uid
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8),
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: messages[index]['sentBy'] ==
                          _authenticationProvider.currentUser!.uid
                      ? Colors.red[700]
                      : Colors.grey[200],
                  borderRadius: messages[index]['sentBy'] ==
                          _authenticationProvider.currentUser!.uid
                      ? BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                        )
                      : BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                ),
                child: Text(
                  messages[index]['messageText'],
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: messages[index]['sentBy'] ==
                            _authenticationProvider.currentUser!.uid
                        ? Colors.white
                        : Colors.grey[800],
                  ),
                ),
              ),
              SizedBox(height: 4.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  messages[index]['sentBy'] ==
                              _authenticationProvider.currentUser!.uid &&
                          messages[index]['isRead']
                      ? Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Icon(Icons.check, size: 14.0),
                        )
                      : SizedBox(),
                  Text(
                    messages[index]['sentAt'] != null
                        ? _getDetailDate(messages[index]['sentAt'].toDate())
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
      },
    );
  }

  Widget _messageTextBox() {
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
                if (_messageController.text.isNotEmpty) await _sendMessage();
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

  Widget _detailChatPageBody() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: firestore
                .collection('chatgroup')
                .doc(widget.chatgroupId)
                .collection('messages')
                .orderBy('sentAt', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              _changeReadStatus().then((_) {
                if (mounted) setState(() {});
              });

              if (!snapshot.hasData) {
                return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Center(child: CircularProgressIndicator()));
              } else {
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
                                margin: const EdgeInsets.only(
                                    left: 10.0, right: 15.0),
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
                                margin: const EdgeInsets.only(
                                    left: 15.0, right: 10.0),
                                child: Divider(
                                  color: Colors.black38,
                                  height: 50,
                                ),
                              ),
                            ),
                          ],
                        ),
                        _messageContainer(messages),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),
        _messageTextBox(),
      ],
    );
  }
}
