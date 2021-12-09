import 'package:flutter/material.dart';
import 'package:ignite/animations/fade_animations.dart';

class HomeLogo extends StatefulWidget {
  HomeLogo({Key? key}) : super(key: key);

  @override
  _HomeLogoState createState() => _HomeLogoState();
}

class _HomeLogoState extends State<HomeLogo> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeAnimation(
          duration: Duration(milliseconds: 500),
          delay: Duration(milliseconds: 500),
          offset: Offset(-10.0, 0.0),
          child: Container(
            height: 60.0,
            padding: EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/icons/light_icon.png',
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        SizedBox(height: 10.0),
        const FadeAnimation(
          duration: Duration(milliseconds: 500),
          delay: Duration(milliseconds: 750),
          offset: Offset(-10.0, 0.0),
          child: Text(
            'IGNITE',
            style: TextStyle(
              fontSize: 40.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 4.0),
        const FadeAnimation(
          duration: Duration(milliseconds: 500),
          delay: Duration(milliseconds: 1000),
          offset: Offset(-10.0, 0.0),
          child: Text(
            'your passion anytime, anywhere.\nIt doesn\'t matter who you are or what platform you\'re on.',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 10.0),
        // FadeAnimation(
        //   duration: Duration(milliseconds: 500),
        //   delay: Duration(milliseconds: 750),
        //   offset: Offset(-10.0, 0.0),
        //   child: InkWell(
        //     onTap: () {},
        //     onHover: (hovering) => setState(() => _isHovering = hovering),
        //     child: Row(
        //       children: [
        //         Text(
        //           'REGISTER YOUR ACCOUNT',
        //           style: TextStyle(
        //             fontWeight: FontWeight.bold,
        //             fontSize: 16.0,
        //             color: Colors.white,
        //           ),
        //         ),
        //         SizedBox(width: 4.0),
        //         Icon(
        //           Icons.keyboard_arrow_right,
        //           size: 16.0,
        //           color: Colors.white,
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
