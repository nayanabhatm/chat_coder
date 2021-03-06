import 'package:flutter/material.dart';
import 'package:chatcoder/screens/welcome_screen.dart';
import 'package:chatcoder/screens/login_screen.dart';
import 'package:chatcoder/screens/registration_screen.dart';
import 'package:chatcoder/screens/chat_screen.dart';

void main() => runApp(FlashChat());

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//      theme:  ThemeData.dark().copyWith(
//        textTheme: TextTheme(
//          body1: TextStyle(color: Colors.black54),
//        ),
//      ),
      routes: {
        WelcomeScreen.id:(context)=>WelcomeScreen(),
        LoginScreen.id:(context)=>LoginScreen(),
        RegistrationScreen.id:(context)=>RegistrationScreen(),
        ChatScreen.id:(context)=>ChatScreen(),
      },
      initialRoute: WelcomeScreen.id,
    );
  }
}
