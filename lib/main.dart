import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DemoViews/TestUI.dart';
import 'Views/Dashboard/MainBottomNavigationViews/MainBottomnavigationViews.dart';
import 'Views/FirstPage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // String? fcmtoken = await FirebaseMessaging.instance.getToken();
  // print("FCM Token: $fcmtoken");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    //  home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}


Future<bool> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userToken = prefs.getString("token");

  // Check if a valid token exists
  if (userToken != null && userToken.isNotEmpty) {
    // You can also validate the token here if needed
    // If it's valid, return true; otherwise, return false
    return true;
  }

  return false; // No valid token found
}
class AppStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(), // Check if the user is already logged in
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == true) {
            // User is already logged in, navigate to the dashboard
            return BottomNavigationBarView(selectedIndex: 0);
          } else {
            // User is not logged in, show the login screen
            return FirstScreen();
          }
        } else {
          // While the status is being checked, you can show a loading indicator
          return CircularProgressIndicator();
        }
      },
    );
  }}
class SplashScreen extends StatefulWidget {


//  final String title;
  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));

  }

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {






  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5),
            ()=>Navigator.pushReplacement(context,
            MaterialPageRoute(builder:
                (context) => AppStart()
            )
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset("images/assets/splash.png",
                gaplessPlayback: true, fit: BoxFit.fill)
        ));
  }
}



