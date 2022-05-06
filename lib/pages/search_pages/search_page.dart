import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ignite/pages/search_pages/not_registered_page.dart';
import 'package:ignite/pages/search_pages/registered_page.dart';
import 'package:ignite/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    return Consumer<AuthProvider>(
      builder: (context, value, widget) {
        return StreamBuilder(
          stream: firestore
              .collection('user')
              .doc(value.currentUser!.uid)
              .collection('accounts')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.docs.isNotEmpty) {
                return RegisteredPage(snapshot: snapshot.data!);
              } else if (snapshot.data!.docs.isEmpty) {
                return NotRegisteredPage();
              }
            }
            return _loadingPage();
          },
        );
      },
    );
  }

  Widget _loadingPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover'),
      ),
      body: const Center(
        child: SizedBox(
            height: 30.0, width: 30.0, child: CircularProgressIndicator()),
      ),
    );
  }
}
