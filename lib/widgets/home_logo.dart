import 'package:flutter/material.dart';
import 'package:ignite/animations/fade_animations.dart';

class HomeLogo extends StatelessWidget {
  final Size size;
  const HomeLogo({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            FadeAnimation(
              duration: Duration(milliseconds: 500),
              delay: Duration(milliseconds: 500),
              offset: Offset(-10.0, 0.0),
              child: Container(
                height: size.height * 0.08,
                padding: EdgeInsets.all(size.height * 0.002),
                decoration: BoxDecoration(
                  border: Border.all(width: 3.0, color: Colors.black),
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/icons/light_icon.png',
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(width: size.width * 0.025),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeAnimation(
                  duration: Duration(milliseconds: 500),
                  delay: Duration(milliseconds: 750),
                  offset: Offset(10.0, 0.0),
                  child: Text(
                    'IGNITE',
                    style: TextStyle(
                      letterSpacing: size.width * 0.002,
                      fontSize: size.height * 0.055,
                      fontFamily: 'BebasNeue',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                FadeAnimation(
                  duration: Duration(milliseconds: 500),
                  delay: Duration(milliseconds: 1000),
                  offset: Offset(10.0, 0.0),
                  child: Text(
                    'YOUR PASSION',
                    style: TextStyle(
                      height: size.height * 0.0008,
                      fontSize: size.height * 0.055,
                      fontFamily: 'BebasNeue',
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
