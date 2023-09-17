import 'dart:io';

import 'package:flutter/material.dart';
import 'package:teamcdcapp/Model/closedChatmodel.dart';
import 'package:teamcdcapp/Views/Dashboard/ChatMessageView.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../Views/websocket.dart';

class ClosedChatViewDesign extends StatefulWidget {
  ClosedChatViewDesign() : super();

  @override
  ClosedChatViewDesignState createState() => ClosedChatViewDesignState();
}

class ClosedChatViewDesignState extends State <ClosedChatViewDesign>{

  var isLoading = false;
//  final socket = io.io('ws://65.1.109.24:8080/chat');
// late final Socket socket1;
  void _openWhatsApp() async {
    // Replace the phone number and message with your own values
    String phoneNumber = '+918126084292'; // Enter the phone number with country code
    String message = 'Hello from my Flutter app!';

    String url = 'https://wa.me/$phoneNumber/?text=${Uri.parse(message)}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /*void socketTest() {
    print("Socket test function is calling");

    final socket = io.io('ws://65.1.109.24:8080/', <String, dynamic>{
      'transports': ['websocket'],
    });


    // Add event listeners and other socket operations here
    socket.on('connect', (_) {
      print('Socket connected');
    });

    socket.on('message', (data) {
      print('Received message: $data');
    });

    socket.on('disconnect', (_) {
      print('Socket disconnected');
    });

    // Connect to the server
    socket.connect();
  }*/

 /*void sockettesting() {
    // 10.11.4.59:8080
    socket1 = io.io('ws://65.1.109.24:8080/',<String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,

      // 'extraHeaders': {'foo': 'bar'} // optional
    }) as Socket;
    socket.on('connect', (_) {
      print('Socket connected');
    });

    socket.on('message', (data) {
      print('Received message: $data');
    });

    socket.on('disconnect', (_) {
      print('Socket disconnected');
    });
  }*/


  // Replace 'http://65.1.109.24:8080/' with the URL of your Socket.IO server
//  final socketUrl = 'http://65.1.109.24:8080/';

// Create a socket instance
  final socket = io.io('http://65.1.109.24:8080/', <String, dynamic>{
    'transports': ['websocket'],
  });

  void socketTest() {
    print("Socket test function is calling");

    // Add event listeners and other socket operations here
    socket.on('connect', (_) {
      print('Socket connected');
    });

    socket.on('message', (data) {
      print('Received message: $data');
    });

    socket.on('disconnect', (_) {
      print('Socket disconnected');
    });

    // Connect to the server
    socket.connect();
  }


 // List<ClosedMessageModel> filteredUsers = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
      CircularProgressIndicator();
    });
    // tabController = TabController(length: 2, vsync: this,);
      fetchData();
    fetchClosedData();
    // prefs;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<List<dynamic>>(
        future: fetchClosedData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final closedDataList = snapshot.data as List<dynamic>;
            /*final closedDataMapped = closedDataList
                .map<Map<String, dynamic>>((item) => {
              'fullName': item['fullName'] ?? 'Unknown',
              'phoneNo': item['phoneNo']?? 'No Phone Number',
            }).toList();*/

            return isLoading? Center(
              child: CircularProgressIndicator(),
            ):closedDataList.length !=0
                ? ListView.builder(
              itemCount: closedDataList.length,
              itemBuilder: (context, index) {
                final item = closedDataList[index];
                final displayName = item['fullName']?? item['phoneNo'];
                final displayMessage = item['lastMsg']?? '';
              //  final formattedDate = DateFormat.yMd().add_Hms().format(item.time);
                final apiDateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");
                final dateName = DateFormat('EEEE').format(DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS").parse(item['time']));

                ///////  here we are doing comparison between curret date with previous date

                final today = DateTime.now();
                final messageDate = apiDateFormat.parse(item['time']);
                final messageDateFormat = DateFormat('yyyy-MM-dd');
                final messageDateFormatted = messageDateFormat.format(messageDate);

                final messageTimeFormat = DateFormat.jm();
                final messageTimeFormatted = messageTimeFormat.format(messageDate);

                final isToday = messageDateFormatted == DateFormat('yyyy-MM-dd').format(today);

                String dateDisplay;
                if (isToday) {
                  dateDisplay = messageTimeFormatted;
                } else {
                  final dayFormat = DateFormat.EEEE();
                  final previousDayName = dayFormat.format(messageDate);
                  dateDisplay = previousDayName;
                }

                /*final now_date = DateFormat('d- M - yyyy ').format(DateTime.now());
                print("Today date is "+now_date);*/

                /*final dateTime = DateTime.now(); // Replace this with your actual DateTime object

                final dayFormat = DateFormat.E(); // E stands for the abbreviated day name (e.g., Mon)
                final dayName = dayFormat.format(dateTime);


                final formattedDate = apiDateFormat.parse(item['time']);

             //   final displayDateFormat = DateFormat.yMd().add_jm();
                final displayTimeFormat = DateFormat.jm();
                final formattedDisplayDate = displayTimeFormat.format(formattedDate);*/

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                     // backgroundImage: NetworkImage(url),
                      backgroundColor: Colors.lightBlueAccent,
                      child: Icon(Icons.person_2_outlined,size: 25,color: Colors.white,),
                      radius: 23.0,
                    ),
                    onTap: (){
                      print("This is chat list");
                      // print("No data found clicked");
                      // socket.emit('chat_message', {'message': 'Hello, server!'});
                      //  Navigator.push(context, MaterialPageRoute(builder: (context) => MySocket()),);
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(displayName,style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                        Text(dateDisplay,style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                      ],
                    ),
                    subtitle: Text(displayMessage,style: TextStyle(color: Colors.black),
                    maxLines: 1,),
                  ),
                );
              },
            ):Center(child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                child: Text("No data found",
                  style: TextStyle(fontWeight: FontWeight.bold),),),
            ));
          }
        },
      ),
    );
  }
  /*Future<List<ClosedMessageModel>> fetchClosedData() async {
    // Existing code ...

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var newtoken = sharedPreferences.getString("token");
    // var LatestToken = sharedPreferences.getString("firebase_token");
    // var newtoken = sharedPreferences.getString("token");
    final apiUrl = 'https://customerdigitalconnect.com/message-history/latest-messages';
    final token = newtoken.toString();
    // final apiUrl = 'https://customerdigitalconnect.com/message-history/latest-messages';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final closedList = jsonData[0]['closed'];

      final closedData = closedList
          .map<ClosedMessageModel>((item) => ClosedMessageModel.fromJson(item))
          .toList();
      print("The closed data list is:"+closedData.toString());
      return closedData;
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }*/

  Future<List<dynamic>> fetchData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var newtoken = sharedPreferences.getString("token");
    // var LatestToken = sharedPreferences.getString("firebase_token");
   // var newtoken = sharedPreferences.getString("token");
    final apiUrl = 'https://customerdigitalconnect.com/chatlist/latest-messages';
    final token = newtoken.toString();
   // final apiUrl = 'https://customerdigitalconnect.com/message-history/latest-messages';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body.toString());
      final openList = jsonData[0]['open'];
      print("The openlist is:"+openList.toString());
      print(response.statusCode);
      print(response.body);
      final opendata = openList
          .map<Map<String, dynamic>>((item) => {
        'fullName': item['fullName'],
        'phoneNo': item['phoneNo'],
      }).toList();

      print("The open data list is:"+opendata.toString());
      return[openList];
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }
  Future<List<Map<String, dynamic>>> fetchClosedData() async {
    isLoading = false;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");

  //  final apiUrl = 'https://customerdigitalconnect.com/message-history/latest-messages';
    final apiUrl = 'https://customerdigitalconnect.com/chatlist/latest-messages';
    final token = newToken.toString();

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {



      final jsonData = json.decode(response.body);
      final closedList = jsonData[0]['closed'];

      final closedData = closedList
          .map<Map<String, dynamic>>((item) => {
        'fullName': item['fullName'],
        'phoneNo': item['phoneNo'],
        'lastMsg':item['lastMsg'],
        'time':item['time'],
      })
          .toList();
      print("The closed data list is:"+closedData.toString());

      return closedData;
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }



}