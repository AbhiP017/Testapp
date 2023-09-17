import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:teamcdcapp/Views/UserLogin/SignIn.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordView extends StatefulWidget {
  ForgotPasswordView() : super();

  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPasswordView> {


  final _sendemail = TextEditingController();



  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));

  }

  @override
  Widget build(BuildContext context) {

    return FlutterEasyLoading(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Forgot Password"),
          centerTitle: true,
          backgroundColor: _colorFromHex("#0BADBC"),
        ),
        body: Column(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Team computers logo
                    Padding(
                      padding: const EdgeInsets.only(top:16),
                      child: Container(

                        child:Center(
                          child: Image(image: AssetImage(
                            ("images/assets/lock-icon.png"),
                          ),
                          ),

                        ),
                      ),
                    ),
                    Container(

                      child:Center(
                        child: Text("Forgot Password",
                          style: TextStyle( color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
                        ),

                      ),
                    ),
                    Container(

                      child:Padding(
                        padding: const EdgeInsets.all(16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Enter your registered email address below to receive the password reset link",
                            style: TextStyle( color: Colors.black, fontSize: 15, fontWeight: FontWeight.normal,),
                            maxLines: 3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    //// Email ID Field
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: RichText(
                          text: TextSpan(
                              text: 'Work Email ID',
                              style: TextStyle(
                                  color: Colors.black, fontWeight: FontWeight.normal, fontSize: 15),
                              children: [
                                TextSpan(
                                    text: ' *',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))
                              ]),

                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                          controller: _sendemail,
                          decoration: const InputDecoration(
                            //  border: UnderlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3, color: Colors.grey), //<-- SEE HERE
                            ),
                            labelText: 'Enter your email id',
                          ),
                          maxLength: 80,
                          validator: MultiValidator([
                            RequiredValidator(errorText: "email id field is empty"),
                            EmailValidator(errorText: "Enter Your email id"),
                          ]),
                          onSaved: (value) {
                            //  email = value!;
                            //  model.password = value;
                            // userrole = value;
                          }
                        //
                      ),
                    ),
                    SizedBox(height: 10,),
                    ////  Container for submit button
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
                              'Generate Link',
                              style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white,
                              ),
                            ),
                            onPressed:(){


                              /*if (formkey.currentState!.validate()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => homeChatListView(),),
                                );
                                print("Validated all conditions and fields are not empty");
                              }
                              else {
                                print("Not Validated and fields are empty");

                              }*/
                              sendPasswordResetEmail();
                              // forgotPassword();
                              // getlogin();
                              //  makeAPIRequest();
                              // loginUser();
                              print("Generate Link Button is pressd");

                            }
                        )
                    ),

                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
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
    //  EasyLoading.showToast("Password reset email sent");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset email sent. Please check uor email!')));
     // EasyLoading.show(status: "Password reset email sent");
    } else {
      print("Something went wrong");
      print(response.statusCode);
      final jsonResponse = response.body != null ? jsonDecode(response.body) : null;
      print("==error jsonResponse is that: " + jsonResponse.toString());
      EasyLoading.showError(jsonResponse != null ? jsonResponse['message'] ?? 'Unknown error' : 'Unknown error');
    }
  }


}