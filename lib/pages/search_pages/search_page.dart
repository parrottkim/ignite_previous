import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ignite/pages/search_pages/not_registered_page.dart';
import 'package:ignite/pages/search_pages/registered_page.dart';
import 'package:ignite/provider/authentication_provider.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    return Consumer<AuthenticationProvider>(
      builder: (context, value, widget) {
        return StreamBuilder(
          stream: firestore
              .collection('user')
              .doc(value.currentUser!.uid)
              .collection('accounts')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
            if (snapshot.hasData) {
              return RegisteredPage(snapshot: snapshot.data!);
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return _loadingPage();
            }
            return NotRegisteredPage();
          },
        );
      },
    );
  }

  Widget _loadingPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('동료 찾기'),
      ),
      body: const Center(
        child: SizedBox(
            height: 30.0, width: 30.0, child: CircularProgressIndicator()),
      ),
    );
  }
}
