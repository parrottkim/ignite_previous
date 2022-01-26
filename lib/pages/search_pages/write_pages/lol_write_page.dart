// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ignite/models/profile/lol.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:ignite/provider/profile/lol_profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class LOLWritePage extends StatefulWidget {
  LOLWritePage({Key? key}) : super(key: key);

  @override
  _LOLWritePageState createState() => _LOLWritePageState();
}

class _LOLWritePageState extends State<LOLWritePage> {
  late AuthenticationProvider _authenticationProvider;
  late LOLProfileProvider _lolProfileProvider;

  LOLUser? lolUser;

  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  late TextEditingController _titleController;
  late TextEditingController _contentController;

  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;

  bool _isTitleEditing = false;
  bool _isContentEditing = false;
  bool _isItemSelected = false;

  DropdownItem? _selectedPosition;
  final List<DropdownItem> _items = <DropdownItem>[
    DropdownItem(
      '탑',
      'top',
      Image.asset(
        'assets/images/game_icons/lol_lanes/top.png',
        height: 16.0,
        width: 16.0,
      ),
    ),
    DropdownItem(
        '정글',
        'jungle',
        Image.asset(
          'assets/images/game_icons/lol_lanes/jungle.png',
          height: 16.0,
          width: 16.0,
        )),
    DropdownItem(
      '미드',
      'mid',
      Image.asset(
        'assets/images/game_icons/lol_lanes/mid.png',
        height: 16.0,
        width: 16.0,
      ),
    ),
    DropdownItem(
      '바텀',
      'bottom',
      Image.asset(
        'assets/images/game_icons/lol_lanes/bottom.png',
        height: 16.0,
        width: 16.0,
      ),
    ),
    DropdownItem(
      '서포터',
      'support',
      Image.asset(
        'assets/images/game_icons/lol_lanes/support.png',
        height: 16.0,
        width: 16.0,
      ),
    ),
  ];

  Future _refreshGameProfile() async {
    await firestore
        .collection('user')
        .doc(_authenticationProvider.currentUser!.uid)
        .collection('accounts')
        .doc('lol')
        .get()
        .then((element) async {
      final username = element['name'];

      await _lolProfileProvider.loadUserProfile(username);
      lolUser = _lolProfileProvider.lolUser;

      await firestore
          .collection('user')
          .doc(_authenticationProvider.currentUser!.uid)
          .collection('accounts')
          .doc('lol')
          .set({
        'id': lolUser!.id,
        'name': lolUser!.name,
        'profileIconId': lolUser!.profileIconId,
        'summonerLevel': lolUser!.summonerLevel,
        'soloTier': lolUser!.soloTier,
        'soloRank': lolUser!.soloRank,
        'soloLeaguePoints': lolUser!.soloLeaguePoints,
        'flexTier': lolUser!.flexTier,
        'flexRank': lolUser!.flexRank,
        'flexLeaguePoints': lolUser!.flexLeaguePoints,
      });
    });
  }

  void _uploadContent() async {
    LOLUser lolUser = _lolProfileProvider.lolUser!;

    if (_validateText(_titleController.text) == null &&
        _validateText(_contentController.text) == null &&
        _isItemSelected) {
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
                    await firestore
                        .collection('user')
                        .doc(_authenticationProvider.currentUser!.uid)
                        .collection('accounts')
                        .doc('lol')
                        .set({
                      'id': lolUser.id,
                      'name': lolUser.name,
                      'profileIconId': lolUser.profileIconId,
                      'summonerLevel': lolUser.summonerLevel,
                      'soloTier': lolUser.soloTier,
                      'soloRank': lolUser.soloRank,
                      'soloLeaguePoints': lolUser.soloLeaguePoints,
                      'flexTier': lolUser.flexTier,
                      'flexRank': lolUser.flexRank,
                      'flexLeaguePoints': lolUser.flexLeaguePoints,
                    });
                    await firestore.collection('board').add({
                      'game': 'lol',
                      'lane': _selectedPosition!.position,
                      'title': _titleController.text,
                      'content': _contentController.text,
                      'user': _authenticationProvider.currentUser!.uid,
                      'date': DateTime.now(),
                    });
                    Navigator.pop(context);
                    Navigator.pop(context, 0);
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
          });
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
    _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _lolProfileProvider =
        Provider.of<LOLProfileProvider>(context, listen: false);

    _refreshGameProfile().then(
      (_) => setState(
        () => lolUser = _lolProfileProvider.lolUser,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _bodyContainer(),
    );
  }

  Widget _bodyContainer() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 1.0),
            _userInformation(),
            Divider(height: 1.0),
            SizedBox(height: 20.0),
            Text('주 포지션', style: TextStyle(fontWeight: FontWeight.w500)),
            DropdownButton<DropdownItem>(
              hint: Text('포지션'),
              value: _selectedPosition,
              onChanged: (DropdownItem? value) {
                setState(() {
                  _selectedPosition = value;
                  _isItemSelected = true;
                });
              },
              items: _items.map((DropdownItem item) {
                return DropdownMenuItem<DropdownItem>(
                    value: item,
                    child: Row(
                      children: <Widget>[
                        item.image,
                        SizedBox(width: 10.0),
                        Text(item.name),
                      ],
                    ));
              }).toList(),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                decoration: InputDecoration(
                    fillColor: Colors.redAccent,
                    enabledBorder: new UnderlineInputBorder(
                        borderSide: new BorderSide(color: Colors.redAccent)),
                    labelText: '글 제목',
                    errorText: _isTitleEditing
                        ? _validateText(_titleController.text)
                        : null),
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
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: TextField(
                controller: _contentController,
                focusNode: _contentFocusNode,
                maxLines: null,
                maxLength: 140,
                decoration: InputDecoration(
                  fillColor: Colors.redAccent,
                  enabledBorder: new UnderlineInputBorder(
                      borderSide: new BorderSide(color: Colors.redAccent)),
                  labelText: '글 내용',
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
                  _uploadContent();
                },
              ),
            ),
            SizedBox(height: 20.0),
            MaterialButton(
              onPressed: (_validateText(_titleController.text) == null &&
                      _validateText(_contentController.text) == null &&
                      _isItemSelected)
                  ? () {
                      _uploadContent();
                    }
                  : null,
              color: Theme.of(context).colorScheme.primary,
              disabledColor: Colors.grey[350],
              minWidth: double.infinity,
              height: 50,
              child: Text('등록',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _userInformation() {
    if (lolUser != null) {
      return ListTile(
        leading: CircleAvatar(
            backgroundImage: NetworkImage(
                'https://ddragon.leagueoflegends.com/cdn/11.6.1/img/profileicon/${lolUser!.profileIconId}.png'),
            child: Text('${lolUser!.summonerLevel}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        title:
            Text(lolUser!.name!, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: lolUser!.soloTier != null && lolUser!.soloRank != null
            ? Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                        text: '${lolUser!.soloTier} ${lolUser!.soloRank}',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    TextSpan(text: ' | '),
                    TextSpan(
                        text: '${lolUser!.soloLeaguePoints}LP',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            : Text('UNRANKED', style: TextStyle(fontWeight: FontWeight.w500)),
      );
    } else {
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
}

class DropdownItem {
  final String name;
  final String position;
  final Image image;
  const DropdownItem(this.name, this.position, this.image);
}
