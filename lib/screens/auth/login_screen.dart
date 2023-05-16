import 'dart:developer';
import 'dart:io';

import 'package:chatter_io/main.dart';
import 'package:chatter_io/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../api/apis.dart';
import '../../helper/dialogs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(microseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log("\nUser : ${user.user}");
        log("UserAdditionalInfo: ${user.additionalUserInfo}");

        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('_signInWithGoogle: $e');
      Dialogs.showSnackbar(context, 'Something went wrong (Check Internet)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // screen_size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to Chatter.io'),
      ),
      body: Stack(children: [
        //App icon
        AnimatedPositioned(
            top: screen_size.height * .15,
            right:
                _isAnimate ? screen_size.width * .25 : -screen_size.width * .5,
            width: screen_size.width * .5,
            duration: const Duration(milliseconds: 1000),
            child: Image.asset('images/icon.png')),

        // Google login button
        Positioned(
            bottom: screen_size.height * .15,
            left: screen_size.width * .05,
            width: screen_size.width * .9,
            height: screen_size.height * .07,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 223, 255, 187),
                    shape: StadiumBorder(),
                    elevation: 1),
                onPressed: () {
                  _handleGoogleBtnClick();
                },
                icon: Image.asset('images/google.png',
                    height: screen_size.height * .04),
                label: RichText(
                  text: const TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 19),
                      children: [
                        TextSpan(text: "Log In with"),
                        TextSpan(
                            text: " Google",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                )))
      ]),
    );
  }
}
