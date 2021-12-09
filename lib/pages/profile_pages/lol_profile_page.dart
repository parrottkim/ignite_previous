import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ignite/models/profile/lol.dart';
import 'package:ignite/pages/dashboard_page.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:ignite/provider/bottom_navigation_provider.dart';
import 'package:ignite/provider/profile/lol_profile_provider.dart';
import 'package:provider/provider.dart';

class LOLProfilePage extends StatefulWidget {
  LOLProfilePage({Key? key}) : super(key: key);

  @override
  _LOLProfilePageState createState() => _LOLProfilePageState();
}

class _LOLProfilePageState extends State<LOLProfilePage>
    with SingleTickerProviderStateMixin {
  late AuthenticationProvider _authenticationProvider;
  late BottomNavigationProvider _bottomNavigationProvider;
  late LOLProfileProvider _lolProfileProvider;

  final firestore = FirebaseFirestore.instance;

  late AnimationController _animationController;
  late Animation<double> _animation;

  late TextEditingController _textController;
  late FocusNode _textFocusNode;
  bool _isEditingText = false;

  bool _searching = false;

  String? _validateText(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return 'Username can\'t be empty';
    }
    return null;
  }

  _addSummonerDialog(LOLUser lolUser) async {
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
    }).then((value) async {
      Navigator.pop(context);
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('등록 완료!'),
              content: Text('유저 정보가 계정에 추가되었습니다\n수정이나 삭제는 \'내 정보\'에서 가능합니다'),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardPage(index: 1),
                        ),
                        (route) => false);
                    _bottomNavigationProvider.updatePage(1);
                  },
                  child: Text('확인'),
                ),
              ],
            );
          });
    });
    Navigator.pop(context);
  }

  _addSummonerData(LOLUser lolUser) async {
    await firestore
        .collection('user')
        .doc(_authenticationProvider.currentUser!.uid)
        .collection('accounts')
        .doc('lol')
        .get()
        .then((value) async {
      if (value.exists) {
        Navigator.pop(context);
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text('어라?'),
                  content:
                      Text('이미 소환사 정보가 등록되어 있습니다\n\'네\'를 누르면 기존 정보를 덮어씌웁니다'),
                  actions: [
                    MaterialButton(
                      onPressed: () async {
                        _addSummonerDialog(lolUser);
                      },
                      child: Text('네'),
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('아니오'),
                    ),
                  ]);
            });
      } else {
        _addSummonerDialog(lolUser);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
    _animation.addListener(() => setState(() {}));

    _textController = TextEditingController();
    _textController.text = '';
    _textFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _bottomNavigationProvider =
        Provider.of<BottomNavigationProvider>(context, listen: false);
    _lolProfileProvider =
        Provider.of<LOLProfileProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('League of Legends')),
        body: _makeSearchTextField(),
      ),
    );
  }

  Widget _makeUserCard(LOLUser? lolUser) {
    if (lolUser != null) {
      return Card(
        child: InkWell(
          onTap: () async {
            await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('이 계정이 맞나요?'),
                    content: ListTile(
                      leading: CircleAvatar(
                          backgroundImage: NetworkImage(lolUser.profileIconUrl),
                          child: Text('${lolUser.summonerLevel}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))),
                      title: Text(lolUser.name!,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: lolUser.soloTier != null &&
                              lolUser.soloRank != null
                          ? Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                      text:
                                          '${lolUser.soloTier} ${lolUser.soloRank}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  TextSpan(text: ' | '),
                                  TextSpan(
                                      text: '${lolUser.soloLeaguePoints}LP',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            )
                          : Text('UNRANKED',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    actions: [
                      MaterialButton(
                        onPressed: () async {
                          await _addSummonerData(lolUser);
                        },
                        child: Text('네'),
                      ),
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('아니요'),
                      ),
                    ],
                  );
                });
          },
          child: ListTile(
            leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://ddragon.leagueoflegends.com/cdn/11.6.1/img/profileicon/${lolUser.profileIconId}.png'),
                child: Text('${lolUser.summonerLevel}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            title: Text(lolUser.name!,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: lolUser.soloTier != null && lolUser.soloRank != null
                ? Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: '${lolUser.soloTier} ${lolUser.soloRank}',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        TextSpan(text: ' | '),
                        TextSpan(
                            text: '${lolUser.soloLeaguePoints}LP',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                : Text('UNRANKED',
                    style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: Icon(Icons.keyboard_arrow_right),
          ),
        ),
      );
    } else
      return Text('소환사 정보가 없습니다');
  }

  Widget _makeSearchTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: new Border(
                  bottom: new BorderSide(color: Colors.redAccent),
                ),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _textFocusNode,
                autofocus: true,
                decoration: InputDecoration(
                  fillColor: Colors.redAccent,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  labelText: 'Summoner\'s Name',
                  icon: Icon(Icons.person),
                  border: InputBorder.none,
                  errorText: _isEditingText
                      ? _validateText(_textController.text)
                      : null,
                  errorStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.redAccent,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () async {
                      setState(() {
                        _searching = true;
                      });
                      if (_validateText(_textController.text) == null) {
                        await _lolProfileProvider
                            .loadUserProfile(_textController.text);
                        setState(() {
                          _searching = false;
                        });
                        _animationController.forward();
                      }
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _isEditingText = true;
                  });
                },
                onSubmitted: (value) async {
                  if (_validateText(_textController.text) == null) {
                    setState(() {
                      _searching = true;
                    });
                    await _lolProfileProvider
                        .loadUserProfile(_textController.text);
                    setState(() {
                      _searching = false;
                    });
                    _animationController.forward();
                  }
                },
              ),
            ),
            SizeTransition(
              axisAlignment: 1.0,
              sizeFactor: _animation,
              child: AnimatedOpacity(
                opacity: _searching ? 0.0 : 1.0,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInQuint,
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.8,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: _makeUserCard(_lolProfileProvider.lolUser),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
