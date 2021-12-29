import 'package:flutter/material.dart';
import 'package:ignite/pages/get_started_page.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/dot_animation_enum.dart';
import 'package:intro_slider/slide_object.dart';

class IntroPage extends StatefulWidget {
  IntroPage({Key? key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  List<Slide> slides = [];
  late Function goToTab;

  @override
  void initState() {
    super.initState();

    slides.add(
      Slide(
        title: '환영합니다!',
        styleTitle: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        description: 'Ignite는 모든 플레이어들을 위한\n실시간 매칭 플랫폼입니다.',
        styleDescription: TextStyle(fontSize: 20.0),
        pathImage: 'assets/images/intro/intro_1.png',
      ),
    );
    slides.add(
      Slide(
        title: '어떤 플랫폼이든',
        styleTitle: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        description: '콘솔, PC 그 어떤 플랫폼에서도\n자유롭게 탐색하세요.',
        styleDescription: TextStyle(fontSize: 20.0),
        pathImage: 'assets/images/intro/intro_2.png',
      ),
    );
    slides.add(
      Slide(
        title: '시작해볼까요?',
        styleTitle: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        description: '지금 수 많은 플레이어들이\n당신을 기다리고 있습니다!',
        styleDescription: TextStyle(fontSize: 20.0),
        pathImage: 'assets/images/intro/intro_3.png',
      ),
    );
  }

  void onDonePress() {
    // Back to the first tab
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => GetStartedPage()), (_) => false);
  }

  void onTabChangeCompleted(index) {
    // Index of current tab is focused
  }

  Widget renderNextBtn() {
    return const Icon(
      Icons.navigate_next,
      size: 35.0,
      color: Colors.redAccent,
    );
  }

  Widget renderDoneBtn() {
    return const Icon(
      Icons.done,
      color: Colors.redAccent,
    );
  }

  Widget renderSkipBtn() {
    return const Icon(
      Icons.skip_next,
      color: Colors.redAccent,
    );
  }

  List<Widget> renderListCustomTabs() {
    List<Widget> tabs = [];
    for (int i = 0; i < slides.length; i++) {
      Slide currentSlide = slides[i];
      tabs.add(
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                    child: Image.asset(
                  currentSlide.pathImage!,
                  width: 200.0,
                  height: 200.0,
                  fit: BoxFit.contain,
                )),
                Container(
                  child: Text(
                    currentSlide.title!,
                    style: currentSlide.styleTitle,
                    textAlign: TextAlign.center,
                  ),
                  margin: EdgeInsets.only(top: 20.0),
                ),
                Container(
                  child: Text(
                    currentSlide.description!,
                    style: currentSlide.styleDescription,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  margin: EdgeInsets.only(top: 20.0),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntroSlider(
        // List slides
        // slides: this.slides,

        // Skip button
        renderSkipBtn: renderSkipBtn(),

        // Next button
        renderNextBtn: renderNextBtn(),

        // Done button
        renderDoneBtn: renderDoneBtn(),
        onDonePress: onDonePress,

        // Dot indicator
        colorDot: Colors.redAccent,
        sizeDot: 13.0,
        typeDotAnimation: dotSliderAnimation.SIZE_TRANSITION,

        // Tabs
        listCustomTabs: renderListCustomTabs(),
        backgroundColorAllSlides: Colors.white,
        refFuncGoToTab: (refFunc) {
          goToTab = refFunc;
        },

        // Behavior
        scrollPhysics: const BouncingScrollPhysics(),

        // Show or hide status bar
        hideStatusBar: false,

        // On tab change completed
        onTabChangeCompleted: onTabChangeCompleted,
      ),
    );
  }
}
