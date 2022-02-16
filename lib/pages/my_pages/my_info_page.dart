import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:ignite/widgets/circular_progress_widget.dart';
import 'package:ignite/widgets/dialog.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io' as i;

import 'package:provider/provider.dart';

class MyInfoPage extends StatefulWidget {
  MyInfoPage({Key? key}) : super(key: key);

  @override
  _MyInfoPageState createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage> {
  late AuthenticationProvider _authenticationProvider;

  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  late i.File? _image;
  final _picker = ImagePicker();

  late TextEditingController _usernameController;
  late TextEditingController _resetController;

  late FocusNode _usernameFocusNode;
  late FocusNode _resetFocusNode;

  bool _isUsernameEditing = false;
  bool _isUsernameExists = true;

  Future getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = i.File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });

    String extension = pickedFile!.path.split('.').last;
    if (extension == 'webp') {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text('오류'),
                content: Text('.webp, .gif 확장자는 지원하지 않습니다.'),
                actions: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ));
    } else {
      var path = 'ProfileImages/${_authenticationProvider.currentUser!.uid}';

      var task = storage.ref(path).putFile(i.File(pickedFile.path));
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 1.0,
                  child: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white)),
                ),
              ],
            );
          });
      await task;
      Navigator.of(context).pop();
      String downloadUrl = await storage.ref(path).getDownloadURL();
      print(downloadUrl);
      await firestore
          .collection('user')
          .doc(_authenticationProvider.currentUser!.uid)
          .set({'avatar': downloadUrl}, SetOptions(merge: true));
    }
  }

  _checkUsernameExists(String name) async {
    final firestore = FirebaseFirestore.instance;
    final result = await firestore
        .collection('user')
        .where('username', isEqualTo: name)
        .limit(1)
        .get();

    List<QueryDocumentSnapshot> documents = result.docs;
    if (documents.length > 0)
      _isUsernameExists = true;
    else
      _isUsernameExists = false;
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

  Future _changeUsername(String username) async {
    _authenticationProvider.currentUser!.updateDisplayName(username);
    await firestore
        .collection('user')
        .doc(_authenticationProvider.currentUser!.uid)
        .set({
      'username': username,
    }, SetOptions(merge: true));
  }

  _resetPasswordRequest(String email) async {
    await _authenticationProvider
        .sendPasswordResetEmail(email: email)
        .then((result) {
      if (result) {
        resetPasswordDialog(context);
      } else {
        errorDialog(context);
      }
      _resetFocusNode.unfocus();
      _resetController.clear();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _resetController = TextEditingController();
    _usernameFocusNode = FocusNode();
    _resetFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("내 정보"),
      ),
      body: _bodyContainer(),
    );
  }

  Widget _bodyContainer() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: StreamBuilder(
        stream: firestore
            .collection('user')
            .doc(_authenticationProvider.currentUser!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressWidget();
          } else {
            return Column(
              children: <Widget>[
                Container(
                  width: 200.0,
                  height: 200.0,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.grey,
                          backgroundImage: snapshot.data!['avatar'] != ""
                              ? NetworkImage(snapshot.data!['avatar'])
                              : null,
                          child: snapshot.data!['avatar'] != ""
                              ? null
                              : Icon(
                                  Icons.person,
                                  size: 160.0,
                                  color: Colors.grey[400],
                                ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          onPressed: () async {
                            getImage();
                          },
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('사용자 이름',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16.0)),
                      Row(
                        children: <Widget>[
                          Text(snapshot.data!['username'],
                              style: TextStyle(fontSize: 16.0)),
                          SizedBox(width: 10.0),
                          _changeUsernameButton(),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('이메일',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16.0)),
                      Text(snapshot.data!['email'],
                          style: TextStyle(fontSize: 16.0)),
                    ],
                  ),
                ),
                SizedBox(height: 30.0),
                Divider(height: 1.0),
                SizedBox(height: 10.0),
                _resetPasswordButton(snapshot.data!['email']),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _changeUsernameButton() {
    return InkWell(
      onTap: () async {
        _isUsernameEditing = false;
        _usernameController.clear();
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('사용자 이름 변경'),
            content: StatefulBuilder(
              builder: (context, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.redAccent))),
                    child: TextField(
                      controller: _usernameController,
                      focusNode: _usernameFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        fillColor: Theme.of(context).primaryColor,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10.0),
                        labelText: 'Username',
                        icon: const Icon(Icons.person),
                        // prefix: Icon(icon),
                        border: InputBorder.none,
                        errorText: _isUsernameEditing
                            ? _validateUsername(_usernameController.text)
                            : null,
                        errorStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.redAccent,
                        ),
                        suffixIcon:
                            _validateUsername(_usernameController.text) != null
                                ? Icon(Icons.clear, color: Colors.red[900])
                                : Icon(Icons.check, color: Colors.green),
                      ),
                      onChanged: (value) async {
                        await _checkUsernameExists(value);
                        setState(() {
                          _isUsernameEditing = true;
                        });
                      },
                      onSubmitted: (value) async {
                        _usernameFocusNode.unfocus();
                        _validateUsername(_usernameController.text) == null
                            ? await _changeUsername(_usernameController.text)
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  MaterialButton(
                    onPressed:
                        _validateUsername(_usernameController.text) == null
                            ? () async {
                                await _changeUsername(_usernameController.text);
                                Navigator.of(context).pop();
                                setState(() {
                                  _usernameFocusNode.unfocus();
                                });
                              }
                            : null,
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
      child: Container(
        padding: EdgeInsets.all(12.0),
        child: Icon(Icons.edit),
      ),
    );
  }

  Widget _resetPasswordButton(String email) {
    return InkWell(
      onTap: () async {
        _resetController.clear();
        await _resetPasswordRequest(email);
      },
      child: Container(
        padding: EdgeInsets.all(12.0),
        child: Text('비밀번호 변경'),
      ),
    );
  }
}
