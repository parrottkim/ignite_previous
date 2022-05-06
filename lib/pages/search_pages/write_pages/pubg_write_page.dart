import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ignite/models/profile/pubg.dart';
import 'package:ignite/provider/auth_provider.dart';
import 'package:ignite/provider/profile/pubg_profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PUBGWritePage extends StatefulWidget {
  PUBGWritePage({Key? key}) : super(key: key);

  @override
  _PUBGWritePageState createState() => _PUBGWritePageState();
}

class _PUBGWritePageState extends State<PUBGWritePage> {
  late AuthProvider _authProvider;
  late PUBGProfileProvider _pubgProfileProvider;

  PUBGUser? pubgUser;

  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  late TextEditingController _titleController;
  late TextEditingController _contentController;

  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;

  bool _isTitleEditing = false;
  bool _isContentEditing = false;

  String _selectedType = 'squads';
  final Map<String, String> _types = {
    'Duos': 'duos',
    'Duos FPP': 'duos-fpp',
    'Squads': 'squads',
    'Squads FPP': 'squads-fpp',
    'Ranked': 'ranked',
    'Ranked FPP': 'ranked-fpp',
  };

  Future _refreshGameProfile() async {
    await firestore
        .collection('user')
        .doc(_authProvider.currentUser!.uid)
        .collection('accounts')
        .doc('pubg')
        .get()
        .then((element) async {
      final username = element['name'];
      final server = element['server'];

      await _pubgProfileProvider.loadUserProfile(username, server);
      pubgUser = _pubgProfileProvider.pubgUser;

      await firestore
          .collection('user')
          .doc(_authProvider.currentUser!.uid)
          .collection('accounts')
          .doc('pubg')
          .set({
        'server': server,
        'accountId': pubgUser!.accountId,
        'name': pubgUser!.name,
        'profileImage': pubgUser!.profileImage,
        'soloTier': pubgUser!.soloTier,
        'soloRank': pubgUser!.soloRank,
        'soloPoints': pubgUser!.soloPoints,
        'squadTier': pubgUser!.squadTier,
        'squadRank': pubgUser!.squadRank,
        'squadPoints': pubgUser!.squadPoints,
      });
    });
  }

  void _uploadContent() async {
    if (_validateText(_titleController.text) == null &&
        _validateText(_contentController.text) == null) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('작성 완료!'),
            content: Text('작성이 완료되었습니다.\n업로드 하시겠어요?'),
            actions: [
              MaterialButton(
                onPressed: () async {
                  await firestore.collection('board').add({
                    'game': 'pubg',
                    'title': _titleController.text,
                    'content': _contentController.text,
                    'type': _selectedType,
                    'user': _authProvider.currentUser!.uid,
                    'date': DateTime.now(),
                    'userinfo': {
                      'username': _pubgProfileProvider.pubgUser!.name,
                      'server': _pubgProfileProvider.pubgUser!.server,
                      'profileImage':
                          _pubgProfileProvider.pubgUser!.profileImage,
                    }
                  });
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context, 1);
                },
                child: Text('예'),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('아니오'),
              ),
            ],
          );
        },
      );
    }
  }

  String? _validateText(String value) {
    value = value.trim();
    if (value.isEmpty) {
      return '내용을 입력해주세요';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _pubgProfileProvider =
        Provider.of<PUBGProfileProvider>(context, listen: false);

    _refreshGameProfile().then(
      (_) => setState(
        () => pubgUser = _pubgProfileProvider.pubgUser,
      ),
    );
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
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New post'),
          Text(
            'Playerunknown\'s Battlegrounds',
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyContainer() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 26.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 1.0),
            _userInformation(),
            Divider(height: 1.0),
            SizedBox(height: 20.0),
            _queueType(),
            TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              decoration: InputDecoration(
                fillColor: Colors.redAccent,
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent)),
                labelText: 'Title',
                errorText: _isTitleEditing
                    ? _validateText(_titleController.text)
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _isTitleEditing = true;
                });
              },
              onSubmitted: (value) {
                _titleFocusNode.unfocus();
                FocusScope.of(context).requestFocus(_contentFocusNode);
              },
            ),
            TextField(
              controller: _contentController,
              focusNode: _contentFocusNode,
              maxLines: null,
              maxLength: 140,
              decoration: InputDecoration(
                fillColor: Colors.redAccent,
                enabledBorder: new UnderlineInputBorder(
                    borderSide: new BorderSide(color: Colors.redAccent)),
                labelText: 'Content',
                errorText: _isContentEditing
                    ? _validateText(_contentController.text)
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _isContentEditing = true;
                });
              },
              onSubmitted: (value) {
                _contentFocusNode.unfocus();
                if (pubgUser != null &&
                    _validateText(_titleController.text) == null &&
                    _validateText(_contentController.text) == null)
                  _uploadContent();
              },
            ),
            SizedBox(height: 20.0),
            MaterialButton(
              onPressed: pubgUser != null &&
                      _validateText(_titleController.text) == null &&
                      _validateText(_contentController.text) == null
                  ? () => _uploadContent()
                  : null,
              elevation: 0.0,
              minWidth: double.maxFinite,
              height: 50.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              color: Theme.of(context).colorScheme.primary,
              disabledColor: Colors.grey[350],
              child: Text('Register',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userInformation() {
    if (pubgUser != null) {
      return ListTile(
        leading: pubgUser!.profileImage != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(pubgUser!.profileImage!),
              )
            : CircleAvatar(),
        title: Text(pubgUser!.name!,
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: pubgUser!.squadTier != null && pubgUser!.squadRank != null
            ? Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                        text: '${pubgUser!.squadTier} ${pubgUser!.squadRank}',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    TextSpan(text: ' | '),
                    TextSpan(
                        text: '${pubgUser!.squadPoints}',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            : Text('UNRANKED', style: TextStyle(fontWeight: FontWeight.w500)),
      );
    } else {
      return _shimmer();
    }
  }

  Widget _queueType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('QUEUE TYPE', style: TextStyle(fontWeight: FontWeight.w500)),
        DropdownButton<String>(
          value: _selectedType,
          onChanged: (String? value) {
            setState(() {
              _selectedType = value!;
            });
          },
          items: _types
              .map((description, value) {
                return MapEntry(
                    description,
                    DropdownMenuItem<String>(
                      value: value,
                      child: Text(description),
                    ));
              })
              .values
              .toList(),
        ),
      ],
    );
  }

  Widget _shimmer() {
    return SizedBox(
      height: 70.0,
      child: ListTile(
        leading: Shimmer.fromColors(
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          baseColor: Colors.grey.withOpacity(0.1),
          highlightColor: Colors.grey.withOpacity(0.3),
        ),
        title: Shimmer.fromColors(
          child: Container(
            height: 16.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
          ),
          baseColor: Colors.grey.withOpacity(0.1),
          highlightColor: Colors.grey.withOpacity(0.3),
        ),
        subtitle: Shimmer.fromColors(
          child: Container(
            height: 12.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
          ),
          baseColor: Colors.grey.withOpacity(0.1),
          highlightColor: Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }
}
