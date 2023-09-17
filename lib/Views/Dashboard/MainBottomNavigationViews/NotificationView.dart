import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:teamcdcapp/Views/Dashboard/MainBottomNavigationViews/MainBottomnavigationViews.dart';


class NotificationViewDesign extends StatefulWidget {
  NotificationViewDesign() : super();

  @override
  NotificationViewDesignState createState() => NotificationViewDesignState();
}

class NotificationViewDesignState extends State<NotificationViewDesign>  {
  /*SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.add_event,
      animatedIconTheme: IconThemeData(size: 28.0),
      backgroundColor: Colors.indigoAccent[900],
      visible: true,
      curve: Curves.bounceInOut,
      children: [
        SpeedDialChild(
          child: Icon(Icons.chrome_reader_mode, color: Colors.white),
          backgroundColor: Colors.pink,
          onTap: () => print('Pressed Read Later'),
          label: 'Read',
          labelStyle:
          TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: Icon(Icons.create, color: Colors.white),
          backgroundColor: Colors.cyan,
          onTap: () => print('Pressed Write'),
          label: 'Write',
          labelStyle:
          TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: Icon(Icons.laptop_chromebook, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => print('Pressed Code'),
          label: 'Code',
          labelStyle:
          TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
      ],
    );
  }*/
  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));

  }
  bool _flag = true;
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('NOTIFICATION'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: _colorFromHex("#0BADBC"),
        actions: [
          // Container(
          //   child: Row(
          //     children: [
          //       Padding(
          //           padding: EdgeInsets.only(right: 10.0),
          //           child: IconButton(
          //             icon: Icon(Icons.search,color: Colors.white),
          //             onPressed: (){
          //               print("Notification is printing");
          //               /*Navigator.push(
          //                 context,
          //                 MaterialPageRoute(builder: (context) => UserNotifications()),
          //               );*/
          //             },
          //
          //
          //           )
          //       ),
          //
          //       Padding(
          //           padding: EdgeInsets.only(right: 10.0),
          //           child: IconButton(
          //             icon: Icon(Icons.filter_alt_outlined,color: Colors.white),
          //             onPressed: () {
          //
          //             },
          //
          //
          //           )
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Container(
            //   margin: const EdgeInsets.all(15.0),
            //   padding: const EdgeInsets.all(3.0),
            //   decoration: BoxDecoration(
            //       border: Border.all(color: Colors.blueAccent)
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Row(
            //       children: [
            //         Expanded(
            //             child: SizedBox(
            //               height: 60,
            //               child: ElevatedButton(
            //                 onPressed: () {
            //                   print("Open button tapped");
            //                   setState(() => _flag = !_flag);
            //                   /*Navigator.push(
            //                         context,
            //                         MaterialPageRoute(builder: (context) => NewAccountView(),),
            //                       );*/
            //                 },
            //                 style: ElevatedButton.styleFrom(
            //                   //  primary: _flag ?Colors.grey: _colorFromHex("#0BADBC")
            //                     primary: _flag ?_colorFromHex("#0BADBC"):Colors.white
            //                 ),
            //                 child: Text(_flag ? "OPEN":"OPEN",
            //                   style: _flag ?TextStyle(color: Colors.white):TextStyle(color: Colors.black),
            //                 ),
            //               ),
            //             )),
            //         Expanded(
            //             child: SizedBox(
            //               height: 60,
            //               child: ElevatedButton(
            //                 onPressed: () {
            //                   print("Closed butten tapped");
            //                   setState(() => _flag = !_flag);
            //
            //                   /*Navigator.push(
            //                         context,
            //                         MaterialPageRoute(builder: (context) => LoginView(),),
            //                       );*/
            //                 },
            //
            //                 style: ElevatedButton.styleFrom(
            //                      primary: _flag ?Colors.white:_colorFromHex("#0BADBC")
            //                   //  primary: _flag ?_colorFromHex("#EDEDED"):Colors.white
            //                 ),
            //
            //                 child: Text(_flag ?"CLOSED":"CLOSED",
            //                   style: _flag ?TextStyle(color: Colors.black):TextStyle(color: Colors.white),
            //                 ),
            //               ),
            //             )
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            SizedBox(height: 250,),
            Center(
              child: Text(
                'No Data Found!',
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
