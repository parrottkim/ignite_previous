import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WritePostPage extends StatefulWidget {
  QuerySnapshot snapshot;
  WritePostPage({Key? key, required this.snapshot}) : super(key: key);

  @override
  _WritePostPageState createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
