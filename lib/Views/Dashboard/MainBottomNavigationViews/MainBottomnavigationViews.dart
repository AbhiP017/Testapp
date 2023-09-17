
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:teamcdcapp/DemoViews/DemoViewone.dart';
import 'package:teamcdcapp/DemoViews/TestUI.dart';
import 'package:teamcdcapp/Views/Dashboard/MainBottomNavigationViews/ChatlistingTabs.dart';
import 'package:teamcdcapp/Views/Dashboard/MainBottomNavigationViews/Dashboard_Home.dart';
import 'package:teamcdcapp/Views/Dashboard/MainBottomNavigationViews/NotificationView.dart';
import 'FABBottomNavigationBar.dart';
import 'MainChatListview.dart';
import 'event_bus.dart';



class BottomNavigationBarView extends StatefulWidget{
  final int? selectedIndex;

  BottomNavigationBarView({Key? key,this.selectedIndex}) : super(key: key);
  @override
  BottomNavigationBarState createState() => BottomNavigationBarState();
}

/// This is the private State class that goes with MyStatefulWidget.
class BottomNavigationBarState extends State<BottomNavigationBarView> {
  // late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String? _message = '';
  int? _selectedIndex = 0;


  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));

  }

  /// To create new ticket open TicketCreate Page
  /*final widgetOptions1 = [
    CreateTicketView()
  ];*/

  /// Widget List for bottom Navigation Items
  final widgetOptions = [
    Dashboard(),
    chatLisitingTab(),
   // WhatsappChatViewDesign(),
   // MainChatViewDesign(),
    NotificationViewDesign(),
    MainChatViewDesign(),
   // MyTestDesign(),
   // ListViewTest()
   // Dashboard(),
   // AllTickets(),
  //  AllReportTickets(),
    //  MultiLevelDropDownExample(),
  //  ProfileView(),
    // MyTestDesign()
    //  MyTestView(),
  ];

  /// When click on bottom Navigation item then to update selectedIndex
  void _onItemTapped(int? index) {
    setState(() {
      _selectedIndex = index;
      print("==selectedIndex" + index.toString());
      if (index == 2) {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => TicketCreate()),);
      }
      else if (index == 1) {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => UserFilterDemo()),);
      }
      else if (index == 3) {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationList()),);
        // socket();
      }
      // else if (index == 4) {
      //   // Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()),);
      // }
    });
  }

  /// When Click on back button  asked for exit



  @override
  Widget build(BuildContext context) {
    // socket();
    Color color1 = _colorFromHex("#00ABC5");
    return  Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex!),
      ),

      //
      bottomNavigationBar: FABBottomAppBar(
        centerItemText: '',
        color: Colors.grey,
        selectedColor:color1,
        // here I made change for initial index
        initialIndex: _selectedIndex,
        notchedShape: CircularNotchedRectangle(),
        onTabSelected: _onItemTapped,
        selectedFontSize: 5,
        items: [
          FABBottomAppBarItem(iconData: Icons.home, text: 'Home',),
          FABBottomAppBarItem(iconData: Icons.inbox, text: 'Inbox'),
          FABBottomAppBarItem(iconData: Icons.notification_add_outlined, text: 'Notification'),
          FABBottomAppBarItem(iconData: Icons.more_horiz, text: 'Profile',),
        ],
      ),
     // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //  floatingActionButton: _buildFab(context), // This trailing comma makes auto-formatting nicer for build methods.
     // floatingActionButton: buildSpeedDial(), // This trailing comma makes auto-formatting nicer for build methods.
    );

  }
  ///// expandable floating action button
  /*SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.add_event,
      animatedIconTheme: IconThemeData(size: 28.0),
     // backgroundColor: ColorCodeFromHexCode.colorFromHex("#00ABC5"),
      backgroundColor: Colors.cyan,
      visible: true,
      curve: Curves.bounceInOut,
      children: [
        SpeedDialChild(
          child: Icon(Icons.edit, color: Colors.white),
          backgroundColor: Colors.pink,
          onTap: () {
            print('create ticket');
            */
  /*Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateTicketView()),
            );*/
  /*
          },
          label: 'Create Ticket',
          labelStyle:
          TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: Icon(Icons.person, color: Colors.white),
          backgroundColor: Colors.cyan,
          onTap: () {
            print('Profile');
            */
  /*Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfileUpdateView()),
            );*/
  /*
          },
          label: 'Profile',
          labelStyle:
          TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: Icon(Icons.laptop_chromebook, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () {
            print('Dashboard');
            */
  /*Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 0,)),
            );*/
  /*
          },
          label: 'Dashboard',
          labelStyle:
          TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
      ],
    );
  }*/

  /// Center fab button for creating ticket
  /*Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      foregroundColor:Colors.white,
      backgroundColor:  ColorCodeFromHexCode.colorFromHex("#00ABC5"),
      onPressed: () {

        Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTicketView()),);
      },
      tooltip: 'Increment',
      child: Icon(Icons.add),

      elevation: 2.0,
    );
  }*/

  // socket() {
  //   Socket socket1 = io('http://10.11.4.59:8080', <String, dynamic>{
  //     'transports': ['websocket'],
  //     'autoConnect': false,
  //     // 'extraHeaders': {'foo': 'bar'} // optional
  //   });
  //   socket1.connect();
  //   socket1.on("track", (data) {
  //     print("engineer coOrdinate: "+data["lat"]);
  //   });
  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.selectedIndex != null){
      _selectedIndex = widget.selectedIndex;
    }

    eventBus.on<OnTabChangeEvent>().listen((event) {
      print("Event received:- "+event.selectedIndex.toString());
      setState(() {
        _selectedIndex = event.selectedIndex;
      });
    });
    getMessage();

  }

  void getMessage(){
    /*FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      _message = message.data["notification"]["title"];


      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });*/
  }

  showNotification(String message) async {
    /*var android =  AndroidNotificationDetails(
        'channel id', 'channel NAME',
        priority: Priority.high,importance: Importance.max
    );
    var iOS =  IOSNotificationDetails();
    var platform =  NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, message, "", platform,
        payload: 'AndroidCoding.in');*/
  }

  Future onSelectNotification(String? payload) async{
    debugPrint("payload : $payload");

    /*Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => NotificationList(),
      ),
          (route) => false,//if you want to disable back feature set to false
    );*/

  }

}

