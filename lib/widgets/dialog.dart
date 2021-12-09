import 'package:flutter/material.dart';
import 'package:ignite/pages/sign_in_page.dart';

emailVerificationDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/email_verification.gif',
            fit: BoxFit.fitWidth,
          ),
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              '이메일 인증',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text('인증 메일을 보냈습니다\n이메일 확인 후, 다시 로그인 하세요'),
          ),
          SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    ),
  );
}

resetPasswordDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/email_verification.gif',
            fit: BoxFit.fitWidth,
          ),
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              '비밀번호 초기화',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text('비밀번호 초기화 메일을 보냈습니다.\n이메일 확인 후, 다시 로그인 하세요.'),
          ),
          SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    ),
  );
}

errorDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/error.gif',
            fit: BoxFit.fitWidth,
          ),
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              '오류',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text('존재하지 않는 이메일 주소입니다.'),
          ),
          SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    ),
  );
}

signUpCompletionDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/sign_up.gif',
            fit: BoxFit.fitWidth,
          ),
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              '준비 완료!',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text('인증 메일을 보냈습니다\n이메일 확인 후, 다시 로그인 하세요'),
          ),
          SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => SignInPage()));
            },
            child: Text('확인'),
          ),
        ],
      ),
    ),
    // builder: (_) => AssetGiffyDialog(
    //   image: Image.asset('assets/images/sign_up.gif', fit: BoxFit.cover),
    //   cornerRadius: 0.0,
    //   buttonRadius: 0.0,
    //   onlyOkButton: true,
    //   title: Text(
    //     '준비 완료!',
    //     style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
    //   ),
    //   description: Text(
    //     '인증 메일을 보냈습니다\n이메일 확인 후, 다시 로그인 하세요',
    //     textAlign: TextAlign.center,
    //     style: TextStyle(),
    //   ),
    //   entryAnimation: EntryAnimation.DEFAULT,
    //   buttonOkColor: Theme.of(context).accentColor,
    //   onOkButtonPressed: () {
    //     Navigator.of(context).pop();
    //     Navigator.of(context).pop();
    //     Navigator.pushReplacement(
    //         context, MaterialPageRoute(builder: (_) => SignInPage()));
    //   },
    // ),
  );
}
