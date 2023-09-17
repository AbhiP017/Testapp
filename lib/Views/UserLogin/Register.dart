import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:teamcdcapp/Views/UserLogin/SignIn.dart';
//import 'package:untitled17/Views/UserCredentialView/Dashboard.dart';



//import 'loginView.dart';



class NewAccountView extends StatefulWidget {
  @override
  ResetPasswordState createState() => ResetPasswordState();
}
//// for profile popup menu
enum Options { profile, logout}

class ResetPasswordState extends State<NewAccountView>{


  /*var email_controller=TextEditingController(text:'');
  var NewPassword_controller=TextEditingController(text:'');
  var mobile_controller=TextEditingController(text:'');
  var name_controller=TextEditingController(text:'');
  var Username_controller=TextEditingController(text:'');
  var UserRole_controller=TextEditingController(text:'');*/

  final TextEditingController email = new TextEditingController();
  final TextEditingController contact = new TextEditingController();
  final TextEditingController password = new TextEditingController();
  final TextEditingController firstname = new TextEditingController();
  final TextEditingController lastname = new TextEditingController();
  final TextEditingController userName = new TextEditingController();
  final TextEditingController userrole = new TextEditingController();
  final TextEditingController userdepartment = new TextEditingController();
  final TextEditingController useraddress = new TextEditingController();
  final TextEditingController userState = new TextEditingController();
  final TextEditingController userCity = new TextEditingController();
  final TextEditingController PostCode = new TextEditingController();
  final TextEditingController CreatedBY = new TextEditingController();
  final TextEditingController UpdatedBY = new TextEditingController();


  // late String name,username,userrole,number,email, password;
  bool isLoading=false;
  late ScaffoldMessengerState scaffoldMessenger ;
  GlobalKey<ScaffoldState>_scaffoldKey=GlobalKey();
  var reg=RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");



  //// for colour code

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*UserSignUp(username.toString(),
        password.toString().toString(),username.toString(),userrole.toString(),
        number.toString(),email.toString(), context);*/
    // UserSignUp();
  }


  ///  For Pop PupMenu Functionality
  var _popupMenuItemIndex = 0;
  Color _changeColorAccordingToMenuItem = Colors.red;
  PopupMenuItem _buildPopupMenuItem(String title, IconData iconData, int position) {
    return PopupMenuItem(
      value: position,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            iconData,
            color: Colors.black,
          ),
          Text(title),
        ],
      ),
    );
  }

  _onMenuItemSelected(int value) {
    setState(() {
      _popupMenuItemIndex = value;
    });

    if (value == Options.profile.index) {
      _changeColorAccordingToMenuItem = Colors.red;
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => Dashboard()),
      // );
    } else if (value == Options.logout.index) {
      _changeColorAccordingToMenuItem = Colors.green;
      print("Logout in popup");
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => LoginView()),
      // );
    }
  }

  //// for circular loader

  Widget _loader(BuildContext context, String url) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  //// for dailog box
  void showFilterDialog() {
    // filterText = "";
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 16,
          child: Container(
            width: 200,
            height: 110,
            padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Status",
                      style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF919191)),
                    )),
                new Container(
                  child: Column(
                    children: [

                      Container(
                        child: InkWell(
                          onTap: () {
                            print("Profile oprtion is clicked");



                            Navigator.of(context).pop();
                          },
                          child: Text('Profile'),
                        ),
                        padding: EdgeInsets.only(top: 20.0),
                      ),
                      Container(
                        child: InkWell(
                          onTap: () {

                          }, // Handle your callback
                          child: Text('Logout'),
                        ),
                        padding: EdgeInsets.only(top: 20.0),
                      ),


                    ],
                  ),

                  //   ],
                  // ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color color1 = _colorFromHex("#00ABC5");
    return FlutterEasyLoading(
      child: Scaffold(

        backgroundColor: _colorFromHex("#F1F2F7"),
        appBar: AppBar(title:Text("Register Your New Account"),
          centerTitle: true,
          backgroundColor: _colorFromHex("#0BADBC"),
        ),


        body: Center(

            child: Padding(

                padding: EdgeInsets.all(10),
                child: ListView(
                  children: <Widget>[



                    //// user First name
                    Container(
                      padding: EdgeInsets.all(10),
                      child: RichText(
                        text: TextSpan(
                            text: 'First Name',
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
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                          controller: firstname,
                          decoration: const InputDecoration(
                            //  border: UnderlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3, color: Colors.grey), //<-- SEE HERE
                            ),
                            labelText: 'Enter your First Name',
                          ),
                          maxLength: 80,
                          validator: MultiValidator([
                            RequiredValidator(errorText: "First name field is empty"),
                            EmailValidator(errorText: "Enter Your first name"),
                          ]),
                          onSaved: (value) {
                            // userrole=value!;
                            //  model.password = value;
                            // userrole = value;
                          }
                        //
                      ),
                    ),
                    //// user last name
                    Container(
                      padding: EdgeInsets.all(10),
                      child: RichText(
                        text: TextSpan(
                            text: 'Last Name',
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
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                          controller: lastname,
                          decoration: const InputDecoration(
                            //  border: UnderlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3, color: Colors.grey), //<-- SEE HERE
                            ),
                            labelText: 'Enter your  last name',
                          ),
                          maxLength: 80,
                          validator: MultiValidator([
                            RequiredValidator(errorText: "last Name field is empty"),
                            EmailValidator(errorText: "Enter Your Name"),
                          ]),
                          onSaved: (value) {
                            // name=value!;
                            //  model.password = value;
                            // userrole = value;
                          }
                        //
                      ),
                    ),
                    //// username
                    Container(
                      padding: EdgeInsets.all(10),
                      child: RichText(
                        text: TextSpan(
                            text: 'UserName',
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
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                          controller: userName,
                          decoration: const InputDecoration(
                            //  border: UnderlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3, color: Colors.grey), //<-- SEE HERE
                            ),
                            labelText: 'Enter your username',
                          ),
                          maxLength: 80,
                          validator: MultiValidator([
                            RequiredValidator(errorText: "user name field is empty"),
                            EmailValidator(errorText: "Enter Your User Name"),
                          ]),
                          onSaved: (value) {
                            // username = value!;
                            //  model.password = value;
                            // userrole = value;
                          }
                        //
                      ),
                    ),

                    //// Email ID Field
                    Container(
                      padding: EdgeInsets.all(10),
                      child: RichText(
                        text: TextSpan(
                            text: 'Email ID',
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
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                          controller: email,
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
                    //// Phone Number
                    Container(
                      padding: EdgeInsets.all(10),
                      child: RichText(
                        text: TextSpan(
                            text: 'Mobile No:',
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
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                          controller: contact,
                          decoration: const InputDecoration(
                            //  border: UnderlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3, color: Colors.grey), //<-- SEE HERE
                            ),
                            labelText: 'Enter your Mobile number',
                          ),
                          maxLength: 10,
                          validator: MultiValidator([
                            RequiredValidator(errorText: "phone number field is empty"),
                            EmailValidator(errorText: "Enter Your phone number"),
                          ]),
                          onSaved: (value) {
                            //  number = value!;
                            //  model.password = value;
                            // userrole = value;
                          }
                        //
                      ),
                    ),
                    //// New Password Field
                    Container(
                      padding: EdgeInsets.all(10),
                      child: RichText(
                        text: TextSpan(
                            text: 'New Password',
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
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                          controller: password,
                          decoration: const InputDecoration(
                            //  border: UnderlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3, color: Colors.grey), //<-- SEE HERE
                            ),
                            labelText: 'Enter your password',
                          ),
                          maxLength: 80,
                          validator: MultiValidator([
                            RequiredValidator(errorText: "password field is empty"),
                            EmailValidator(errorText: "Enter Your password"),
                          ]),
                          onSaved: (value) {
                            //  password = value!;
                            //  model.password = value;
                            // userrole = value;
                          }
                        //
                      ),
                    ),
                    //// Address field
                    Container(
                      padding: EdgeInsets.all(10),
                      child: RichText(
                        text: TextSpan(
                            text: 'Address',
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
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                          controller: useraddress,
                          decoration: const InputDecoration(
                            //  border: UnderlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3, color: Colors.grey), //<-- SEE HERE
                            ),
                            labelText: 'Enter your address',
                          ),
                          maxLength: 80,
                          validator: MultiValidator([
                            RequiredValidator(errorText: "Address field is empty"),
                            EmailValidator(errorText: "Enter Your address"),
                          ]),
                          onSaved: (value) {
                            //  email = value!;
                            //  model.password = value;
                            // userrole = value;
                          }
                        //
                      ),
                    ),
                    //// State field
                    Container(
                      padding: EdgeInsets.all(10),
                      child: RichText(
                        text: TextSpan(
                            text: 'State',
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
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                          controller: userState,
                          decoration: const InputDecoration(
                            //  border: UnderlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3, color: Colors.grey), //<-- SEE HERE
                            ),
                            labelText: 'Enter your state',
                          ),
                          maxLength: 80,
                          validator: MultiValidator([
                            RequiredValidator(errorText: "State field is empty"),
                            EmailValidator(errorText: "Enter Your state"),
                          ]),
                          onSaved: (value) {
                            //  email = value!;
                            //  model.password = value;
                            // userrole = value;
                          }
                        //
                      ),
                    ),
                    //// City Field
                    Container(
                      padding: EdgeInsets.all(10),
                      child: RichText(
                        text: TextSpan(
                            text: 'City',
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
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                          controller: userCity,
                          decoration: const InputDecoration(
                            //  border: UnderlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3, color: Colors.grey), //<-- SEE HERE
                            ),
                            labelText: 'Enter your City',
                          ),
                          maxLength: 80,
                          validator: MultiValidator([
                            RequiredValidator(errorText: "City field is empty"),
                            EmailValidator(errorText: "Enter Your City"),
                          ]),
                          onSaved: (value) {
                            //  email = value!;
                            //  model.password = value;
                            // userrole = value;
                          }
                        //
                      ),
                    ),
                    //// role ID Field
                    Container(
                      padding: EdgeInsets.all(10),
                      child: RichText(
                        text: TextSpan(
                            text: 'Role ID',
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
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                          controller: userrole,
                          decoration: const InputDecoration(
                            //  border: UnderlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3, color: Colors.grey), //<-- SEE HERE
                            ),
                            labelText: 'Enter your role id',
                          ),
                          maxLength: 80,
                          validator: MultiValidator([
                            RequiredValidator(errorText: "role id field is empty"),
                            EmailValidator(errorText: "Enter Your role id"),
                          ]),
                          onSaved: (value) {
                            //  email = value!;
                            //  model.password = value;
                            // userrole = value;
                          }
                        //
                      ),
                    ),
                    //// Department ID Field
                    Container(
                      padding: EdgeInsets.all(10),
                      child: RichText(
                        text: TextSpan(
                            text: 'Department ID',
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
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                          controller: userdepartment,
                          decoration: const InputDecoration(
                            //  border: UnderlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3, color: Colors.grey), //<-- SEE HERE
                            ),
                            labelText: 'Enter your depertment id',
                          ),
                          maxLength: 80,
                          validator: MultiValidator([
                            RequiredValidator(errorText: "depertment id field is empty"),
                            EmailValidator(errorText: "Enter Your depertment id"),
                          ]),
                          onSaved: (value) {
                            //  email = value!;
                            //  model.password = value;
                            // userrole = value;
                          }
                        //
                      ),
                    ),


                    //// For test asterisk
                    /*RichText(
                      text: TextSpan(
                          text: 'My Test',
                          style: TextStyle(
                              color: Colors.amber, fontWeight: FontWeight.normal, fontSize: 15),
                          children: [
                            TextSpan(
                                text: ' *',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20))
                          ]),

                    ),*/

                    Container(
                        height: 50,
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: ElevatedButton(
                          //  textColor: Colors.white,
                          //  color: color1,
                          style: ElevatedButton.styleFrom(
                            primary: _colorFromHex("#0BADBC"),
                          ),
                          child: Text('Submit',style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                              color: Colors.white),),
                          onPressed: () async {
                            if(userName.text=='')
                            {
                              EasyLoading.showToast("Please enter the username");
                            } else if (firstname.text == '') {
                              EasyLoading.showToast("Please enter the firstname");
                            }else if (lastname.text == '') {
                              EasyLoading.showToast("Please enter the lastname");
                            }else if (email.text == '') {
                              EasyLoading.showToast("Please enter the email");
                            }else if (contact.text == '') {
                              EasyLoading.showToast("Please enter the mobile number");
                            }else if (password.text == '') {
                              EasyLoading.showToast("Please enter the password");
                            }else if (useraddress.text == '') {
                              EasyLoading.showToast("Please enter the address");
                            }else if (userState.text == '') {
                              EasyLoading.showToast("Please enter the state");
                            }else if (userCity.text == '') {
                              EasyLoading.showToast("Please enter the city");
                            }else if (userrole.text == '') {
                              EasyLoading.showToast("Please enter the role");
                            }else if (userdepartment.text == '') {
                              EasyLoading.showToast("Please enter the department");
                            }
                            else{
                              register();
                            }
                           // register();
                            // if(isLoading)
                            // {
                            //   return;
                            // }
                            // if(name_controller.text.isEmpty)
                            // {
                            //   scaffoldMessenger.showSnackBar(SnackBar(content:Text("Please Enter Name")));
                            //   return;
                            // }
                            // if(!reg.hasMatch(email_controller.text))
                            // {
                            //   scaffoldMessenger.showSnackBar(SnackBar(content:Text("Enter Valid Email")));
                            //   return;
                            // }
                            // if(NewPassword_controller.text.isEmpty||NewPassword_controller.text.length<6)
                            // {
                            //   scaffoldMessenger.showSnackBar(SnackBar(content:Text("Password should be min 6 characters")));
                            //   return;
                            // }

                            /*final pref = await SharedPreferences.getInstance();
                            await pref.clear();*/
                            // Navigator.of(context).pushReplacementNamed('/HomePage');

                          },
                        )),

                    SizedBox(height: 35,),
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
                            Text("Register with Google")
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

                                  text: "Already have an account yet?",
                                  style: TextStyle(
                                    color: Colors.black, fontSize: 18,),
                                  children: <TextSpan>[
                                    TextSpan(text: 'Sign IN',
                                        style: TextStyle(


                                            color: _colorFromHex("#0BADBC") , fontSize: 18),
                                        recognizer: TapGestureRecognizer()..onTap = () {

                                          print("Sign in button tap Working");
                                          Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => LoginView(),),
                                          );
                                          // navigate to desired screen
                                        }
                                    ),
                                    /*TextSpan(text: ' Click To Sign UP',
                                style: TextStyle(


                                    color: Colors.blue , fontSize: 11),
                                recognizer: TapGestureRecognizer()

                            )*/
                                  ]
                              ),
                            ),
                          )
                      ),
                    )


                  ],
                )
            )
        ),
        // drawer

      ),
    );
  }
  ///// for signup api integration

  register() async {
    print("Registration function is calling");
    EasyLoading.show(status: "Loading");
    Map data = {

      'roleId':userrole.text,
      'firstName':firstname.text,
      'lastName':lastname.text,
      'username':userName.text,
      'contact':contact.text,
      'password':password.text,
      'email':email.text,
      'address':useraddress.text,
      'state':userState.text,
      'city':userCity.text,
      'postcode':PostCode.text,
      'createdBy':CreatedBY.text,
      'updatedBy':UpdatedBY.text,
      'departmentId':userdepartment.text,
    };
    print(data);

    String body = json.encode(data);

    var url = Uri.parse("http://65.1.109.24:8080/register");
    var response = await http.post(
      url,
      body: body,
      headers: {
        "Content-Type": "application/json",
        "accept": "application/json",
        "Access-Control-Allow-Origin": "*"
      },
    );

    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print("Success always");
      print("==jsonResponse is" + jsonResponse.toString());
      //Or put here your next screen using Navigator.push() method
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginView(),),
      );
      // return"Success";
      EasyLoading.showToast("Success");
      print('success');
    } else {
      final jsonResponse2 = response.body != null ? jsonDecode(response.body) : null;
      // final jsonResponse2 = jsonDecode(response.body);
      print("==error jsonResponse is that:" + jsonResponse2.toString());
      //  EasyLoading.showError(jsonResponse2!=null ? jsonResponse2['massage']:'unknown error');
      EasyLoading.showError(jsonResponse2 != null ? jsonResponse2['message'] ?? 'unknown error' : 'unknown error');
    //  final jsonResponse2 = jsonDecode(response.body);
    //  EasyLoading.showError(jsonResponse2['message']);
      print('error');


    }
  }

}