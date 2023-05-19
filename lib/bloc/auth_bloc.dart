import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_sign_in_plus/github_sign_in_plus.dart';
import 'package:vgtstask/screen/home_screen.dart';
import 'package:vgtstask/screen/login_screen.dart';

class AuthCubit extends Cubit<User?> {
  AuthCubit() : super(null);

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GitHubSignIn? gitHubSignIn = GitHubSignIn(
    clientId: '74b7887391024124039f',
    clientSecret: 'fcd73f3dc5f1eb68a40f6b876f665e1b3b2b00e6',
    redirectUrl: 'https://vgtstask.firebaseapp.com/__/auth/handler',
    title: 'GitHub Connection',
    scope: 'read:user,user:email',
    centerTitle: false,
    allowSignUp: true,
  );

  void signInWithGitHub(BuildContext context) async {
    if (gitHubSignIn != null) {
      try {
        final result = await gitHubSignIn?.signIn(context);
        switch (result!.status) {
          case GitHubSignInResultStatus.ok:
            final AuthCredential credential = GithubAuthProvider.credential(result.token!);
            final userCredential = await _firebaseAuth.signInWithCredential(credential);
            final user = userCredential.user!;
            emit(user);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(token: result.token!,),
              ),
            );
            break;
          case GitHubSignInResultStatus.cancelled:
          case GitHubSignInResultStatus.failed:
            print(result.errorMessage);
            break;
        }
      } catch (error) {
        print('GitHub sign-in error: $error');
      }
    } else {
      print("GitHub sign-in error");
    }
  }

  void signOut(BuildContext context) async {
    await _firebaseAuth.signOut();
    emit(null);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPag()),
          (Route<dynamic> route) => false,
    );
  }
}