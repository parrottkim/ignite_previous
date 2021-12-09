import 'package:flutter/material.dart';
import 'package:ignite/pages/my_pages/registration_page.dart';
import 'package:ignite/services/service.dart';

class NotRegisteredPage extends StatelessWidget {
  const NotRegisteredPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('동료 찾기')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('처음 오셨나요?\n\'게임 등록\' 버튼을 눌러 게임을 등록해주세요'),
            SizedBox(height: 20.0),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: MaterialButton(
                elevation: 0,
                minWidth: double.maxFinite,
                height: 50,
                onPressed: () {
                  Navigator.push(
                      context, createRoute(RegistrationPage(flag: false)));
                },
                color: Theme.of(context).primaryColor,
                child: Text('게임 등록',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
