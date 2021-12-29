import 'package:flutter/material.dart';
import 'package:ignite/pages/dashboard_page.dart';
import 'package:ignite/pages/sign_up_page.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:ignite/provider/bottom_navigation_provider.dart';
import 'package:ignite/services/service.dart';
import 'package:ignite/widgets/dialog.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late AuthenticationProvider _authenticationProvider;
  late BottomNavigationProvider _bottomNavigationProvider;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _resetController;

  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _resetFocusNode;

  String _loginStatus = '';
  Color _loginStringColor = Colors.green;

  void signInRequest() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      await _authenticationProvider
          .signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      )
          .then((result) {
        if (result == null) {
          setState(() {
            _loginStatus = 'You have successfully signed in';
            _loginStringColor = Colors.green;
          });
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardPage(),
            ),
            (_) => false,
          );
          _bottomNavigationProvider.updatePage(0);
        } else if (result == '이메일 주소 인증이 필요합니다') {
          setState(() {
            _loginStatus = result;
            _loginStringColor = Colors.green;
          });
          emailVerificationDialog(context);
        } else {
          setState(() {
            _loginStatus = result;
            _loginStringColor = Colors.red;
          });
        }
      });
    } else {
      setState(() {
        _loginStatus = 'Please enter email & password';
        _loginStringColor = Colors.red;
      });
    }
  }

  _resetPasswordRequest() async {
    if (_resetController.text.isNotEmpty) {
      await _authenticationProvider
          .sendPasswordResetEmail(email: _resetController.text.trim())
          .then((result) {
        if (result) {
          Navigator.pop(context);
          resetPasswordDialog(context);
        } else {
          errorDialog(context);
        }
        _resetFocusNode.unfocus();
        _resetController.clear();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authenticationProvider = Provider.of<AuthenticationProvider>(context);
    _bottomNavigationProvider =
        Provider.of<BottomNavigationProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _resetController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _resetFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _bodyContainer(size),
    );
  }

  Widget _bodyContainer(Size size) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.topCenter,
      fit: StackFit.loose,
      children: [
        Image.asset('assets/images/sign/sign.png'),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: size.height * 0.6,
            width: size.width,
            padding: EdgeInsets.symmetric(vertical: 60.0, horizontal: 30.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.redAccent))),
                  child: TextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        fillColor: Colors.redAccent,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: 'Email',
                        icon: Icon(
                          Icons.email,
                        ),
                        border: InputBorder.none),
                    onSubmitted: (value) {
                      _emailFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      border: new Border(
                          bottom: new BorderSide(color: Colors.redAccent))),
                  child: TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: true,
                    decoration: InputDecoration(
                        fillColor: Colors.redAccent,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: 'Password',
                        icon: Icon(
                          Icons.lock,
                        ),
                        border: InputBorder.none),
                    onSubmitted: (value) {
                      _passwordFocusNode.unfocus();
                      signInRequest();
                    },
                  ),
                ),
                SizedBox(height: 15),
                _loginStatus != null
                    ? Center(
                        child: Text(
                          _loginStatus,
                          style: TextStyle(
                            color: _loginStringColor,
                            fontSize: 14.0,
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(height: 15.0),
                MaterialButton(
                  elevation: 0,
                  minWidth: double.maxFinite,
                  height: 50,
                  onPressed: () {
                    setState(() {
                      _emailFocusNode.unfocus();
                      _passwordFocusNode.unfocus();
                    });
                    signInRequest();
                  },
                  color: Theme.of(context).primaryColor,
                  child: Text('Sign In',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  textColor: Colors.white,
                ),
                SizedBox(height: 15.0),
                _resetPasswordButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _resetPasswordButton() {
    return Container(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () async {
          _resetController.clear();
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('이메일을 입력하세요'),
              content: StatefulBuilder(
                builder: (context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.redAccent))),
                      child: TextField(
                        controller: _resetController,
                        focusNode: _resetFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            fillColor: Theme.of(context).primaryColor,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            labelText: 'Email',
                            icon: const Icon(Icons.email),
                            // prefix: Icon(icon),
                            border: InputBorder.none),
                        onSubmitted: (value) {
                          _resetPasswordRequest();
                        },
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    MaterialButton(
                      onPressed: () {
                        _resetPasswordRequest();
                      },
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
            ),
          );
        },
        child: Text(
          'Forgot Password?',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
