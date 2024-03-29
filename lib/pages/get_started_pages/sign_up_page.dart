import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ignite/provider/auth_provider.dart';
import 'package:ignite/widgets/dialog.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late AuthProvider _authProvider;

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmController;

  late FocusNode _usernameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _confirmFocusNode;

  bool _isUsernameEditing = false;
  bool _isEmailEditing = false;
  bool _isPasswordEditing = false;
  bool _isConfirmEditing = false;

  bool _isUsernameExists = true;
  bool _isEmailExists = true;

  String _signUpStatus = '';
  Color _signUpStringColor = Colors.green;

  bool _isSigningUp = false;

  _checkUsernameExists(String name) async {
    final firestore = FirebaseFirestore.instance;
    final result = await firestore
        .collection('user')
        .where('username', isEqualTo: name)
        .limit(1)
        .get();

    List<QueryDocumentSnapshot> documents = result.docs;

    if (documents.isNotEmpty)
      _isUsernameExists = true;
    else
      _isUsernameExists = false;
  }

  _checkEmailExists(String email) async {
    final firestore = FirebaseFirestore.instance;
    final result = await firestore
        .collection('user')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    List<QueryDocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty)
      _isEmailExists = true;
    else
      _isEmailExists = false;
  }

  String? _validateUsername(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return 'Username can\'t be empty';
    } else if (!value.contains(RegExp(r'^[A-Za-z]+$'))) {
      return 'Enter a correct username';
    } else if (_isUsernameExists) {
      return 'Username is already exists';
    }
    return null;
  }

  String? _validateEmail(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return 'Email can\'t be empty';
    } else if (!value.contains(RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-_]+\.[a-zA-Z]+"))) {
      return 'Enter a correct email address';
    } else if (_isEmailExists) {
      return 'Email is already exists';
    }
    return null;
  }

  String? _validatePassword(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return 'Password can\'t be empty';
    } else if (value.length < 6) {
      return 'Must be at least 6 characters long';
    }
    return null;
  }

  String? _validateConfirm(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return 'Password can\'t be empty';
    } else if (value.length < 6) {
      return 'Length of password should be greater than 6';
    } else if (value != _passwordController.text.trim()) {
      return 'Password is not matched';
    }
    return null;
  }

  void signUpRequest() async {
    if (_validateUsername(_usernameController.text) == null &&
        _validateEmail(_emailController.text) == null &&
        _validatePassword(_passwordController.text) == null &&
        _validateConfirm(_confirmController.text) == null) {
      await _authProvider
          .signUp(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      )
          .then((result) async {
        if (result == null) {
          setState(() {
            _isSigningUp = false;
            _signUpStatus = '계정 생성이 완료되었습니다';
            _signUpStringColor = Colors.green;
          });
          signUpCompletionDialog(context);
        } else {
          _isSigningUp = false;
          _signUpStatus = result;
          _signUpStringColor = Colors.red;
        }
      });
    } else {
      setState(() {
        _isSigningUp = false;
        _signUpStatus = 'Please enter every text field';
        _signUpStringColor = Colors.red;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    _usernameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Sign up',
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
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: new Border(
                    bottom: new BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                child: TextField(
                  controller: _usernameController,
                  focusNode: _usernameFocusNode,
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).colorScheme.secondary,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    labelText: 'Username',
                    icon: Icon(
                      Icons.person,
                    ),
                    // prefix: Icon(icon),
                    border: InputBorder.none,
                    errorText: _isUsernameEditing
                        ? _validateUsername(_usernameController.text)
                        : null,
                    errorStyle: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    suffixIcon:
                        (_validateUsername(_usernameController.text) != null)
                            ? Icon(Icons.clear, color: Colors.red[900])
                            : Icon(Icons.check, color: Colors.green),
                  ),
                  onChanged: (value) async {
                    await _checkUsernameExists(value);
                    setState(() {
                      _isUsernameEditing = true;
                    });
                  },
                  onSubmitted: (value) {
                    _usernameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_emailFocusNode);
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    border: new Border(
                        bottom: new BorderSide(
                            color: Theme.of(context).colorScheme.secondary))),
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
                    // prefix: Icon(icon),
                    border: InputBorder.none,
                    errorText: _isEmailEditing
                        ? _validateEmail(_emailController.text)
                        : null,
                    errorStyle: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary),
                    suffixIcon: (_validateEmail(_emailController.text) != null)
                        ? Icon(Icons.clear, color: Colors.red[900])
                        : Icon(Icons.check, color: Colors.green),
                  ),
                  onChanged: (value) async {
                    await _checkEmailExists(value);
                    setState(() {
                      _isEmailEditing = true;
                    });
                  },
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
                        bottom: new BorderSide(
                            color: Theme.of(context).colorScheme.secondary))),
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
                      // prefix: Icon(icon),
                      border: InputBorder.none,
                      errorText: _isPasswordEditing
                          ? _validatePassword(_passwordController.text)
                          : null,
                      errorStyle: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isPasswordEditing = true;
                      });
                    },
                    onSubmitted: (value) {
                      _passwordFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(_confirmFocusNode);
                    }),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    border: new Border(
                        bottom: new BorderSide(
                            color: Theme.of(context).colorScheme.secondary))),
                child: TextField(
                  controller: _confirmController,
                  focusNode: _confirmFocusNode,
                  obscureText: true,
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).colorScheme.secondary,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    labelText: 'Confirm Password',
                    icon: Icon(
                      Icons.lock,
                    ),
                    // prefix: Icon(icon),
                    border: InputBorder.none,
                    errorText: _isConfirmEditing
                        ? _validateConfirm(_confirmController.text)
                        : null,
                    errorStyle: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isConfirmEditing = true;
                    });
                  },
                  onSubmitted: (_validateUsername(_usernameController.text) ==
                              null &&
                          _validateEmail(_emailController.text) == null &&
                          _validatePassword(_passwordController.text) == null &&
                          _validateConfirm(_confirmController.text) == null &&
                          !_isSigningUp)
                      ? (value) {
                          setState(() {
                            _isSigningUp = true;
                            _signUpStatus = '';
                            _usernameFocusNode.unfocus();
                            _emailFocusNode.unfocus();
                            _passwordFocusNode.unfocus();
                            _confirmFocusNode.unfocus();
                          });
                          signUpRequest();
                        }
                      : null,
                ),
              ),
              SizedBox(height: 15.0),
              _signUpStatus != null
                  ? Center(
                      child: Text(_signUpStatus,
                          style: TextStyle(
                              color: _signUpStringColor, fontSize: 14.0)))
                  : Container(),
              SizedBox(height: 15.0),
              MaterialButton(
                onPressed: (_validateUsername(_usernameController.text) ==
                            null &&
                        _validateEmail(_emailController.text) == null &&
                        _validatePassword(_passwordController.text) == null &&
                        _validateConfirm(_confirmController.text) == null &&
                        !_isSigningUp)
                    ? () {
                        setState(() {
                          _isSigningUp = true;
                          _signUpStatus = '';
                          _usernameFocusNode.unfocus();
                          _emailFocusNode.unfocus();
                          _passwordFocusNode.unfocus();
                          _confirmFocusNode.unfocus();
                        });
                        signUpRequest();
                      }
                    : null,
                elevation: 0.0,
                minWidth: double.maxFinite,
                height: 50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                color: Theme.of(context).colorScheme.secondary,
                disabledColor: !_isSigningUp ? Colors.grey[350] : null,
                child: !_isSigningUp
                    ? Text(
                        'Sign in',
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      )
                    : Center(child: CircularProgressIndicator()),
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
