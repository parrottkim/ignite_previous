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
  bool _isPositionSelected = false;

  String? _selectedPosition;
  final Map<String, String> _positions = {
    'Top': 'top',
    'Jungle': 'jungle',
    'Mid': 'mid',
    'Bottom': 'bottom',
    'Support': 'support'
  };

  String _selectedType = 'solo';
  final Map<String, String> _types = {
    'Solo': 'solo',
    'Flex': 'flex',
    'Normal': 'normal',
    'ARAM': 'aram',
  };

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
        _isPositionSelected) {
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
                    'game': 'lol',
                    'lane': _selectedPosition!,
                    'title': _titleController.text,
                    'content': _contentController.text,
                    'type': _selectedType,
                    'user': _authenticationProvider.currentUser!.uid,
                    'date': DateTime.now(),
                  });
                  Navigator.pop(context);
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
            'League of Legends',
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
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 1.0),
            _userInformation(),
            Divider(height: 1.0),
            SizedBox(height: 20.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _queueType(),
                  SizedBox(width: 30.0),
                  _mainRole(),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                decoration: InputDecoration(
                    fillColor: Colors.redAccent,
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent)),
                    labelText: 'Title',
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
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: TextField(
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
                  if (lolUser != null &&
                      _validateText(_titleController.text) == null &&
                      _validateText(_contentController.text) == null &&
                      _isPositionSelected) _uploadContent();
                },
              ),
            ),
            SizedBox(height: 20.0),
            MaterialButton(
              onPressed: lolUser != null &&
                      _validateText(_titleController.text) == null &&
                      _validateText(_contentController.text) == null &&
                      _isPositionSelected
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
    if (lolUser != null) {
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              'https://ddragon.leagueoflegends.com/cdn/11.6.1/img/profileicon/${lolUser!.profileIconId}.png'),
          child: Text(
            '${lolUser!.summonerLevel}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.0,
            ),
          ),
        ),
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
      return _shimmer();
    }
  }

  Widget _mainRole() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MAIN ROLE', style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 6.0),
        SizedBox(
          height: 34.0,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: _positions.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              String key = _positions.keys.elementAt(index);
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedPosition = _positions[key];
                    _isPositionSelected = true;
                  });
                },
                child: Container(
                  color: _selectedPosition == _positions[key]
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  width: 34.0,
                  height: 34.0,
                  child: Image.asset(
                      'assets/images/game_icons/lol_lanes/${_positions[key]}.png',
                      color: _selectedPosition == _positions[key]
                          ? Colors.white
                          : null),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(width: 4.0);
            },
          ),
        ),
      ],
    );
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

class PositionItem {
  final String description;
  final String key;
  final Widget? widget;
  const PositionItem(this.description, this.key, this.widget);
}
