import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ignite/pages/get_started_page.dart';
import 'package:ignite/pages/my_pages/my_info_page.dart';
import 'package:ignite/pages/my_pages/notice_page.dart';
import 'package:ignite/pages/my_pages/registration_page.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:ignite/services/service.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class MyPage extends StatefulWidget {
  MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late AuthenticationProvider _authenticationProvider;
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<bool> _isBiometricAvailable() async {
    bool isAvailable = false;
    try {
      isAvailable = await _localAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    } on MissingPluginException catch (e) {
      _missingPluginDialog();
    }

    if (!mounted) return isAvailable;

    return isAvailable;
  }

  Future<void> _getListOfBiometricTypes() async {
    List<BiometricType>? listOfBiometrics;
    try {
      listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    print(listOfBiometrics);
  }

  Future<void> _authenticateUser() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticate(
          localizedReason: '생체 정보 혹은 PIN 번호를 입력하세요',
          androidAuthStrings:
              AndroidAuthMessages(signInTitle: '인증이 필요합니다', biometricHint: ''),
          useErrorDialogs: true,
          stickyAuth: true);
      // if (isAuthenticated) Navigator.push(context, createRoute(MyInfoPage()));
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    if (isAuthenticated) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => MyInfoPage()));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
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
      title: Text('내 정보'),
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          tooltip: '로그아웃',
          onPressed: () async {
            await _authenticationProvider.signOut().then((result) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => GetStartedPage()),
                  (_) => false);
            }).catchError((error) {
              print('Sign Out Error: $error');
            });
          },
        ),
      ],
    );
  }

  Widget _bodyContainer() {
    return Container(
      child: ListView(
        children: [
          InkWell(
              onTap: () async {
                if (await _isBiometricAvailable()) {
                  await _getListOfBiometricTypes();
                  await _authenticateUser();
                }
              },
              child: ListTile(title: Text('내 정보'))),
          InkWell(
              onTap: () {
                Navigator.push(context, createRoute(NoticePage()));
              },
              child: ListTile(title: Text('공지사항'))),
          Divider(height: 10.0, thickness: 10.0),
          InkWell(
            onTap: () {
              Navigator.push(
                  context, createRoute(RegistrationPage(flag: false)));
            },
            child: ListTile(
              title: Text('계정 관리'),
              subtitle: Text('게임 계정을 추가하거나 수정 및 삭제합니다'),
            ),
          ),
          Divider(height: 10.0, thickness: 10.0),
          InkWell(
            onTap: () {},
            child: ListTile(
              title: Text('회원 탈퇴',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  _missingPluginDialog() {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('생체 인식 및 보안 오류'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text('이 기기에는 생체 인식 및 보안 설정이 되어 있지 않습니다.\n설정 후 사용해 주세요.'),
            ),
            const SizedBox(height: 15.0),
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(),
              color: Theme.of(context).primaryColor,
              disabledColor: Colors.grey[350],
              minWidth: double.infinity,
              height: 50,
              child: Text('확인',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
