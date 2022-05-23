import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ignite/models/profile/lol.dart';
import 'package:ignite/pages/dashboard_page.dart';
import 'package:ignite/provider/auth_provider.dart';
import 'package:ignite/provider/page_provider.dart';
import 'package:ignite/provider/profile/lol_profile_provider.dart';
import 'package:provider/provider.dart';

class LOLProfilePage extends StatefulWidget {
  LOLProfilePage({Key? key}) : super(key: key);

  @override
  _LOLProfilePageState createState() => _LOLProfilePageState();
}

class _LOLProfilePageState extends State<LOLProfilePage>
    with SingleTickerProviderStateMixin {
  late AuthProvider _authProvider;
  late PageProvider _pageProvider;
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
        .doc(_authProvider.currentUser!.uid)
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
                          builder: (context) => DashboardPage(),
                        ),
                        (route) => false);
                    Provider.of<PageProvider>(context, listen: false)
                        .updatePage(1);
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
        .doc(_authProvider.currentUser!.uid)
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
    _textFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _pageProvider = Provider.of<PageProvider>(context, listen: false);
    _lolProfileProvider =
        Provider.of<LOLProfileProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('League of Legends')),
      body: _bodyContainer(),
    );
  }

  Widget _bodyContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                errorText:
                    _isEditingText ? _validateText(_textController.text) : null,
                errorStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.redAccent,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    if (_validateText(_textController.text) == null) {
                      setState(() {
                        _searching = true;
                      });
                      await _lolProfileProvider
                          .loadUserProfile(_textController.text);
                      setState(() {
                        _searching = false;
                        _animationController.reset();
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
                    _animationController.reset();
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
                height: _searching
                    ? 0.0
                    : MediaQuery.of(context).size.height * 0.65 -
                        MediaQuery.of(context).viewInsets.bottom,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: _lolProfileProvider.lolUser != null
                    ? _userCard(_lolProfileProvider.lolUser!)
                    : Text('소환사 정보가 없습니다'),
              ),
            ),
          ),
          SizeTransition(
            axisAlignment: 1.0,
            sizeFactor: _animation,
            child: AnimatedOpacity(
              opacity: _searching ? 0.0 : 1.0,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInQuint,
              child: MaterialButton(
                elevation: 0.0,
                minWidth: double.maxFinite,
                height: 50.0,
                onPressed: _lolProfileProvider.lolUser != null
                    ? () async {
                        await _confirmAccountDialog(
                            _lolProfileProvider.lolUser!);
                      }
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                color: _lolProfileProvider.lolUser != null
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: _lolProfileProvider.lolUser != null
                        ? Colors.white
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(LOLUser lolUser) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
            backgroundImage: NetworkImage(
                'https://ddragon.leagueoflegends.com/cdn/12.8.1/img/profileicon/${lolUser.profileIconId}.png'),
            child: Text('${lolUser.summonerLevel}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white))),
        title:
            Text(lolUser.name!, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                  gradient: _lolTierColors(lolUser.soloTier),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                    ),
                  ]),
              child: lolUser.soloTier != null
                  ? Text(
                      '${lolUser.soloTier} ${lolUser.soloRank}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                      ),
                    )
                  : Text(
                      'UNRANKED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _confirmAccountDialog(LOLUser lolUser) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('이 계정이 맞나요?'),
          content: _userCard(lolUser),
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
      },
    );
  }

  LinearGradient? _lolTierColors(String? tier) {
    switch (tier) {
      case 'IRON':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF423730),
            Color(0xFF848482),
          ],
        );
      case 'BRONZE':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF4F1C0D),
            Color(0xFFA96A40),
          ],
        );
      case 'SILVER':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF848482),
            Color(0xFFB0C4DE),
          ],
        );
      case 'GOLD':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFDA9100),
            Color(0xFFFCC201),
          ],
        );
      case 'PLATINUM':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF209BBA),
            Color(0xFFA8D8DF),
          ],
        );
      case 'DIAMOND':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF4467C4),
            Color(0xFF8EC3E6),
          ],
        );
      case 'MASTER':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF5F31A9),
            Color(0xFFCEA7DE),
          ],
        );
      case 'GRANDMASTER':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF4B505A),
            Color(0xFFDE3E25),
          ],
        );
      case 'CHALLENGER':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF7BC1FA),
            Color(0xFFFCC201),
          ],
        );
      case null:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF104730),
            Color(0xFF6D9775),
          ],
        );
    }
  }
}
