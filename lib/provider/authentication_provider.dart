import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth;
  AuthenticationProvider(this._auth);

  User? get currentUser => _auth.currentUser;

  // 이메일/비밀번호로 Firebase에 회원가입
  Future<String?> signUp(
      {required String username,
      required String email,
      required String password}) async {
    String? errorMessage;

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        user.updateDisplayName(username);
      }

      await _firestore.collection('user').doc(userCredential.user!.uid).set({
        'avatar': '',
        'username': username,
        'email': email,
        'manners': 0,
        'skill': 0,
      });
      return errorMessage;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = '동일한 이메일이 등록되어 있습니다';
          break;
        case 'invalid-email':
          errorMessage = '이메일 주소가 유효하지 않습니다';
          break;
        case 'operation-not-allowed':
          errorMessage = '이메일 주소와 비밀번호를 사용할 수 없습니다';
          break;
        case 'weak-password':
          errorMessage = '비밀번호가 안전하지 않습니다';
          break;
        default:
          errorMessage = '이메일 주소와 비밀번호를 확인해주세요';
      }
    }
    return errorMessage;
  }

  // 이메일/비밀번호로 Firebase에 로그인
  Future<String?> signIn(
      {required String email, required String password}) async {
    String? errorMessage;
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return '이메일 주소 인증이 필요합니다';
      }
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          errorMessage = '이메일 주소가 잘못되었습니다';
          break;
        case 'wrong-password':
          errorMessage = '비밀번호가 잘못되었습니다';
          break;
        case 'user-not-found':
          errorMessage = '등록되지 않은 이메일 주소입니다';
          break;
        case 'user-disabled':
          errorMessage = '비활성화 된 이메일 주소입니다';
          break;
        default:
          errorMessage = '이메일 주소와 비밀번호를 확인해주세요';
      }
    }
    return errorMessage;
  }

  // 사용자에게 비밀번호 재설정 메일을 전송
  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      return false;
    }
    return true;
  }

  // Firebase로부터 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
