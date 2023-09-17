import 'dart:convert';
import 'dart:ffi';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:async';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamcdcapp/Views/Dashboard/MainBottomNavigationViews/MainBottomnavigationViews.dart';
import 'package:teamcdcapp/Views/ResetPassword.dart';
import 'HomeChatBoxView.dart';
import 'Register.dart';




class LoginView extends StatefulWidget {
  LoginView() : super();

  @override
  loginViewState createState() => loginViewState();
}



class loginViewState extends State<LoginView> {
  bool isCheck = false;
  String? username;
  String? passwordd;
  final _Emailcontroller = TextEditingController();
  final _Passwordcontroller = TextEditingController();
  final _sendemail = TextEditingController();
  bool _obscureText = true;
  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));

  }

  // uniquely identifies a Form
  final _formKey = GlobalKey<FormState>();
  bool _isHidden = true;
  String? imagePath;
  String? token;
  String? email;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _Emailcontroller.dispose();
    _Passwordcontroller.dispose();
    super.dispose();
  }


  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();



  String setPassword(String value) {
    Pattern pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regex = new RegExp(pattern as String);
    bool passValid = RegExp(
        "^(?=.{8,32}\$)(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%^&*(),.?:{}|<>]).*")
        .hasMatch(value);
    print(value);
    if (value.isEmpty) {
      return 'Please enter password';
    } else {
      if (!regex.hasMatch(value))
        return 'Enter valid password';
      else{
        return 'null';
      }

    }
  }


  //// For Snackbar or toast display for messages

  _showSnackbar() {
    var snackBar = new SnackBar(content: Text("Login Successful"));

    //  scaffoldKey.currentState?.showSnackBar(snackBar);
  }

 // bool _obscureText = true;
  // Toggles the password show status
  void _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });}

  /// For Pick Images from Gallery
  /*void pickImageFiles2() async {
    XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      print(xFile.path);
      imagePath = xFile.path;
      setState(() {
        imagePath = xFile.path;
      });
    }
  }

  Widget SelectImg(){
    if(imagePath == null){
      return Text("No Image Selected!");
    } else{
      return Image.file(File(imagePath!), width: 350, height: 350);
    }
  }*/



  @override void initState() {
    // TODO: implement initState
    super.initState();
   // fetchUserId();

  }


  @override
  Widget build(BuildContext context) {

    return FlutterEasyLoading(
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        // backgroundColor: Color(0xEDFFFB),
        appBar: AppBar(title:Text("User Log In"),
          centerTitle: true,
          backgroundColor: _colorFromHex("#0BADBC"),
        ),
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

                  SizedBox(height: 30,),

                  Container(

                    child:Center(
                      child: Text("Hello Again!",
                        style: TextStyle( color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
                      ),

                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(

                    child:Center(
                      child: Text("Welcome back you've been missed!",
                        style: TextStyle( color: Colors.black, fontSize: 18, fontWeight: FontWeight.normal),
                      ),

                    ),
                  ),
                  SizedBox(height: 10,),
                  ///  This is login form textfield coloum
                  Form(
                    // autovalidate: true,
                    autovalidateMode: AutovalidateMode.always, key: formkey,
                    //  key: formKey,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),

                          child: TextFormField(
                              controller: _Emailcontroller,
                             // inputFormatters: [NoLeadingSpaceFormatter()],
                              decoration: const InputDecoration(
                                //  border: UnderlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 3, color: Colors.grey), //<-- SEE HERE
                                ),
                                labelText: 'Enter your username',
                              ),
                              maxLength: 80,
                              /*validator: MultiValidator([
                                RequiredValidator(errorText: "Email id field is empty"),
                                EmailValidator(errorText: "Enter valid email id"),
                              ]),*/
                              validator: (value) {
                                // Check if the value has leading spaces
                                if (value != null && value.trim() != value) {
                                  return 'Leading spaces are not allowed.';
                                }
                                return null; // Return null if validation succeeds
                              },
                              onSaved: (value) {


                                //  model.password = value;
                                //  username = value;
                              }
                            //
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: TextFormField(
                            controller: _Passwordcontroller,
                            obscureText: !_isPasswordVisible, // Use the _isPasswordVisible flag
                            decoration: InputDecoration(
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
                                  });
                                },
                                child: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off, // Change icon based on visibility state
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 3,
                                  color: Colors.grey,
                                ),
                              ),
                              labelText: 'Enter your password',
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  /// This container is for checkbox and Forgot password button
                  Container(
                    // color: Color(0xFFF8FCFF),

                    child: Column(children: [
                      Row(
                        children: [


                          Material(
                            color:_colorFromHex("#EDFFFB"),
                            child: Checkbox(
                              key: Key("checkBox"),
                              value: isCheck,
                              activeColor: Colors.blue,
                              checkColor: Colors.white,
                              onChanged: (value) {
                                setState(() {
                                  //   isCheck = value;
                                });
                              },
                            ),
                          ),
                          FittedBox(

                            child: Container(
                                padding: EdgeInsets.fromLTRB(2, 10, 10, 10),
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Remember Me',
                                      style: TextStyle(
                                        color: Colors.black, fontSize: 11,),

                                    ),
                                  ),
                                )
                            ),
                          ),
                          SizedBox(width: 70,),
                          Container(
                              child: Row(
                                children: <Widget>[

                                  TextButton(
                                    //  textColor: color1,
                                    child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold, color:_colorFromHex("#0BADBC")
                                        )),
                                    onPressed: () {

                                      print("Forgot password tap is working");

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ForgotPasswordView()),
                                      );

                                      //signup screen
                                    },
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                              )),
                        ],
                      ),


                    ]
                    ),
                  ),
                  SizedBox(height: 10,),
                  ////  Container for login Action button
                  Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: ElevatedButton(
                        // textColor: Colors.white,
                        // color: _colorFromHex("#0BADBC"),
                          style: ElevatedButton.styleFrom(
                            primary: _colorFromHex("#0BADBC"),
                          ),
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white,
                            ),
                          ),
                          onPressed:(){


                            /*if (formkey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 0,),),
                              );
                              print("Validated all conditions and fields are not empty");
                            }
                            else {
                              print("Not Validated and fields are empty");

                            }*/
                            if(_Emailcontroller.text=='')
                            {
                              EasyLoading.showToast("Please enter the username");
                            } else if (_Passwordcontroller.text == '') {
                              EasyLoading.showToast("Please enter the password");
                            }else{
                              loginRequest();
                            }


                            print("Login Button is pressd");

                          }
                      )
                  ),
                  SizedBox(height: 15,),
                  Container(

                    child:Center(
                      child: Text("-------OR-------",
                        style: TextStyle( color: Colors.grey, fontSize: 18, fontWeight: FontWeight.normal),
                      ),

                    ),
                  ),
                  SizedBox(height: 15,),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: MaterialButton(
                      height: 60,

                      color: _colorFromHex("#F8F8F8"),
                      elevation: 10,
                      onPressed: () {  },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 30.0,
                            width: 30.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:AssetImage('images/assets/google-icon.png'),
                                  fit: BoxFit.cover),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text("Login with Google")
                        ],
                      ),

                      // by onpressed we call the function signup function

                    ),),
                  SizedBox(height: 15,),
                  FittedBox(

                    child: Container(
                        padding: EdgeInsets.fromLTRB(2, 10, 10, 10),
                        child: Center(
                          child: RichText(

                            text: TextSpan(

                                text: "Don't have an account yet?",
                                style: TextStyle(
                                  color: Colors.black, fontSize: 18,),
                                children: <TextSpan>[
                                  TextSpan(text: 'Sign UP',
                                      style: TextStyle(


                                          color: _colorFromHex("#0BADBC") , fontSize: 18),
                                      recognizer: TapGestureRecognizer()..onTap = () {

                                        print("Sign Up button tap Working");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => NewAccountView(),),
                                        );
                                        // navigate to desired screen
                                      }
                                  ),

                                ]
                            ),
                          ),
                        )
                    ),
                  ),
                  /// here gmail login container is created

                ],
                ),

            ),
          ),
        ),
      ),
    );
  }
///// API function call for login

  Future<void> loginRequest() async {
    print("The login api function is calling");
    // String? fcmtoken = await FirebaseMessaging.instance.getToken();
    // print("FCM Token: $fcmtoken");
    PassfcmToken();
    EasyLoading.show(status: "Loading");
   // final url = Uri.parse('http://65.1.109.24:8080/authenticate');
    final url = Uri.parse('https://customerdigitalconnect.com/authenticate');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _Emailcontroller.text,
        'password': _Passwordcontroller.text,
        // add additional fields as needed
      }),
    );
    final jsonResponse = jsonDecode(response.body);

    print(jsonResponse);

    if(response.statusCode==200)
    {
      // final responseData = json.decode(response.body);
      // final success = responseData['status'];
      //  print("The Success msg is"+responseData.toString());

      print("Success always");

      var userToken = jsonResponse['token'];
      print("The user token is:"+userToken);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 0,),),
      );

      print('success');
      EasyLoading.showToast("Success");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("token", userToken);
    //  UserDetails();
      fetchUsernameFromToken();
      fetchGeneralInformation();

    //  print("The prefs is that"+prefs.toString());

    }

    else {
      print('error');
      //  EasyLoading.showError("Please enter the valid crendentials");
      final jsonResponse2 = response.body != null ? jsonDecode(response.body) : null;
     // final jsonResponse2 = jsonDecode(response.body);
      print("==error jsonResponse is that:" + jsonResponse2.toString());
    //  EasyLoading.showError(jsonResponse2!=null ? jsonResponse2['massage']:'unknown error');
      EasyLoading.showError(jsonResponse2 != null ? jsonResponse2['message'] ?? 'unknown error' : 'unknown error');
    }

  }

  void PassfcmToken () async {
    print("fcm tocken calling");
    String? fcmtoken = await FirebaseMessaging.instance.getToken();
    print("FCM Token is : $fcmtoken");
  }


  ///// API function call for Forgot Password

  Future<void> sendPasswordResetEmail() async {
    print("Forgot password function calling");
    EasyLoading.show(status: "Loading");

    final url = Uri.parse('http://65.1.109.24:8080/forgot-password');

    if (_sendemail.text.isEmpty) {
      print("Email address is empty");
      EasyLoading.showError("Please enter your email address");
      return;
    }

    final response = await http.post(
      url,
      body: {'email': _sendemail.text},
    );

    print("The forgot password response is: " + response.body);

    if (response.statusCode == 200) {

      print("Response Status success");
      print(response.statusCode);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginView()),
      );
      EasyLoading.showToast("Password reset email sent");
    } else {
      print("Something went wrong");
      print(response.statusCode);
      final jsonResponse = response.body != null ? jsonDecode(response.body) : null;
      print("==error jsonResponse is that: " + jsonResponse.toString());
      EasyLoading.showError(jsonResponse != null ? jsonResponse['message'] ?? 'Unknown error' : 'Unknown error');
    }
  }

////  Api function for fetching userid


// Fetch user name from the token through jwt decode
  Future<String?> fetchUsernameFromToken() async {
    try {
      // Fetch the token from shared preferences
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String? newToken = sharedPreferences.getString("token");

      if (newToken != null) {
        // Decode the token and get the payload as a Map
        Map<String, dynamic> decodedToken = Jwt.parseJwt(newToken);

        // Access the username from the decoded payload using the key specified in the token
        String? username = decodedToken['sub'] as String?;
        return username;
      } else {
        // Handle the case when the token is null
        print('Token not found in shared preferences.');
        return null;
      }
    } catch (e) {
      // Handle any exceptions that may occur during token decoding
      print('Error decoding token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchGeneralInformation() async {
    print("Fetch general user information API is calling");
    try {
      // Fetch the username from the token
      String? username = await fetchUsernameFromToken();
      print("proper username is:"+username.toString());

      if (username != null) {
        // Get the token from shared preferences
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        String? newToken = sharedPreferences.getString("token");

        print("String token is: " + newToken.toString());
        if (newToken != null) {
          // Construct the API URL
          final apiUrl = 'http://65.1.109.24:8080/userinfo/$username';
          print("api url is:"+apiUrl);// Replace with your API endpoint

          // Set the headers with the token and username
          Map<String, String> headers = {
            'Authorization': 'Bearer $newToken',
          };

          // Make the API request
          final response = await http.get(
            Uri.parse(apiUrl),
            headers: headers,
          );

          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);
            print("The information response data is: $responseData");

            var userid = responseData['userId'] as int?;
            var username = responseData['username'];
            print("The userid is:" + userid.toString());
            print("The username is:" + username.toString());
            sharedPreferences.setInt("userId", userid!);
          //  print("The userid is:"+userid.toString());
            return responseData as Map<String, dynamic>;
          } else {
            print('Failed to fetch data: ${response.statusCode}, ${response.body}');
            return null;
          }
        }
        else {
          // Handle the case when the token is null
          print('Token not found in shared preferences.');
          return null;
        }
      }
      else {
        // Handle the case when the username is null
        print('Username not found in token.');
        return null;
      }
    }
    catch (e)
    {
      // Handle any exceptions that may occur during the API call
      print('Error fetching data: $e');
      return null;
    }
  }


}