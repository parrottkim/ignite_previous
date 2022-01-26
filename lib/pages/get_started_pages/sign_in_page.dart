import 'package:flutter/material.dart';
import 'package:ignite/pages/dashboard_page.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:ignite/provider/bottom_navigation_provider.dart';
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
        if (result.isEmpty) {
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
    return AlertDialog(
      content: _dialogContent(),
    );
  }

  Widget _dialogContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Sign in',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontFamily: 'BarlowSemiCondensed',
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            child: TextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              autofillHints: [AutofillHints.email],
              decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.secondary,
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
            padding: EdgeInsets.symmetric(vertical: 5.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            child: TextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              keyboardType: TextInputType.text,
              autofillHints: [AutofillHints.password],
              obscureText: true,
              decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.secondary,
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
          _loginStatus.isNotEmpty
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
            elevation: 0.0,
            minWidth: double.maxFinite,
            height: 50.0,
            onPressed: () {
              setState(() {
                _emailFocusNode.unfocus();
                _passwordFocusNode.unfocus();
              });
              signInRequest();
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              'Sign in',
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ),
          SizedBox(height: 15.0),
          _resetPasswordButton(),
        ],
      ),
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
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
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
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
