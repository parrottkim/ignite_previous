import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ignite/models/chat_user.dart';
import 'package:ignite/pages/chat_pages/chat_page.dart';
import 'package:ignite/provider/auth_provider.dart';
import 'package:ignite/services/service.dart';
import 'package:ignite/widgets/circular_progress_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ChatgroupPage extends StatelessWidget {
  const ChatgroupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('채팅')),
      body: ChatgroupList(),
    );
  }
}

class ChatgroupList extends StatefulWidget {
  ChatgroupList({Key? key}) : super(key: key);

  @override
  State<ChatgroupList> createState() => _ChatgroupListState();
}

class _ChatgroupListState extends State<ChatgroupList> {
  final _firestore = FirebaseFirestore.instance;

  Future<ChatUser?> _getMembers(User currentUser, List<dynamic> members) async {
    ChatUser? chatMember;

    for (var member in members) {
      await _firestore.collection('user').doc(member).get().then((element) {
        if (member != currentUser.uid) {
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

  @override
  Widget build(BuildContext context) {
    var currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser!;
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chatgroup')
          .where('members', arrayContains: currentUser.uid)
          .orderBy('modifiedAt', descending: true)
          .snapshots(),
      builder: (context, chatgroup) {
        if (chatgroup.hasData) {
          return ListView.builder(
            itemCount: chatgroup.data!.docs.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: FutureBuilder<ChatUser?>(
                      future: _getMembers(
                          currentUser, chatgroup.data!.docs[index]['members']),
                      builder: (context, members) {
                        if (members.hasData) {
                          return ChatgroupListItem(
                              currentUser: currentUser,
                              chatgroup: chatgroup.data!.docs[index],
                              members: members.data!);
                        } else
                          return SizedBox();
                      },
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Shimmer.fromColors(
              child: Container(
                height: 20.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
              baseColor: Colors.grey.withOpacity(0.1),
              highlightColor: Colors.grey.withOpacity(0.3),
            ),
          );
        }
      },
    );
  }
}

class ChatgroupListItem extends StatefulWidget {
  final User currentUser;
  final QueryDocumentSnapshot chatgroup;
  final ChatUser members;
  ChatgroupListItem({
    Key? key,
    required this.currentUser,
    required this.chatgroup,
    required this.members,
  }) : super(key: key);

  @override
  State<ChatgroupListItem> createState() => _ChatgroupListItemState();
}

class _ChatgroupListItemState extends State<ChatgroupListItem> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        child: ListTile(
          onTap: () {
            Navigator.push(
                context,
                createRoute(ChatPage(
                    members: widget.members,
                    chatgroupId: widget.chatgroup['id'])));
          },
          minLeadingWidth: 10,
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: widget.members.avatar != ''
                ? NetworkImage(widget.members.avatar!)
                : null,
            child: widget.members.avatar != ''
                ? null
                : Icon(
                    Icons.person,
                    color: Colors.grey[400],
                  ),
          ),
          title: Text(widget.members.username!,
              style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
            widget.chatgroup['recentMessage']['messageText'],
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: StreamBuilder(
            stream: _firestore
                .collection('chatgroup')
                .doc(widget.chatgroup['id'])
                .collection('messages')
                .where('isRead', isEqualTo: false)
                .where('sentBy', isNotEqualTo: widget.currentUser.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                        widget.chatgroup['modifiedAt'] != null
                            ? getDetailDate(
                                widget.chatgroup['modifiedAt'].toDate())
                            : '',
                        style:
                            TextStyle(color: Colors.black38, fontSize: 12.0)),
                    SizedBox(height: 6.0),
                    Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary),
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
                  widget.chatgroup['modifiedAt'] != null
                      ? getDetailDate(widget.chatgroup['modifiedAt'].toDate())
                      : '',
                  style: TextStyle(color: Colors.black38, fontSize: 12.0));
            },
          ),
        ),
      ),
    );
  }
}
