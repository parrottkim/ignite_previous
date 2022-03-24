import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ignite/animations/fade_animations.dart';
import 'package:ignite/services/service.dart';
import 'package:ignite/widgets/circular_progress_widget.dart';

class ProSettingsPage extends StatefulWidget {
  ProSettingsPage({Key? key}) : super(key: key);

  @override
  State<ProSettingsPage> createState() => _ProSettingsPageState();
}

class _ProSettingsPageState extends State<ProSettingsPage> {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: _bodyContainer(size),
    );
  }

  Widget _bodyContainer(Size size) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _mainBanner(size),
          SizedBox(height: 20.0),
          _gameList(size),
        ],
      ),
    );
  }

  Widget _mainBanner(Size size) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.primary,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeAnimation(
                duration: Duration(milliseconds: 500),
                delay: Duration(milliseconds: 500),
                offset: Offset(10.0, 0.0),
                child: Text(
                  'Find everything\nfrom your favorite pro players.',
                  style: TextStyle(
                    fontSize: 24,
                    // fontFamily: 'BebasNeue',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              FadeAnimation(
                duration: Duration(milliseconds: 500),
                delay: Duration(milliseconds: 750),
                offset: Offset(10.0, 0.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: TextField(
                    // controller: _passwordController,
                    // focusNode: _passwordFocusNode,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Search for Player',
                      icon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _gameList(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Find by game',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10.0),
        FutureBuilder<QuerySnapshot>(
          future: firestore.collection('gamelist').orderBy('rank').get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return CircularProgressWidget();
            else {
              return SizedBox(
                height: size.height * 0.1 + 60.0,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 0.4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(0.0),
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     createRoute(_profilePageProvider
                          //         .getPage(snapshot.data!.docs[index]['name'])));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.network(
                                snapshot.data!.docs[index]['imageLink'],
                                height: size.height * 0.1),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30.0),
                                child: Divider(height: 10.0)),
                            Container(
                              width: 100.0,
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
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
