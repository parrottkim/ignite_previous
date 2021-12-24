import 'package:flutter/material.dart';
import 'package:ignite/animations/fade_animations.dart';

class HomeLogo extends StatelessWidget {
  const HomeLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            FadeAnimation(
              duration: Duration(milliseconds: 500),
              delay: Duration(milliseconds: 500),
              offset: Offset(-10.0, 0.0),
              child: Container(
                height: 66.0,
                padding: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  border: Border.all(width: 2.0, color: Colors.white),
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Image.asset('assets/images/icons/light_icon.png'),
              ),
            ),
            SizedBox(width: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                FadeAnimation(
                  duration: Duration(milliseconds: 500),
                  delay: Duration(milliseconds: 750),
                  offset: Offset(10.0, 0.0),
                  child: Text(
                    'IGNITE',
                    style: TextStyle(
                      letterSpacing: 1.5,
                      fontSize: 44.0,
                      fontFamily: 'BebasNeue',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                      height: 0.8,
                      fontSize: 44.0,
                      fontFamily: 'BebasNeue',
                      color: Colors.white,
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
