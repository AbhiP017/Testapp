import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamcdcapp/Model/Openchatmodel.dart';
import 'package:teamcdcapp/Views/Dashboard/ChatMessageView.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teamcdcapp/Views/Dashboard/ChatViewScreen.dart';
import 'package:teamcdcapp/Views/UserChatViews/chatScreen.dart';
import 'package:teamcdcapp/Views/UserChatViews/userchat.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_tts/flutter_tts.dart';



import 'ChatCoversationView.dart';


class OpenChatViewDesign extends StatefulWidget {
  OpenChatViewDesign() : super();

  @override
  OpenChatViewState createState() => OpenChatViewState();
}

class OpenChatViewState extends State<OpenChatViewDesign>  {

  FlutterTts flutterTts = FlutterTts();
  bool isNewMessage = false;
  Timer? dataRefreshTimer;

  List<Map<String, dynamic>> openlistData = [];


  ///// Hex colour code
  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
  //String? phoneNumber;
//  late Timer timer;


  void startDataRefreshTimer() {
    const refreshInterval = Duration(seconds: 15); // Set your desired refresh interval

    dataRefreshTimer = Timer.periodic(refreshInterval, (timer) async {
      // Call your openData function here to update the list
      final updatedData = await openData();

      // Update your UI with the updated data
      setState(() {
        // Assign the updated data to your state variable here
        // For example, if you have a state variable called openlistData:
        openlistData = updatedData;
      });
    });
  }

  Future<void> playMessageReceivedSound() async {
    print("playMessageReceivedSound function is called");
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);

    await flutterTts.speak('You have a new message');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startDataRefreshTimer();
  //  playMessageReceivedSound();
   // fetchOpenData();
 //   openData();
  //  autoRefreshDetails();
   // tabController = TabController(length: 2, vsync: this,);
  //  fetchData();
    // prefs;
  }


  @override
  /*void dispose() {
    // TODO: implement dispose
    super.dispose();
    // this will stop api calling
    if (timer != null) {
      timer.cancel();
    }
  }*/

  ///// Conversational widget screen

  /*Widget conversation(
      String url, String name, String message, String time, bool messageSeen) {
    return InkWell(
      onTap: () {
        print("This is chat list");
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen()),);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(url),
              radius: 25.0,

            ),
            SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(time),
                    ],
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    children: [
                      Expanded(child: Text(message)),
                      if (messageSeen)
                        Icon(
                          Icons.check_circle,
                          size: 16.0,
                          color: Colors.green,
                        ),
                      if (!messageSeen)
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.grey,
                          size: 16.0,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }*/

  Future<SharedPreferences> getSharedPreferences() async {
    return await SharedPreferences.getInstance();

  }


  Widget build(BuildContext context) {
    return Scaffold(



      body:FutureBuilder<List<dynamic>>(
       future: openData(),
       builder: (context, snapshot) {
       if (snapshot.connectionState == ConnectionState.waiting) {
      // return Center(child: CircularProgressIndicator());
         return Center(
           child: Container(
             height: 20,
             child: CircularProgressIndicator(),
           ),
         );
       } else if (snapshot.hasError) {
         return Text('Error: ${snapshot.error}');
       } else {
       final openedDataList = snapshot.data as List<dynamic>;
       /*final closedDataMapped = openedDataList
        .map<Map<String, dynamic>>((item) => {
       'fullName': item['fullName'] ?? 'Unknown',
       'phoneNo': item['phoneNo']?? 'No Phone Number',
       }).toList();*/
       final openMessages = snapshot.data;
       bool shouldPlaySound = false;
      // DateTime lastViewedTime = DateTime.parse(getSharedPreferences().('lastViewedTime'));



       // Call isNewMessage function here to play incoming message sound
      // isNewMessage(shouldPlaySound);
       return ListView.builder(
         itemCount: openedDataList.length,
         itemBuilder: (context, index) {
           final item = openedDataList[index];
           var fullName = item['fullName'] ?? '';
           var phoneNo = item['phoneNo'] ?? '';

           String formattedPhoneNo = '+91 ' + phoneNo.substring(2);

           String displayName;
           if (fullName.isNotEmpty && fullName != phoneNo) {
             displayName = fullName;
           }
           else {
             // If the name is not available or is the same as the phone number, format the phone number
             displayName = '+91 ' + phoneNo.substring(2);
           }

           print("phone number is: $formattedPhoneNo");
           print('displayName or number is: $displayName');
           final displayMessage = item['lastMsg']?? '';
           final displaylabel = item['customerLabel']?? '';
           //  final formattedDate = DateFormat.yMd().add_Hms().format(item.time);
         //  final apiDateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");
           final messageTime = DateTime.parse(item['time']);
           print("display label is: $displaylabel");

           if (messageTime.isAfter(DateTime.now().subtract(Duration(seconds: 5))) && isNewMessage) {
             playMessageReceivedSound();
             isNewMessage = false; // Reset the flag
           }

           final apiDateFormat = DateFormat("yyyy-MM-ddTHH:mm");
         //  final dateName = DateFormat('EEEE').format(DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS").parse(item['time']));

           ///////  here we are doing comparison between current date with previous date

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
           // Call isNewMessage function here to play incoming message sound



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
                 Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreenArea(userPhoneNumber:item['phoneNo']??item['fullName'],
                   userFullName:item['fullName']??item['phoneNo'] ,)),);
               //  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreenArea(userPhoneNumber: item['phoneNo']??item['fullName'],)),);
               },
               title: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text(
                     displayName,
                     style: TextStyle(
                       fontSize: 14,
                       fontWeight: FontWeight.bold,
                     ),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis, // Ensure this property is not causing issues.
                     textAlign: TextAlign.start, // Ensure this property is not causing issues.
                   ),
                   Text(dateDisplay,style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                 ],
               ),
               subtitle: Align(
                 alignment: Alignment.centerLeft,
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(displayMessage,style: TextStyle(color: Colors.black),
                     maxLines: 1,
                     ),
                     SizedBox(height: 10,),
                     if (displaylabel.isNotEmpty) // Check if displayLabel is not empty
                       Text(
                         displaylabel,
                         style: TextStyle(color: Colors.black),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                   ],
                 ),
               ),
             ),
           );
         },
         );
              }
             },
            ),

           );
          }



////// API Calling Here


  Future<List<Map<String, dynamic>>> openData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");
    sharedPreferences.setString('lastReceivedTime', DateTime.now().toString());

  //  final apiUrl = 'https://customerdigitalconnect.com/message-history/latest-messages';
    final apiUrl = 'https://customerdigitalconnect.com/chatlist/latest-messages';
    final token = newToken.toString();

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200)
    {
      final jsonData = json.decode(response.body);
      final closedList = jsonData[0]['open'];

      // add if need
     // final lastReceivedTime = DateTime.parse(sharedPreferences.getString('lastReceivedTime'));
      final lastReceivedTimeString = sharedPreferences.getString('lastReceivedTime');
      final lastReceivedTime = lastReceivedTimeString != null
          ? DateTime.parse(lastReceivedTimeString)
          : DateTime.now();

      final openlistData = closedList.map<Map<String, dynamic>>((item) {
        final messageTime = DateTime.parse(item['time']);

        // Check if the message is newer than the last received time
        if (messageTime.isAfter(lastReceivedTime)) {
          isNewMessage = true;
        }

        return {
          'id': item['id'],
          'fullName': item['fullName'],
          'phoneNo': item['phoneNo'],
          'lastMsg': item['lastMsg'],
          'customerLabel': item['customerLabel'],
          'time': item['time'],
        };
      }).toList();
      print("The latest open data list is:"+openlistData.toString());

      // final lastViewedTime = DateTime.parse(sharedPreferences.getString('lastViewedTime'));
      // bool hasNewMessage = await isNewMessage(lastViewedTime);
      //
      // if (hasNewMessage) {
      //   await playMessageReceivedSound(); // Play the sound
      // }



      return openlistData;

    }
    else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }



  // Future<void> isNewMessage(bool shouldPlaySound) async {
  //   if (shouldPlaySound) {
  //     await flutterTts.setVolume(1.0);
  //     await flutterTts.setSpeechRate(1.0);
  //     await flutterTts.setPitch(1.0);
  //
  //     await flutterTts.speak("You have got a new message");
  //   }
  // }
  //// for incoming Voice message
  /*Future<void> playMessageReceivedSound() async {
    try {
      await flutterTts.setVolume(1.0);
      await flutterTts.setSpeechRate(1.0);
      await flutterTts.setPitch(1.0);
      await flutterTts.speak("You have a new message");
    } catch (e) {
      print("Error playing message received sound: $e");
    }
  }*/
  // bool isNewMessage(DateTime messageTime, DateTime lastReceivedTime) {
  //   // Define the time interval (in minutes) within which a new message is considered
  //   const newMessageTimeInterval = 5; // Change this to your desired interval
  //
  //   DateTime currentTime = DateTime.now();
  //   DateTime earliestNewMessageTime = lastReceivedTime;
  //   DateTime latestNewMessageTime = lastReceivedTime.add(Duration(minutes: newMessageTimeInterval));
  //
  //   return messageTime.isAfter(earliestNewMessageTime) && messageTime.isBefore(latestNewMessageTime);
  // }



}
