import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ignite/pages/dashboard_page.dart';
import 'package:ignite/provider/profile_page_provider.dart';
import 'package:ignite/services/service.dart';
import 'package:provider/provider.dart';

class RegistrationPage extends StatefulWidget {
  final bool flag;
  RegistrationPage({Key? key, required this.flag}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  late ProfilePageProvider _profilePageProvider;

  Map _images = Map<String, Image>();
  bool _imageLoaded = false;

  Future preloadImages() async {
    await firestore.collection('gamelist').get().then((snapshots) {
      snapshots.docs.forEach((element) {
        _images.putIfAbsent(element.data()['id'],
            () => Image.network(element.data()['imageLink']));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    preloadImages().then((_) {
      _images.forEach((key, value) async {
        await precacheImage(value.image, context).then((_) {
          if (mounted) setState(() {});
        });
        _imageLoaded = true;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profilePageProvider =
        Provider.of<ProfilePageProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _registrationPageAppBar(),
      body: _imageLoaded
          ? _registrationPageBody()
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(child: CircularProgressIndicator())),
    );
  }

  AppBar _registrationPageAppBar() {
    return AppBar(
      title: Text('게임 등록'),
      actions: [
        if (widget.flag)
          IconButton(
            icon: Icon(Icons.skip_next),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardPage(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _registrationPageBody() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder(
        future: firestore.collection('gamelist').orderBy('rank').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(child: CircularProgressIndicator()));

          return GridView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              return Card(
                elevation: 0.4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(0.0),
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => MultiProvider(
                    //       providers: [
                    //         ChangeNotifierProvider(
                    //             create: (_) =>
                    //                 AuthenticationProvider(
                    //                     FirebaseAuth.instance)),
                    //         ChangeNotifierProvider(
                    //             create: (_) =>
                    //                 LOLProfileProvider()),
                    //       ],
                    //       child: _profilePageProvider.getPage(
                    //         snapshot.data.docs[index]
                    //             .data()['name'],
                    //       ),
                    //     ),
                    //   ),
                    // );

                    Navigator.push(
                        context,
                        createRoute(_profilePageProvider
                            .getPage(snapshot.data!.docs[index]['name'])));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _images[snapshot.data!.docs[index]['id']],
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: Divider(height: 10.0)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          snapshot.data!.docs[index]['name'],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
