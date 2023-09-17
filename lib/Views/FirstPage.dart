
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:teamcdcapp/Views/UserLogin/Register.dart';
import 'package:teamcdcapp/Views/UserLogin/SignIn.dart';
//import 'package:shared_preferences/shared_preferences.dart';



class FirstScreen extends StatefulWidget {
  FirstScreen() : super();

  @override
  FirstScreenState createState() => FirstScreenState();
}



class FirstScreenState extends State<FirstScreen> {


  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));

  }



  //// For Snackbar or toast display for messages

  _showSnackbar() {
    var snackBar = new SnackBar(content: Text("Login Successful"));

    //  scaffoldKey.currentState?.showSnackBar(snackBar);
  }

  bool _obscureText = true;
  // Toggles the password show status
  void _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });}




  @override
  Widget build(BuildContext context) {

    return Scaffold(
     // key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      // backgroundColor: Color(0xEDFFFB),
      //appBar: AppBar(title:Text("Splash Screen Example")),
      /*body: Center(
            child:Text("Welcome to Home Page",
                style: TextStyle( color: Colors.black, fontSize: 30)
                team-logo.png
            )
        ),*/
      backgroundColor: _colorFromHex("#EDFFFB"),
      body: AnimationLimiter(
        child: SingleChildScrollView(
          child: Column(

            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                // horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                SizedBox(height: 40,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(

                      child:Image(image: AssetImage(
                        ("images/assets/logo.png"),),

                        /*"Welcome to Home Page",
                    style: TextStyle( color: Colors.black, fontSize: 10)*/
                      )
              ),
                  ),
                ),

                SizedBox(height: 50,),
                // Team computers logo
                Center(
                  child: Container(

                    child:Center(
                      child: Image(image: AssetImage(
                        ("images/assets/intro-1.png"),
                      ),
                      ),

                    ),
                  ),
                ),
                SizedBox(height: 10,),

                Container(

                  child:Center(
                    child: Text("Market AnyTime, AnyWhere",
                      style: TextStyle( color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
                    ),

                  ),
                ),
                Container(

                  child:Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Create campaigns, share timely updates and exciting offers. All while tracking performance across thousands of messages.",
                        style: TextStyle( color: Colors.black, fontSize: 15, fontWeight: FontWeight.normal,),
                        maxLines: 3,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                            height: 60,
                            child: ElevatedButton(
                        onPressed: () {
                          print("Register button tapped");

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NewAccountView(),),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            primary: _colorFromHex("#EDEDED")
                        ),
                        child: Text("Register",
                            style: TextStyle(color: Colors.black),
                        ),),
                          )),
                      Expanded(
                          child: SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            print("Sihn in butten tapped");

                            Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => LoginView(),),
                                      );
                          },

                          style: ElevatedButton.styleFrom(primary: _colorFromHex("#0BADBC")),
                          child: Text("Sign IN",style: TextStyle(color: Colors.white),),
                        ),
                      )
                      ),
                    ],
                  ),
                )
                ///  This is login form textfield coloum



                /// This container is for checkbox and Forgot password button

              ],
            ),

          ),
        ),
      ),
    );
  }


}