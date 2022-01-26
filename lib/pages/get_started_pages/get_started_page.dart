import 'package:flutter/material.dart';
import 'package:ignite/animations/fade_animations.dart';
import 'package:ignite/pages/get_started_pages/sign_in_page.dart';
import 'package:ignite/pages/get_started_pages/sign_up_page.dart';
import 'package:ignite/services/service.dart';
import 'package:video_player/video_player.dart';

class GetStartedPage extends StatefulWidget {
  GetStartedPage({Key? key}) : super(key: key);

  @override
  _GetStartedPageState createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videos/get_started.mp4')
      ..initialize().then((_) {
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleWidget(),
                SizedBox(height: 20.0),
                _signInButton(),
                SizedBox(height: 10.0),
                _signUpButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleWidget() {
    var textSpan1 = const TextSpan(
      children: [
        TextSpan(
          text: 'PLAY',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 2.0,
            height: 0.6,
            fontFamily: 'BebasNeue',
            fontWeight: FontWeight.w900,
            fontSize: 60.0,
          ),
        ),
        TextSpan(
          text: '.\n',
          style: TextStyle(
            color: Colors.redAccent,
            letterSpacing: 1.0,
            height: 0.6,
            fontFamily: 'BebasNeue',
            fontWeight: FontWeight.w900,
            fontSize: 60.0,
          ),
        ),
      ],
    );

    var textSpan2 = const TextSpan(
      children: [
        TextSpan(
          text: 'TOGETHER',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 2.0,
            height: 0.6,
            fontFamily: 'BebasNeue',
            fontWeight: FontWeight.w900,
            fontSize: 60.0,
          ),
        ),
        TextSpan(
          text: '.',
          style: TextStyle(
            color: Colors.redAccent,
            letterSpacing: 2.0,
            height: 0.6,
            fontFamily: 'BebasNeue',
            fontWeight: FontWeight.w900,
            fontSize: 60.0,
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeAnimation(
          duration: Duration(milliseconds: 500),
          delay: Duration(milliseconds: 1500),
          offset: Offset(-10.0, 0.0),
          child: Text.rich(textSpan1),
        ),
        FadeAnimation(
          duration: Duration(milliseconds: 500),
          delay: Duration(milliseconds: 1750),
          offset: Offset(-10.0, 0.0),
          child: Text.rich(textSpan2),
        ),
      ],
    );
  }

  Widget _signInButton() {
    return FadeAnimation(
      duration: Duration(milliseconds: 500),
      delay: Duration(milliseconds: 3000),
      offset: Offset(-10.0, 0.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 50,
        child: MaterialButton(
          onPressed: () =>
              showDialog(context: context, builder: (_) => SignInPage()),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          color: Theme.of(context).colorScheme.secondary,
          child: Text(
            'Sign in',
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ),
      ),
    );
  }

  Widget _signUpButton() {
    return FadeAnimation(
      duration: Duration(milliseconds: 500),
      delay: Duration(milliseconds: 3250),
      offset: Offset(-10.0, 0.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 50,
        child: MaterialButton(
          onPressed: () =>
              showDialog(context: context, builder: (_) => SignUpPage()),
          padding: const EdgeInsets.all(0.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.blue[100]!.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Container(
              constraints: const BoxConstraints(
                  minWidth: double.maxFinite, minHeight: 50.0),
              alignment: Alignment.center,
              child: Text(
                'Sign up',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
