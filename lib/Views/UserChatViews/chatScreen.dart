import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamcdcapp/Model/ActiveUsers.dart';
import 'package:teamcdcapp/Model/activelabelList.dart';
import 'package:teamcdcapp/Model/quickrepliesList.dart';
import 'package:teamcdcapp/Views/Dashboard/MainBottomNavigationViews/ChatlistingTabs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
//import 'package:audioplayers/audioplayers.dart';



class CatalogOrderItem {
  final String productRetailerId;
  final int quantity;
  final double itemPrice;
  final String currency;
  double totalPrice;

  CatalogOrderItem({
    required this.productRetailerId,
    required this.quantity,
    required this.itemPrice,
    required this.currency,
    required this.totalPrice,
  });
}

class ChatScreenArea extends StatefulWidget {

  final String userPhoneNumber;
  final String userFullName;
  ChatScreenArea({required this.userPhoneNumber, required this.userFullName});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreenArea> {
  List<Map<String, dynamic>> chatHistory = [];
//  List<Map<String, dynamic>> MainchatHistory = [];
  List<String> sentMessagetoUser = [];
  List<String> selectedTemplates = [];
  String selectedTemplateName = "";
  List<User> activeusers = [];
  List<QuickReply> quickReplies = [];
  List<Activelabel> activelabels = [];
  List<CatalogOrderItem> catalogOrderItems = [];
 // GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  FlutterTts flutterTts = FlutterTts();
 // AudioPlayer audioPlayer = AudioPlayer();//// For playing a message sound
  bool isPlaying = false;
  // Create an instance of AudioPlayer
  final AudioPlayer audioPlayer1 = AudioPlayer();
  bool isEmojiPickerVisible = false;
  Emoji? selectedEmoji;
  Timer? dataRefreshTimer;
  File? _selectedImage;
  String currentlyPlayingAudioUrl = '';

  final TextEditingController messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();    ///   for displaying last message in chat screen

  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://65.1.109.24:8080/chat'), // Replace with your WebSocket server URL
  );
  final StreamController<String> _messagesStreamController = StreamController();
  final StreamController<String> _incomingMessagesStreamController = StreamController();
  bool _isInitialScrollComplete = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
 // bool _isScrolledToBottom = true;

  Future<void> _showDropdownPopup(BuildContext context) async {
    User? selectedUser;
    await getAlluser();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Assigned To'),
          content: DropdownButtonFormField<User>(
            value: activeusers.isNotEmpty ? activeusers[0] : null,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select User',
                hintText: 'Select User'
            ),
            validator: (value) =>
            value == null ? 'Please select a user' : null,
            onChanged: (User? newValue) {
              setState(() {
                selectedUser = newValue;
                print("Active selected user");
                print("the selected user is$selectedUser"); // Update selected user

                if (selectedUser != null) {
                  _assignUserOnInit(selectedUser!.userId);
                }


                Navigator.of(context).pop(); // Close the dialog
              });
            },
            items: activeusers.map((User user) {
              return DropdownMenuItem<User>(
                value: user,
                child: Text('${user.firstName} ${user.lastName}'),
              );
            }).toList(),
          ),
        );
      },
    );
  }
  Future openpopupWindow(){
    return showModalBottomSheet(context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Handle image attachment
                        Navigator.pop(context);
                        //_handleImageAttachment();
                        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                        // if (result != null) {
                        //   String filePath = result.files.single.path!;
                        //   String recipientPhoneNumber = widget.userPhoneNumber;
                        //
                        //   // Add the image message to the chat history
                        //   final messageEntry = {
                        //     "messagetype": "image",
                        //     "fileUrl": "URL_OF_THE_UPLOADED_IMAGE", // You may need to set the URL of the uploaded image
                        //     // Add other necessary message data
                        //   };
                        //   chatHistory.add(messageEntry);
                        //
                        //
                        //
                        //   // await sendDocumentToWhatsApp(filePath, recipientPhoneNumber);
                        //   await sendImageToWhatsApp(filePath, recipientPhoneNumber);
                        // //  await fetchChatHistory();
                        // } else {
                        //   // User canceled the file picking
                        // }
                        if (result != null) {
                        String filePath = result.files.single.path!;
                        print("The new file path is $filePath");
                         String recipientPhoneNumber = widget.userPhoneNumber;
                        final now = DateTime.now();


                          final formattedDateTime = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").format(now);

                        final fileUrl = await sendImageToWhatsApp(filePath, recipientPhoneNumber);
                        print("before file url");
                        print("The file url is$fileUrl");
                        var name = widget.userFullName;
                        if (fileUrl != null){
                          final chatMessage = {
                            'type': 'Sender', // or 'Receiver' as appropriate
                            'messagetype': 'image',
                            'message': fileUrl, // Set the message to the fileUrl
                            'name': name, // Replace with the actual sender's name
                            'time': formattedDateTime,
                            'fileUrl': fileUrl, // Set the fileUrl in the chat message
                          };
                          chatHistory.add(chatMessage);
                          // dataRefreshTimer = Timer.periodic(Duration(seconds: 1), (timer) {
                          //   fetchChatHistory();
                          // });
                        }else {
                          // Handle the case where sending the image failed
                          print("Failed to send image. File URL is null.");
                        }
                      } else{
                          print("User canceled image selection.");
                        }
                        },
                      child: Icon(
                        Icons.photo,
                        color: Colors.white,
                        size: 25.0,
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), primary: Colors.purpleAccent),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(

                      onPressed: () async {
                        // Handle document attachment
                        Navigator.pop(context);
                        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);


                        if (result != null) {
                          String filePath = result.files.single.path!;
                          String recipientPhoneNumber = widget.userPhoneNumber;
                        //  String serverBaseUrl = 'https://customerdigitalconnect.com/messagefile/';
                         // String filePath = result.files.single.path;
                        //   String fileName = filePath.split('/').last; // Extract the file name from the file path
                        //   String fileUrl = serverBaseUrl + fileName;
                        //   messageController.text = fileUrl;
                           await sendDocumentToWhatsApp(filePath, recipientPhoneNumber);
                       //   await sendDocumentToWhatsApp(filePath, recipientPhoneNumber);
                        } else {
                          // User canceled the file picking
                        }
                      },
                      child: Center(
                        child: Icon(
                          Icons.file_open,
                          color: Colors.white,
                          size: 25.0,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), primary: Colors.blue),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Handle document attachment
                        Navigator.pop(context);
                        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);


                        if (result != null) {
                          String filePath = result.files.single.path!;
                          String recipientPhoneNumber = widget.userPhoneNumber;

                          // await sendDocumentToWhatsApp(filePath, recipientPhoneNumber);
                          await sendAudioToWhatsApp(filePath, recipientPhoneNumber);
                        } else {
                          // User canceled the file picking
                        }
                      },
                      child: Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 25.0,
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), primary: Colors.orange),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Handle document attachment
                        Navigator.pop(context);
                        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);


                        if (result != null) {
                          String filePath = result.files.single.path!;
                          String recipientPhoneNumber = widget.userPhoneNumber;

                          // await sendDocumentToWhatsApp(filePath, recipientPhoneNumber);
                          await sendvedioToWhatsApp(filePath, recipientPhoneNumber);
                        } else {
                          // User canceled the file picking
                        }
                      },
                      child: Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 25.0,
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), primary: Colors.green),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Photo'),
                  ),
                  // SizedBox(width: 10,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Document'),
                  ),
                  // SizedBox(width: 10,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Audio'),
                  ),
                  // SizedBox(width: 10,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Video'),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // For template
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Handle image attachment
                        Navigator.pop(context);
                        //  await sendTemplateToWhatsApp();
                        await openTemplatePopup(context);

                      },
                      child: Icon(
                        Icons.insert_drive_file,
                        color: Colors.white,
                        size: 25.0,
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), primary: Colors.purpleAccent),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Handle image attachment
                        Navigator.pop(context);
                        //  await sendTemplateToWhatsApp();
                        //  await openTemplatePopup(context);
                        await CatlogAllProductssMessage();

                      },
                      child: Icon(
                        Icons.production_quantity_limits_sharp,
                        color: Colors.white,
                        size: 25.0,
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), primary: Colors.orangeAccent),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Handle image attachment
                        Navigator.pop(context);
                        //  await sendTemplateToWhatsApp();
                        //   await openTemplatePopup(context);
                        await CatlogFoodsandBaveragesMessage();
                      },
                      child: Icon(
                        Icons.emoji_food_beverage_outlined,
                        color: Colors.white,
                        size: 25.0,
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), primary: Colors.yellowAccent),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Handle image attachment
                        Navigator.pop(context);
                        await sendCatlogdrinksMessage();
                        //  await sendTemplateToWhatsApp();
                        //  await openTemplatePopup(context);

                      },
                      child: Icon(
                        Icons.local_drink_sharp,
                        color: Colors.white,
                        size: 25.0,
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), primary: Colors.cyanAccent),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Templates'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('All Products'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Food & Baverages'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Drinks'),
                  ),
                  // SizedBox(width: 10,),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Handle image attachment
                        Navigator.pop(context);
                        await CatlogSpasMessage();


                      },
                      child: Icon(
                        Icons.spa_outlined,
                        color: Colors.white,
                        size: 25.0,
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), primary: Colors.cyanAccent),
                    ),
                  ),
                  SizedBox(width: 35,),

                ],
              ),
              SizedBox(height: 10,),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Spa'),
                  ),


                  // SizedBox(width: 10,),
                ],
              ),
            ],
          );
        });
  }

  ////  open Notes popup
  void SendNotesDialog() {
    print("Send Notes button click");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notes'),
          content: Container(
            width: double.maxFinite,
            height: 180,// Adjust the width as needed
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                //padding: EdgeInsets.all(12),
                child: Column(
                  children: [

                    TextField(
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      minLines: null,//Normal textInputField will be displayed
                      maxLines: 5,
                      //  controller: controllers,
                      decoration: InputDecoration(
                        hintText: 'Comment',
                        border: OutlineInputBorder(),

                        //  border: OutlineInputBorder(),
                        //  labelText: 'Attribute',
                      ),

                    ),
                  ],
                ),

              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                //_handleSendNotes;
                Navigator.pop(context);
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }
  // void startDataRefreshTimer() {
  //   const refreshInterval = Duration(seconds: 15); // Set your desired refresh interval
  //
  //   dataRefreshTimer = Timer.periodic(refreshInterval, (timer) async {
  //     // Call your openData function here to update the list
  //     final updatedData = await fetchChatHistory();
  //
  //     // Update your UI with the updated data
  //     setState(() {
  //       // Assign the updated data to your state variable here
  //       // For example, if you have a state variable called openlistData:
  //       chatHistory = updatedData;
  //     });
  //   });
  // }
  _scrollToEnd() {
    print("Scroll down automatically");
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
  // void scrollToLastMessage() {
  //    _scrollController.animateTo(
  //    _scrollController.position.maxScrollExtent,
  //    duration: Duration(milliseconds: 300),
  //    curve: Curves.easeOut,
  //    );
  // }
  void scrollToLastMessage() {
    print("scrollToLastMessage is working");
     _scrollController.animateTo(
     _scrollController.position.maxScrollExtent,
     duration: Duration(milliseconds: 1),
     curve: Curves.easeOut,
     );
  }

  @override
  void initState() {
    super.initState();

    _channel.stream.listen(_handleIncomingMessages);
   // _scrollController = ScrollController();
    fetchChatHistory();
    fetchActivelabels();
  }


  ///// Hex colour code
  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  // Future<void> speakMessage(String message) async {
  //   await flutterTts.setLanguage('en-US'); // Set the language, adjust as needed
  //   await flutterTts.speak(message);
  // }

  Future<void> convertTextToSpeech(String text) async {
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.setLanguage('hi-IN');

    // Play the speech audio
    await flutterTts.speak(text);
  }

  void playNotificationSound(String senderName) {
    String message = "You have a new message from $senderName";
   // speakMessage(message);
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 350, // Set a specific height for the bottom sheet
          child: Column(
            children: [
              Expanded(
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {

                    String selectedEmoji = emoji.emoji;
                    String recipientPhoneNumber = widget.userPhoneNumber;
                    messageController.text = selectedEmoji;
                    sendStickers(selectedEmoji, recipientPhoneNumber);
                    // Handle emoji selection
                    // setState(() {
                    //   selectedEmoji = emoji;
                    // });
                    Navigator.pop(context);
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Close the bottom sheet
                  Navigator.pop(context);
                },
                child: Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }
  void _scrollToLast() {
    _scrollController.animateTo(
      0.0, // Scroll to the top (the most recent message)
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    ///  for go to bottom
   // _scrollToLast();

    return Scaffold(
      backgroundColor:_colorFromHex("#ece5dd"),
      appBar: AppBar(
        title: Row(
          children: [
            Text('${widget.userFullName}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
            IconButton(
              icon: Icon(Icons.label,color: Colors.white),
              onPressed: (){
                _showlabeltagDialog();
                // Navigator.of(context).pop();

              },),
          ],
        ),
        backgroundColor: _colorFromHex("#0BADBC"),
        actions: [

          IconButton(
            icon: Icon(Icons.menu,color: Colors.white),
            onPressed: (){
              _showDropdownPopup(context);
              // Navigator.of(context).pop();

            },),
          IconButton(
            icon: Icon(Icons.roller_shades_closed_outlined,color: Colors.white),
            onPressed:(){
              closeChat();
              print("closed chat");
            },
          ),
        ],
      ),
      body: Column(
        children:[
          Expanded(
             child: ListView.builder(
             //  key: _listKey,
               controller: _scrollController,
               reverse: false,
              shrinkWrap: true,
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
               final chatMessage = chatHistory[index];
               if(index==chatHistory.length-1){
                 print("chatMessage data");
                 print(chatMessage.toString());
               }
                final isSender = chatMessage['type'] == 'Sender';
               final alignment = isSender ? MainAxisAlignment.end : MainAxisAlignment.start;
               final bgColor = isSender ? _colorFromHex("#dcf8c6"): Colors.white;

               final apiDateFormat = DateFormat("yyyy-MM-ddTHH:mm");
               final apiDateFormatnew = DateFormat("yyyy-MM-dd HH:mm:ss");

               final today = DateTime.now();
               var messageDate;
               try {
                 messageDate = apiDateFormat.parse(chatMessage['time'] ?? '');
               } on Exception catch (e) {
                // messageDate = apiDateFormatnew.parse(chatMessage['time'] ?? '');
                 messageDate = DateTime.now();
                 // TODO
               }
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
                 //  print("dayFormat is:$dayFormat");
                 final previousDayName = dayFormat.format(messageDate);
                 //  print("dayFormat is:$dayFormat");

                 final oneWeekAgo = today.subtract(Duration(days: 7));
                 final oneMonthAgo = today.subtract(Duration(days: 30));

                 if (messageDate.isAfter(oneWeekAgo)) {
                   final dateFormatter = DateFormat('dd-MM-yyyy');
                   dateDisplay = " (${dayFormat.format(messageDate)}), ${dateFormatter.format(messageDate)}";
                 } else if (messageDate.isAfter(oneMonthAgo)) {
                   final dateFormatter = DateFormat('dd-MM-yyyy');
                   dateDisplay = "Last month (${dayFormat.format(messageDate)}), ${dateFormatter.format(messageDate)}";
                   // dateDisplay = "Last month";
                 } else {
                   dateDisplay = previousDayName;
                 }
               }
               final isImageMessage = chatMessage['messagetype'] == 'image';

               // if (isImageMessage) {
               //   return Image.network(
               //     chatMessage['message'], // URL of the image
               //     width: 150, // Adjust the width as needed
               //     height: 150, // Adjust the height as needed
               //     // ... other parameters
               //   );
               // } else {
               //   // Build your other types of chat messages here
               // }

               Widget imageWidget = SizedBox.shrink();
               if (chatMessage['filePath'] != null &&
                   chatMessage['localMessageType'] != null &&
                   chatMessage['localMessageType'] == "image") {
                 imageWidget = Align(
                   alignment: isSender?Alignment.centerRight:Alignment.centerLeft,
                   child: Image.file(
                     File(chatMessage['filePath']),
                     width: MediaQuery.of(context).size.width * 0.5,
                   ),
                 );
               } else if (chatMessage['messagetype'] == 'image') {
                 imageWidget = Align(
                   alignment: isSender?Alignment.centerRight:Alignment.centerLeft,
                   child: Image.network(
                     chatMessage['fileUrl'] ??
                         "https://d23qowwaqkh3fj.cloudfront.net/wp-content/uploads/2022/03/placeholder.png",
                     width: MediaQuery.of(context).size.width * 0.5,
                   ),
                 );
               }


               if (chatMessage['messagetype'] == 'template') {
                 final templatePreview = chatMessage['templatePreview'];
                 final templateBodyAttributes = chatMessage['templateBodyAttributes'] ?? []; // Use an empty list as default
                 final templateHeaderfileLink = chatMessage['templateHeaderfileLink'];

                 if (templatePreview != null) {
                   // Check if templateBodyAttributes is not null and not empty before performing replacement
                   final modifiedTemplatePreview = templateBodyAttributes.isNotEmpty
                       ? templatePreview.replaceAll('{{1}}', templateBodyAttributes[0])
                       : templatePreview;
                   final tempheaderfile = chatMessage['templateHeaderFileType'] == 'document'
                       ? Icon(Icons.picture_as_pdf,color: Colors.red,) : null;
                   String pdfLink = chatMessage['templateHeaderfileLink']; // Replace with your link
                   String pdfFileName = '';

                   if (pdfLink != null && Uri.parse(pdfLink).pathSegments.isNotEmpty) {
                     pdfFileName = Uri.parse(pdfLink).pathSegments.last;
                   }

                   return GestureDetector(
                     onTap: () {
                       // Handle template message click
                     },
                     child: Container(
                       padding: const EdgeInsets.symmetric(vertical: 8.0),
                       alignment: Alignment.centerRight,
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.end,
                         children: [
                           Container(
                             padding: const EdgeInsets.all(8.0),
                             decoration: BoxDecoration(
                               color: bgColor,
                               borderRadius: BorderRadius.circular(8.0),
                             ),
                             child: Column(
                               children: [

                                 if (tempheaderfile != null)
                                   Row(
                                     children: [
                                       Align(
                                         alignment: Alignment.centerLeft,
                                         child: Container(
                                           padding: EdgeInsets.symmetric(vertical: 8),
                                           decoration: BoxDecoration(
                                             borderRadius: BorderRadius.circular(10),
                                             // color: Colors.white,
                                           ),
                                           child: tempheaderfile,
                                         ),
                                       ),
                                       InkWell(
                                           onTap: () async {

                                             if (templateHeaderfileLink != null){

                                               if (await canLaunch(templateHeaderfileLink)) {
                                                 await launch(templateHeaderfileLink);
                                               } else {
                                                 print('Could not launch $templateHeaderfileLink');
                                               }

                                             }


                                           },
                                           child: Text(pdfFileName)),
                                     ],
                                   ),
                                 Align(
                                     alignment: Alignment.centerLeft,
                                     child: Text(modifiedTemplatePreview)),

                               ],
                             ),
                           ),

                         ],
                       ),
                     ),
                   );
                 } else {
                   return Container(); // Return an appropriate widget when templatePreview is missing
                 }
               }
               else if (chatMessage['messagetype'] == 'audio') {
                 return Container(
                   color: _colorFromHex("#dcf8c6"),
                   margin: EdgeInsets.all(8.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                           IconButton(
                             icon: Icon(
                               isPlaying && currentlyPlayingAudioUrl == chatMessage['message']
                                   ? Icons.stop
                                   : Icons.play_arrow,
                             ),
                             onPressed: () async {
                               // Toggle play/stop for audio
                               if (currentlyPlayingAudioUrl == chatMessage['message']) {
                                 // Stop playing
                                 audioPlayer1.stop();
                                 setState(() {
                                   isPlaying = false;
                                 });
                                 currentlyPlayingAudioUrl = '';
                               } else {
                                 // Play the audio
                                 await audioPlayer1.setUrl(chatMessage['message']);
                                 await audioPlayer1.play();
                                 setState(() {
                                   isPlaying = true;
                                 });
                                 currentlyPlayingAudioUrl = chatMessage['message'];
                               }
                             },
                           ),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(chatMessage['name'] ?? ''),
                                 Text('AUD-${chatMessage['filename'] ?? ''}'),
                               ],
                             ),
                           ),
                         ],
                       ),
                       // Progress bar
                       if (isPlaying && currentlyPlayingAudioUrl == chatMessage['message'])
                         StreamBuilder<Duration?>(
                           stream: audioPlayer1.durationStream,
                           builder: (context, snapshot) {
                             final duration = snapshot.data ?? Duration.zero;
                             return StreamBuilder<Duration>(
                               stream: audioPlayer1.positionStream,
                               builder: (context, snapshot) {
                                 final position = snapshot.data ?? Duration.zero;
                                 return LinearProgressIndicator(
                                   value: position.inMilliseconds.toDouble() /
                                       duration.inMilliseconds.toDouble(),
                                 );
                               },
                             );
                           },
                         ),
                     ],
                   ),
                 );
               }


               double c_width = MediaQuery.of(context).size.width*0.8;
               return Padding(
               // alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                 padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: alignment,
                  children: [
                    Container(
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isSender ? _colorFromHex("#dcf8c6"): Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),

                    child: Column(
                     // crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Text(
                        //     chatMessage['message']??'',
                        //     maxLines: null,
                        //     overflow: TextOverflow.ellipsis,
                        //     style: TextStyle(color: Colors.black),
                        //       ),
                        // ),
                        // Text(dateDisplay,style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: Colors.black),),

                        if (chatMessage['messagetype'] == 'text')
                          Align(
                            alignment: isSender?Alignment.centerRight:Alignment.centerLeft,
                            child:Container(
                              padding: const EdgeInsets.all(8.0),
                              width: c_width,
                              child: Text(
                                chatMessage['message']?? '',
                                maxLines: null,
                                softWrap: false,
                                //  overflow: TextOverflow.ellipsis,
                                overflow: TextOverflow.clip,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          // Regular text message


                        /*if (chatMessage['messagetype'] == 'image')
                        // Image message
                          if (chatMessage['fileUrl'] != null)
                            Image.network(
                              chatMessage['fileUrl'],
                              width: 200, // Adjust the width as needed
                            )
                          else
                            Image.file(
                              File(chatMessage['filePath']??''),
                              width: 200.0,
                            ),*/
                          // if (chatMessage['messagetype'] == 'image' && chatMessage['fileUrl'] != null)
                          imageWidget,
                          // Display incoming image
                          //   Image.network(
                          //     chatMessage['fileUrl'],
                          //     width: 200, // Adjust the width as needed
                          //   ),


                          if (chatMessage['messagetype'] == 'document') // Document message
                          GestureDetector(
                            onTap: () async {
                              // Implement opening the document URL here
                              final url = chatMessage['fileUrl']; // URL of the document
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                print('Could not launch $url');
                              }
                            },
                            child: Container(
                              width: 300,
                              child: Text(
                                chatMessage['filename']??'', // Display the filename as a link
                                style: TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,

                                ),
                                maxLines: null,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,

                              ),
                            ),
                          ),
                        if (chatMessage['messagetype'] == 'sticker') // Sticker message
                          Image.network(
                            chatMessage['fileUrl'], // Assuming 'fileUrl' key has the sticker URL
                            width: 100, // Adjust the width as needed
                          ),
                        if(chatMessage['type']=='Activity'&&chatMessage['messagetype']=='assigned')
                          Container(
                            width: 200,
                            // color: Colors.grey,
                            // Set the desired width for the Container
                            child: Center(

                              child: Text(
                                chatMessage['message'] ?? '',
                                style: TextStyle(color: Colors.black,),
                                softWrap: true, // Allow text to wrap to the next line
                              ),
                            ),
                          ),
                        /*if(chatMessage['type']=='interactive' && chatMessage['interactiveName'] =='drinks' )
                          Container(
                            width: 200,
                            color: Colors.yellow,
                            child: Center(

                              child: Text(
                                chatMessage['interactiveName'] ?? 'drinks',
                                style: TextStyle(color: Colors.black,),
                                softWrap: true, // Allow text to wrap to the next line
                              ),
                            ),
                          ),*/
                       if (chatMessage['type'] == 'Sender' &&
                         chatMessage['messagetype'] == 'interactive' &&
                         chatMessage['message'] == 'drinks')
                          // Display the catalog name for 'drinks' interactive messages
                         Align(
                             alignment: Alignment.centerLeft,
                            child: Container(
                            width: 200,
                             color: bgColor,
                             child: Row(
                               children: [
                                 // Container(
                                 //   height: 100,
                                 //     width: 40,
                                 //     child: Image(image:AssetImage('images/assets/drinks.jpeg'),)),
                                 Icon(Icons.local_drink_outlined,color: Colors.red,size: 40,),
                                 Text(
                                  chatMessage['message'] ?? 'drinks',
                                  style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.normal),
                                  softWrap: true,
                                 ),
                               ],
                             ),
                               ),
                                  ),
                        if (chatMessage['type'] == 'Sender' &&
                            chatMessage['messagetype'] == 'interactive' &&
                            chatMessage['message'] == 'foodAndBeverages')
                        // Display the catalog name for 'foodAndBeverages' interactive messages
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 200,
                              color: bgColor,
                              child: Row(
                                children: [
                                  Icon(Icons.emoji_food_beverage_sharp,color: Colors.red,size: 40,),
                                  Text(
                                    chatMessage['message'] ?? 'foodAndBeverages',
                                    style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.normal),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (chatMessage['type'] == 'Sender' &&
                            chatMessage['messagetype'] == 'interactive' &&
                            chatMessage['message'] == 'allProducts')
                        // Display the catalog name for 'allProducts' interactive messages
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 200,
                              color: bgColor,
                              child: Row(
                                children: [
                                  Icon(Icons.production_quantity_limits,color: Colors.red,size: 40,),
                                  Text(
                                    chatMessage['message'] ?? 'allProducts',
                                    style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.normal),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (chatMessage['type'] == 'Sender' &&
                            chatMessage['messagetype'] == 'interactive' &&
                            chatMessage['message'] == 'spa')
                        // Display the catalog name for 'spa' interactive messages
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 200,
                              color: bgColor,
                              child: Row(
                                children: [
                                  Icon(Icons.spa_outlined,color: Colors.red,size: 40,),
                                  Text(
                                    chatMessage['message'] ?? 'spa',
                                    style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.normal),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                            ),
                          ),


                        if (chatMessage['messagetype'] == 'order')

                           Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              SizedBox(height: 10),
                              if (chatMessage['catalogOrderItems'] != null)
                              Column(
                                children: List.generate(
                                  chatMessage['catalogOrderItems'].length,
                                      (index) {
                                    var item = chatMessage['catalogOrderItems'][index];
                                    return Container(
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('product Name:${item['productName']??''}'),
                                          Text('Product Retailer ID: ${item['product_retailer_id']}'),
                                          Text('Quantity: ${item['quantity']}'),
                                          Text('Item Price: ${item['item_price']}'),
                                          Text('Currency: ${item['currency']}'),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),

                            ],

                          ),
                           Row(
                         // mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            if (chatMessage['messageStatus'] == 'sending')
                              CircularProgressIndicator(),
                            if (chatMessage['messageStatus'] == 'sent')
                              Icon(Icons.done, color: Colors.grey),
                            if (chatMessage['messageStatus'] == 'delivered')
                              Row(
                                children: [
                                  Icon(Icons.done_all, color: Colors.grey),
                                  SizedBox(width: 2),
                                  // Icon(Icons.done_all, color: Colors.grey),
                                ],
                              ),
                            if (chatMessage['messageStatus'] == 'read')
                              Row(
                                children: [
                                  Icon(Icons.done_all, color: Colors.blue),
                                  SizedBox(width: 2),
                                  // Icon(Icons.done_all, color: Colors.blue),
                                ],
                              ),
                          ],
                        ),
                        // Text(chatMessage['time'] ?? ''),
                        Text(dateDisplay,style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                      ],
                        ),
                      ),
                     ],
                ),
               );

              },
              ),
          ),

          StreamBuilder<String>(
            stream: _incomingMessagesStreamController.stream,
            builder: (context, snapshot) {
              // _scrollController.animateTo(
              //   0.0,
              //   duration: Duration(milliseconds: 300),
              //   curve: Curves.easeOut,
              // );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent+ 400);
                } else {
                  setState(() => null);
                }
              });
              if (snapshot.hasData) {
                final incomingMessage = snapshot.data!;
                final messageParts = incomingMessage.split(':'); // Split message by colons

                if (messageParts.length >= 3) {
                  final senderName = messageParts[0].trim();
                  final messageType = messageParts[1].trim();
                  final messageContent = messageParts[2].trim();

                  // Check if the senderName matches the current userPhoneNumber
                  if (widget.userPhoneNumber == senderName || widget.userPhoneNumber == messageContent) {
                    // Display only messages sent by the current user
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 1.0),
                              child: Text(
                                messageContent,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }
              }

              return Container(); // Empty container if no new message or if the message doesn't match criteria
            },
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.grey[200],
                  // padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.insert_emoticon),

                        onPressed: _showEmojiPicker,
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            if (_selectedImage != null)
                              Image.file(
                                _selectedImage!,
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                            TextField(
                              controller: messageController,
                              decoration: InputDecoration.collapsed(
                                hintText: 'Type a message',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /*Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration.collapsed(
                              hintText: 'Type a message',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              )
                          ),
                        ),
                      ),*/


                      /// Container For popupwindow attachment
                      IconButton(
                        icon: Icon(Icons.attach_file),
                        onPressed: () {
                          print("Attachment button clicked");
                          // openattachment();
                          openpopupWindow();
                        },
                      ),

                      ///   for quick replies
                      IconButton(
                        icon: Icon(Icons.window), // Replace with your sticker icon
                        onPressed: ()  {
                          _showQuickRepliesDialog();
                        },
                      ),

                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed:  _handleSendMessage,
                      ),
                    ],
                  ),

                ),
              ),
              /// for displaying selected media here

            ],
          ),
             ],

      ),

    );
  }

  void _handleSendMessage() async {
    final messageContent = messageController.text;
    if (messageContent.isNotEmpty) {
      final outgoingMessage = {
        'type': 'Sender',
        'messagetype': 'text',
        'message': messageContent,
        'time': DateTime.now().toString(),
      };

      // Play notification sound for outgoing message

      String announcement = "You have sent a new message to ${widget.userFullName}. The message is: $messageContent";

      // Convert the announcement text to speech and play
     // convertTextToSpeech(announcement);

      setState(() {
        chatHistory.add(outgoingMessage);
      });

      // Convert outgoing message text to speech and play
      // final outgoingMessageText = outgoingMessage['message'] ?? '';
      //
      // // Convert outgoing message text to speech and play
      // await convertTextToSpeech(outgoingMessageText);

      bool messageSent = false;

      try {
        // Send the message to WhatsApp
        await sendMessageToWhatsApp(messageContent);
        messageSent = true;
      } catch (e) {
        print('Error sending message to WhatsApp: $e');
      }

      // Delay the removal of the temporary outgoing message to avoid flickering
      // if (messageSent) {
      //   Future.delayed(Duration(milliseconds: 100), () {
      //     setState(() {
      //       chatHistory.remove(outgoingMessage);
      //     });
      //     //  scrollToBottom();
      //   });
      //
      // } else {
      //   // Handle the case when the message couldn't be sent
      //   // Update message status or style as needed
      //   // For example: outgoingMessage['status'] = 'error';
      // }

      if (messageSent) {
        // Update the status of the sent message to 'sent'
        setState(() {
          // Find the index of the outgoing message in chatHistory
          final index = chatHistory.indexOf(outgoingMessage);
          if (index != -1) {
            chatHistory[index]['messageStatus'] = 'sent';
          }
        });
       // playTTSMessage("Recipient's Name");
      }
      else {
        // Handle the case when the message couldn't be sent

      }

      messageController.clear();
      // scrollToBottom();
    }
   // await fetchChatHistory();
  }
  Future<void> sendMessageToWhatsApp(String messageContent) async {

    print("sending message to user");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';
    final uId = sharedPreferences.getInt("userId");
    print("badal id is: $uId");

    // Replace these values with your actual data
    String recipientPhoneNumber = widget.userPhoneNumber;
    String recipientName = widget.userFullName;
    print(recipientPhoneNumber);

    final messageEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "text",
      "fromId": uId,
      "assignedto": 1,
      "fullname": recipientName,
      "text": {
        "preview_url": false,
        "body": messageContent,
      }
    };
    print("All fields"+messageEntry.toString());

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';

      // Convert the messageEntry map to JSON and set it as a form field
      request.fields['messageEntry'] = json.encode(messageEntry);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print(responseBody);
      if (response.statusCode == 200) {
        print('Message sent successfully.');
        setState(() {
          sentMessagetoUser.add(messageContent);
        });
      } else {
        print('Failed to send message. Status code: ${response
            .statusCode}, Response: $responseBody');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }
  /*void _handleIncomingMessages(dynamic data) {
    
    print("Received Data: $data");
    if (data != null) {
      final jsonData = json.decode(data as String);
      final String messageType = jsonData['messagetype'] ?? '';
      final String messageContent = jsonData['message'] ?? '';
      final String senderName = jsonData['name'] ?? '';
      final String senderPhoneNumber = jsonData['mobileNo'] ?? '';
      final String userType = jsonData['type'] ?? '';

      if (messageType == 'text' && messageContent.isNotEmpty) {
        if (widget.userPhoneNumber == senderPhoneNumber && userType == "Receiver") {
          setState(() {
            chatHistory.add({
              'type': 'Receiver',
              'messagetype': messageType,
              'message': messageContent,
              'name': senderName,
              'time': jsonData['time'],
            });
          });
         // Construct the announcement message
            //  String announcement = "You have got a new message from $senderName. The message says: $messageContent";
              String announcement = "You have got a new message from $senderName.";
            //  String announcement = "आपको $senderName से नया संदेश मिला है. संदेश कहता है: $messageContent";

              // Convert the announcement text to speech and play
              convertTextToSpeech(announcement);
        }
      }
      else if (messageType == 'order' && messageContent.isNotEmpty) {
        if (widget.userPhoneNumber == senderPhoneNumber && userType == "Receiver") {
          setState(() {
            chatHistory.add({
              'type': 'Receiver',
              'messagetype': messageType,
              'message': messageContent,
              'name': senderName,
              'time': jsonData['time'],
            });
          });
          // Construct the announcement message
          //  String announcement = "You have got a new message from $senderName. The message says: $messageContent";
          String announcement = "You have got a new message from $senderName.";
          //  String announcement = "आपको $senderName से नया संदेश मिला है. संदेश कहता है: $messageContent";

          // Convert the announcement text to speech and play
          convertTextToSpeech(announcement);
        }
      }

      // if (messageType == 'text' && messageContent.isNotEmpty) {
      //   if (widget.userPhoneNumber == senderPhoneNumber) {
      //     setState(() {
      //       chatHistory.add({
      //         'type': 'Receiver',
      //         'messagetype': messageType,
      //         'message': messageContent,
      //         'name': senderName,
      //         'time': jsonData['time'],
      //       });
      //     });
      //   //  playTTSMessage(senderName);
      //   //  convertTextToSpeech(messageContent);
      //     // Construct the announcement message
      //     String announcement = "You have got a new message from $senderName. The message says: $messageContent";
      //   //  String announcement = "आपको $senderName से नया संदेश मिला है. संदेश कहता है: $messageContent";
      //
      //     // Convert the announcement text to speech and play
      //     convertTextToSpeech(announcement);
      //
      //   }
      // }
      else if (messageType == 'image' && messageContent.isNotEmpty) {
        if (widget.userPhoneNumber == senderPhoneNumber) {
          setState(() {
            final baseUrl = 'https://customerdigitalconnect.com';
            final fileUrl = jsonData['fileUrl'];
            print('File URL is that: ${jsonData['fileUrl']}');

            // Check if the fileUrl is already a complete URL (starts with http or https)
            final imageUrl = fileUrl.startsWith('http') ? fileUrl : '$baseUrl$fileUrl';

            chatHistory.add({
              'type': 'Receiver',
              'messagetype': messageType,
              'message': imageUrl, // Store the complete image URL
              'name': senderName,
              'time': jsonData['time'],
            });
          });
        }
      }
      else if (messageType == 'document' && messageContent.isNotEmpty) {
        if (widget.userPhoneNumber == senderPhoneNumber) {
          setState(() {
            chatHistory.add({
              'type': 'Receiver',
              'messagetype': messageType,
              'message': jsonData['fileUrl'], // Store the document URL
              'name': senderName,
              'time': jsonData['time'],
            });
          });
        //  final incomingMessageText = messageContent ?? '';
          // Convert incoming message text to speech and play
        //  convertTextToSpeech(incomingMessageText);
        }
      }
     else if (messageType == 'audio' && messageContent.isNotEmpty) {
        if (widget.userPhoneNumber == senderPhoneNumber) {
          setState(() {
            chatHistory.add({
              'type': 'Receiver',
              'messagetype': messageType,
              'message': jsonData['fileUrl'], // Store the audio file URL
              'name': senderName,
              'time': jsonData['time'],
            });
          });
          // Play a notification sound or TTS for audio message
          // For example: playNotificationSound(senderName);
        }
      }
    }
  //  _listKey.currentState?.insertItem(chatHistory.length - 1);
  }*/
  void _handleIncomingMessages(dynamic data) {
    print("Received Data: $data");
    if (data != null) {
      final jsonData = json.decode(data as String);
      final String messageType = jsonData['messagetype'] ?? '';
      final String messageContent = jsonData['message'] ?? '';
      final String senderName = jsonData['name'] ?? '';
      final String senderPhoneNumber = jsonData['mobileNo'] ?? '';
      final String userType = jsonData['type'] ?? '';

      if (messageType == 'text' ||
          messageType == 'order'&& messageContent.isNotEmpty) {
        if (widget.userPhoneNumber == senderPhoneNumber && userType == "Receiver") {
          setState(() {
            chatHistory.add({
              'type': 'Receiver',
              'messagetype': messageType,
              'message': messageContent,
              'name': senderName,
              'time': jsonData['time'],
            });
          });
          fetchChatHistory();
          // Construct the announcement message
          String announcement = "You have got a new message from $senderName.";

          // Convert the announcement text to speech and play
          convertTextToSpeech(announcement);
        }
      } else if ((messageType == 'image' || messageType == 'document' || messageType == 'audio') && messageContent.isNotEmpty) {
        if (widget.userPhoneNumber == senderPhoneNumber && userType == "Receiver") {
          setState(() {
            final baseUrl = 'https://customerdigitalconnect.com';
            final fileUrl = jsonData['fileUrl'];

            // Check if the fileUrl is already a complete URL (starts with http or https)
            final mediaUrl = fileUrl.startsWith('http') ? fileUrl : '$baseUrl$fileUrl';

            chatHistory.add({
              'type': 'Receiver',
              'messagetype': messageType,
              'message': mediaUrl, // Store the complete media URL
              'name': senderName,
              'time': jsonData['time'],
            });
          });
          fetchChatHistory();
        }
      }
    }
  }

  /////  for fetching chat history
  Future<void> fetchChatHistory() async {

    print("fetchChatHistory calling");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl =
        'https://customerdigitalconnect.com/chatlist/history/number/${widget.userPhoneNumber}';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final chatHistoryData = json.decode(response.body) as List<dynamic>;
        print("the history data is:"+chatHistoryData.toString());

        setState(() {
          chatHistory.addAll(List.from(chatHistoryData));

        });
        // After adding chat history, scroll to the end
        // _scrollController.animateTo(
        //   0.0,
        //   duration: Duration(milliseconds: 300),
        //   curve: Curves.easeOut,
        // );


      } else {
        print('Failed to fetch chat history. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chat history: $e');
    }
  }

  Future<void> sendDocumentToWhatsApp(String filePath, String recipientPhoneNumber) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';

    final uId = sharedPreferences.getInt("userId");
    String recipientfullName = widget.userFullName;

    final messageEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "document",
      "fromId": uId.toString(),
      "caption": "testing",
      "assignedto": "1",
      "fullname": recipientfullName,
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['messageEntry'] = json.encode(messageEntry);

      // Open the file and add it as a part of the request
      var file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Document sent successfully.');
        // final sentDocumentMessage = {
        //   'type': 'Sender', // Or 'Receiver' depending on sender/receiver
        //   'messagetype': 'document',
        //   'message': 'Document',
        //   'time': DateTime.now().toString(),
        //   // Add any additional fields you need for document messages
        // };
        //
        // setState(() {
        //   chatHistory.add(sentDocumentMessage);
        // });
        fetchChatHistory();
      } else {
        print('Failed to send document. Status code: ${response.statusCode}, Response: $responseBody');
      }
    } catch (e) {
      print('Error sending document: $e');
    }
  }
///// for send image
  /*Future<void> sendImageToWhatsApp(String filePath, String recipientPhoneNumber) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';

    final uId = sharedPreferences.getInt("userId");

       var userfullname = widget.userFullName;
    final messageEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "image",
      "fromId": uId.toString(),
      "caption": "testing",
      "assignedto": "1",
      "fullname": userfullname,

    };
    // chatHistory.add(messageEntry);
    // setState(() {
    // });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['messageEntry'] = json.encode(messageEntry);

      // Open the file and add it as a part of the request
      var file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseJson = json.decode(responseBody);
      //  final fileUrl = responseJson['fileUrl']; // Replace 'fileUrl' with the actual key in your response

        // Now you can use the 'fileUrl' to display the image or perform other actions
      //  print('File URL: $fileUrl');
        print('image sent successfully.');
        final imageUrl = json.decode(responseBody)['fileUrl'];
        final sentImageMessage = {
          'type': 'Sender', // or 'Receiver' based on who sent it
          'messagetype': 'image',
          'message': imageUrl, // Replace with the actual image URL
          'name': userfullname, // Name of the sender
          'time': DateTime.now().toIso8601String(), // The timestamp of the message
        };

        // Add the new image message to chatHistory and trigger UI update
        setState(() {
          chatHistory.add(sentImageMessage);
        });
      } else {
        print('Failed to send document. Status code: ${response.statusCode}, Response: $responseBody');
      }
    } catch (e) {
      print('Error sending document: $e');
    }
  }*/
  Future<String?> sendImageToWhatsApp(String filePath, String recipientPhoneNumber) async {
    print("Send the image to whatsapp function calling");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';

    final uId = sharedPreferences.getInt("userId");
    var userfullname = widget.userFullName;

    final messageEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "Sender",
      "fromId": uId.toString(),
      "caption": "testing",
      "assignedto": "1",
      "fullname": userfullname,
      "filePath": filePath,
      "time": DateTime.now().toString(),
      "localMessageType": "image"
    };
    chatHistory.add(messageEntry);
    setState(() {

    });
    messageEntry['type'] = "image";
     print("The send image message entry is:$messageEntry");
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['messageEntry'] = json.encode(messageEntry);

      // Open the file and add it as a part of the request
      var file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);
      print("The file path is$file");

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Response Body is: $responseBody');
        final responseData = json.decode(responseBody);
        final fileUrl = responseData['fileUrl'];
        /*setState(() {
          final now = DateTime.now();
          final formattedDateTime = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").format(now);
          var name = widget.userFullName;
          final chatMessage = {
            'type': 'Sender', // or 'Receiver' as appropriate
            'messagetype': 'image',
            'message': fileUrl, // Set the message to the fileUrl
            'name': name, // Replace with the actual sender's name
            'time': formattedDateTime,
            'fileUrl': fileUrl, // Set the fileUrl in the chat message
          };
          chatHistory.add(chatMessage);
        });*/// Extract the file URL from the response
        // fetchChatHistory();
        print('Image sent successfully. File URL: $fileUrl');
        return fileUrl; // Return the file URL
      } else {
        print('Failed to send image. Status code: ${response.statusCode}, Response: $responseBody');
        return null; // Return null to indicate failure
      }
    } catch (e) {
      print('Error sending image: $e');
      return null; // Return null to indicate failure
    }
  }

  ///// for send audio
  Future<void> sendAudioToWhatsApp(String filePath, String recipientPhoneNumber) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';

    final uId = sharedPreferences.getInt("userId");

    final messageEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "audio",
      "fromId": uId.toString(),
      "caption": "testing",
      "assignedto": "1",
      "fullname": "badal badal",
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['messageEntry'] = json.encode(messageEntry);

      // Open the file and add it as a part of the request
      var file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Document sent successfully.');
        fetchChatHistory();
      } else {
        print('Failed to send document. Status code: ${response.statusCode}, Response: $responseBody');
      }
    } catch (e) {
      print('Error sending document: $e');
    }
  }
  ///// for send video
  Future<void> sendvedioToWhatsApp(String filePath, String recipientPhoneNumber) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';

    final uId = sharedPreferences.getInt("userId");

    final messageEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "video",
      "fromId": uId.toString(),
      "caption": "testing",
      "assignedto": "1",
      "fullname": "badal badal",
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['messageEntry'] = json.encode(messageEntry);

      // Open the file and add it as a part of the request
      var file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Document sent successfully.');
      } else {
        print('Failed to send document. Status code: ${response.statusCode}, Response: $responseBody');
      }
    } catch (e) {
      print('Error sending document: $e');
    }
  }

  ///   for send emoji and stickers
  Future<void> sendStickers(String filePath, String recipientPhoneNumber) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';

    final uId = sharedPreferences.getInt("userId");

    String recipientFullName = widget.userFullName;
    final messageEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "sticker",
      "fromId": uId.toString(),
      "caption": "testing",
      "assignedto": "1",
      "fullname": recipientFullName,
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['messageEntry'] = json.encode(messageEntry);

      // Open the file and add it as a part of the request
      var file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Sticker sent successfully.');
      } else {
        print('Failed to send sticker. Status code: ${response.statusCode}, Response: $responseBody');
      }
    } catch (e) {
      print('Error sending document: $e');
    }
  }

  //// for closed chat

  Future<void> closeChat() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl = 'https://customerdigitalconnect.com/chat-activity/closed'; // Replace this with your actual API endpoint
    String recipientPhoneNumber = widget.userPhoneNumber;
    print(recipientPhoneNumber);
    final mobileNo = recipientPhoneNumber;
    final messageType = "closed";
    final fromId = 14;

    final messageData = {
      "mobileNo": mobileNo,
      "messagetype": messageType,
      "fromId": fromId,
    };

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(messageData),
      );

      if (response.statusCode == 200) {
        print('Chat closed successfully.');
        Navigator.push(context, MaterialPageRoute(builder: (context) => chatLisitingTab()),);
        // Perform any other actions or UI updates as needed after closing the chat.
      } else {
        print('Failed to close chat. Status code: ${response.statusCode}, Response: ${response.body}');
        final jsonResponse2 = response.body != null ? jsonDecode(response.body) : null;
        // final jsonResponse2 = jsonDecode(response.body);
        print("==error jsonResponse is that:" + jsonResponse2.toString());
        //  EasyLoading.showError(jsonResponse2!=null ? jsonResponse2['massage']:'unknown error');
      //  EasyLoading.showError(jsonResponse2 != null ? jsonResponse2['message'] ?? 'unknown error' : 'unknown error');
      }
    } catch (e) {
      print('Error closing chat: $e');
    }
  }
  Future<void> getAlluser()async{
    print("get all users function is calling");
    // final response = await http.get(Uri.parse('https://customerdigitalconnect.com/users/active'));
    final sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");
    final token = newToken.toString();

    final headers = {
      'Authorization': 'Bearer $token', // Add the token to the headers
    };

    final response = await http.get(
      Uri.parse('https://customerdigitalconnect.com/users/active'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final List<User> fetchedUsers = data.map((e) => User.fromJson(e)).toList();
      print("All active users");
      print(fetchedUsers.toString());
      //  final assignedToUserId = user.userId;
      if (fetchedUsers.isNotEmpty) {
        int assignedToUserId = fetchedUsers[0].userId;
        print("The userIddd$assignedToUserId");// Change this based on your logic
       // final prefs = await SharedPreferences.getInstance();
      //  prefs.setInt('assignedToUserId', assignedToUserId);
        // Call _assignUserOnInit with the fetched userId
        _assignUserOnInit(assignedToUserId);
      }
      setState(() {
        activeusers = fetchedUsers;
      });
    } else {
      //throw Exception('Failed to load users');
      print('Response Body: ${response.body}');
    }
  }
  void _assignUserOnInit(int assignedToUserId,) async {
    print("_assignUserOnInit");
    print(assignedToUserId);
    final sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final recipientPhoneNumber = widget.userPhoneNumber;
    print(recipientPhoneNumber);
    final uId = sharedPreferences.getInt("userId");
    print("Assigned id");
    print(uId);
    var userid = sharedPreferences.getInt("userId");
    final useridd = userid?.toInt();
    print("the useridd is:$useridd");

    //  final assignedToUserId = user.userId;
    // print("badal id is: $uId");
    // final uidd =sharedPreferences.getDouble("assignedToUserId");
    // print("The Uidd is a$uidd");
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = {
      "mobileNo": recipientPhoneNumber,
      "messagetype": "assigned",
      "fromId": uId, // Use the fetched userId
      "assignedto": assignedToUserId, // Use the fetched userId
    };

    final response = await http.post(
      Uri.parse('https://customerdigitalconnect.com/chat-activity/assigned'),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      print('User assigned successfully');
      print(body);
    } else {
      print('Failed to assign user. Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  //// here is the function of send template

  Future<void> sendTemplateToWhatsApp(Map<String, dynamic> selectedTemplate) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';
    final uId = sharedPreferences.getInt("userId");
    String recipientPhoneNumber = widget.userPhoneNumber;
    String recipientfullname = widget.userFullName;

    // Initialize the messageEntry object with common parameters
    var messageEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "template",
      "fromId": uId,
      "assignedto": 1,
      "fullname": recipientfullname,
      "templateName": selectedTemplate['templateName'],
      "time": DateTime.now().toString(),
      "localMessageType": "template"
    };

    // Check if templateBody should be included
    if (selectedTemplate['body'] != null && selectedTemplate['body']['body'] != null) {
      messageEntry["templateBody"] = {
        "body": selectedTemplate['body']['body'],
        "bodyattribute": selectedTemplate['body']['bodyattribute'],
      };
    }

    // Check if templateHeader should be included
    if (selectedTemplate['header'] != null && selectedTemplate['header']['header'] != null) {
      messageEntry["templateHeader"] = {
        "header": selectedTemplate['header']['header'],
        "headerFileType": selectedTemplate['header']['headerFileType'],
        "link": selectedTemplate['header']['file'],
      };
    }

    try {
      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll(headers);

      // Encode the messageEntry object as a JSON string and set it as a field
      request.fields['messageEntry'] = json.encode(messageEntry);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Template message sent successfully.');

        final sentTemplateMessage = {
          'type': 'Sender', // Or 'Receiver' depending on sender/receiver
          'messagetype': 'template',
          'message': selectedTemplate['templateName'],
          'time': DateTime.now().toString(),
        };

        // setState(() {
        //   chatHistory.add(sentTemplateMessage);
        // });
        fetchChatHistory();
        // Perform any necessary UI updates here
      } else {
        print('Failed to send template message. Status code: ${response.statusCode}, Response: $responseBody');
        // Handle the error scenario here
      }
    } catch (e) {
      print('Error sending template message: $e');
      // Handle the error scenario here
    }
  }

  Future<void> openTemplatePopup(BuildContext context) async {
    // Fetch template list from API
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token"); // Retrieve the token

    final response = await http.get(
      Uri.parse('https://customerdigitalconnect.com/meta-templates'),
      headers: {
        'Authorization': 'Bearer $token', // Include the token in the headers
      },
    );

    if (response.statusCode == 200) {
      final templateData = json.decode(response.body)['data'] as List<dynamic>;
      List<Map<String, dynamic>> templates = List<Map<String, dynamic>>.from(templateData);

      if (templates.isEmpty) {
        // Handle the case where templates are empty
        return;
      }
      print('Before opening modal: templates = $templates');
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              print('Inside modal: templates = $templates');
              // if (templates == null) {
              //   // Return a loading indicator while data is being fetched
              //   return Center(child: CircularProgressIndicator());
              // }
              if (templates == null || templates.isEmpty) {
                // Return a loading indicator or message when data is null or empty
                return Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 300,
                            child: ListView.builder(
                              itemCount: templates.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> template = templates[index];
                                bool isSelected = selectedTemplates.contains(template['templateName']);

                                return ListTile(
                                  title: Text(template['templateName']),
                                  tileColor: template['templateName'] == selectedTemplateName
                                      ? Colors.grey
                                      : Colors.white,
                                  onTap: () {
                                    setState(() {
                                      selectedTemplateName = template['templateName'];
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Container(
                            color: Colors.lightBlueAccent,
                            padding: EdgeInsets.all(10),
                            child: selectedTemplateName.isNotEmpty
                                ? ExpansionTile(
                              title: Text(
                                "Selected Template: $selectedTemplateName",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black,
                                ),
                              ),
                              children: [
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ...templates
                                          .where((template) => template['templateName'] == selectedTemplateName)
                                          .map((selectedTemplate) {
                                        List<Widget> templateInfoWidgets = [];

                                        if (selectedTemplate['templatePreview'] != null) {
                                          templateInfoWidgets.add(
                                            Text(
                                              "Template Preview: ${selectedTemplate['templatePreview']}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                color: Colors.black,

                                              ),
                                              maxLines: null, // Allow unlimited lines
                                              overflow: TextOverflow.clip,
                                            ),
                                          );
                                        }

                                        if (selectedTemplate['button1'] != null) {
                                          templateInfoWidgets.add(
                                            Container(
                                              padding: EdgeInsets.symmetric(vertical: 8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Colors.white,
                                                // Set the desired background color
                                              ),
                                              child: Text(
                                                "Option 1: ${selectedTemplate['button1']}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                  color: Colors.black, // Set the desired color
                                                ),
                                                // maxLines: selectedTemplate['templatePreview'].split('\n').length,
                                                maxLines: null,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          );
                                        }
                                        // SizedBox(height: 10,);
                                        if (selectedTemplate['button2'] != null) {
                                          templateInfoWidgets.add(
                                            Container(
                                              padding: EdgeInsets.symmetric(vertical: 8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Colors.white,
                                                // Set the desired background color
                                              ),
                                              child: Text(
                                                "Option 2: ${selectedTemplate['button2']}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                  color: Colors.black, // Set the desired color
                                                ),
                                                // maxLines: selectedTemplate['templatePreview'].split('\n').length,
                                                maxLines: null,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          );
                                        }
                                        // SizedBox(height: 10,);
                                        if (selectedTemplate['button3'] != null) {
                                          templateInfoWidgets.add(

                                            Container(
                                              padding: EdgeInsets.symmetric(vertical: 8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Colors.white,
                                                // Set the desired background color
                                              ),
                                              child: Text(
                                                "Option 3: ${selectedTemplate['button3']}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                  color: Colors.black, // Set the desired color
                                                ),
                                                // maxLines: selectedTemplate['templatePreview'].split('\n').length,
                                                maxLines: null,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          );
                                        }

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: templateInfoWidgets,
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),

                              ],
                            )
                                : Text(
                              "No template selected",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        print("Selected Templates: $selectedTemplateName");
                        // await sendTemplateToWhatsApp(selectedTemplates);
                        //  await sendTemplateToWhatsApp(selectedTemplate);
                        if (selectedTemplateName.isNotEmpty) {
                          Map<String, dynamic> selectedTemplate = templates.firstWhere(
                                (template) => template['templateName'] == selectedTemplateName,
                          );
                          await sendTemplateToWhatsApp(selectedTemplate);
                        } else {
                          // Handle the case when no template is selected
                        }
                        Navigator.pop(context);
                      },
                      child: Text("Send"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );


    }
  }
  //// here is the function of send catalog
  Future<void> sendCatlogdrinksMessage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';
    final uId = sharedPreferences.getInt("userId");
    String recipientPhoneNumber = widget.userPhoneNumber; // Replace with the actual recipient phone number
    String recipientFullName = widget.userFullName;  // Replace with the actual recipient full name
    String interactiveName = 'drinks'; // Replace with the actual interactive name

    final templateEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "interactive",
      "fromId": uId,
      "assignedto": 1,
      "fullname": recipientFullName,
      "interactiveName": interactiveName,
      'messagetype': 'interactive',
      'time': DateTime.now().toString(),
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['messageEntry'] = json.encode(templateEntry);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('catlog template message sent successfully.');
       // 'messagetype': 'interactive',
       //  'time': DateTime.now().toString(),
        final sentTemplateMessage = {
          'type': 'Sender', // Or 'Receiver' depending on sender/receiver
          'messagetype': 'interactive',
          'message': interactiveName,
          'time': DateTime.now().toString(),
        };

        setState(() {
          chatHistory.add(sentTemplateMessage);
        });
        fetchChatHistory();
        // Perform any necessary UI updates here
      } else {
        print('Failed to send template message. Status code: ${response.statusCode}, Response: $responseBody');
        // Handle the error scenario here
      }
    } catch (e) {
      print('Error sending template message: $e');
      // Handle the error scenario here
    }
  }
  Future<void> CatlogFoodsandBaveragesMessage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';
    final uId = sharedPreferences.getInt("userId");
    String recipientPhoneNumber = widget.userPhoneNumber; // Replace with the actual recipient phone number
    String recipientFullName = widget.userFullName; // Replace with the actual recipient full name
    String interactiveName = 'foodAndBeverages'; // Replace with the actual interactive name

    final templateEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "interactive",
      "fromId": uId,
      "assignedto": 1,
      "fullname": recipientFullName,
      "interactiveName": interactiveName,
       'messagetype': 'interactive',
       'time': DateTime.now().toString(),
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['messageEntry'] = json.encode(templateEntry);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('catlog template message sent successfully.');
        // 'messagetype': 'interactive',
        //  'time': DateTime.now().toString(),
        final sentTemplateMessage = {
          'type': 'Sender', // Or 'Receiver' depending on sender/receiver
          'messagetype': 'interactive',
          'message': interactiveName,
          'time': DateTime.now().toString(),
        };

        setState(() {
          chatHistory.add(sentTemplateMessage);
        });
      //  fetchChatHistory();
        // Perform any necessary UI updates here
      } else {
        print('Failed to send template message. Status code: ${response.statusCode}, Response: $responseBody');
        // Handle the error scenario here
      }
    } catch (e) {
      print('Error sending template message: $e');
      // Handle the error scenario here
    }
  }
  Future<void> CatlogAllProductssMessage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';
    final uId = sharedPreferences.getInt("userId");
    String recipientPhoneNumber = widget.userPhoneNumber; // Replace with the actual recipient phone number
    String recipientFullName = widget.userFullName; // Replace with the actual recipient full name
    String interactiveName = 'allProducts'; // Replace with the actual interactive name

    final templateEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "interactive",
      "fromId": uId,
      "assignedto": 1,
      "fullname": recipientFullName,
      "interactiveName": interactiveName,
       'messagetype': 'interactive',
        'time': DateTime.now().toString(),
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['messageEntry'] = json.encode(templateEntry);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('catlog template message sent successfully.');
        // 'messagetype': 'interactive',
        //  'time': DateTime.now().toString(),
        final sentTemplateMessage = {
          'type': 'Sender', // Or 'Receiver' depending on sender/receiver
          'messagetype': 'interactive',
          'message': interactiveName,
          'time': DateTime.now().toString(),
        };

        setState(() {
          chatHistory.add(sentTemplateMessage);
        });
       // fetchChatHistory();
        // Perform any necessary UI updates here
      } else {
        print('Failed to send template message. Status code: ${response.statusCode}, Response: $responseBody');
        // Handle the error scenario here
      }
    } catch (e) {
      print('Error sending template message: $e');
      // Handle the error scenario here
    }
  }
  Future<void> CatlogSpasMessage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';
    final uId = sharedPreferences.getInt("userId");
    String recipientPhoneNumber = widget.userPhoneNumber; // Replace with the actual recipient phone number
    String recipientFullName = widget.userFullName; // Replace with the actual recipient full name
    String interactiveName = 'spa'; // Replace with the actual interactive name

    final templateEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "interactive",
      "fromId": uId,
      "assignedto": 1,
      "fullname": recipientFullName,
      "interactiveName": interactiveName,
       'messagetype': 'interactive',
      'time': DateTime.now().toString(),
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['messageEntry'] = json.encode(templateEntry);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('catlog template message sent successfully.');
        // 'messagetype': 'interactive',
        //  'time': DateTime.now().toString(),
        final sentTemplateMessage = {
          'type': 'Sender', // Or 'Receiver' depending on sender/receiver
          'messagetype': 'interactive',
          'message': interactiveName,
          'time': DateTime.now().toString(),
        };

        setState(() {
          chatHistory.add(sentTemplateMessage);
        });
        // Perform any necessary UI updates here
      } else {
        print('Failed to send template message. Status code: ${response.statusCode}, Response: $responseBody');
        // Handle the error scenario here
      }
    } catch (e) {
      print('Error sending template message: $e');
      // Handle the error scenario here
    }
  }

  /// for displaying quickreplies list
  Future<void> fetchQuickReplies() async {
    print("fetchQuickReplies");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    //  final token = 'your_token_here'; // Replace with your actual token
    final headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(
      Uri.parse('https://customerdigitalconnect.com/quickreplies'),
      headers: headers, // Pass the headers here
    );


    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final data = jsonData['data'] as List<dynamic>;
      print("QuickReplyList");
      print("The replies list is:$data");

      setState(() {
        quickReplies = data.map((item) => QuickReply.fromJson(item)).toList();
      });
    } else {
      // Handle error
      print('Failed to fetch quick replies');
    }
  }
  Future<void> _showQuickRepliesDialog() async {
    print("QuickReplies List");
    // Fetch quick replies before showing the dialog
   await fetchQuickReplies();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quick Replies'),
          content: Container(
            width: double.maxFinite, // Adjust the width as needed
            child: ListView.builder(
              itemCount: quickReplies.length,
              itemBuilder: (context, index) {
                final quiclreplieslist = quickReplies[index];
                print("The print list is:$quiclreplieslist");
                return Column(
                  children: [
                    ListTile(
                      title: Text(quiclreplieslist.name,style: TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: Text(quiclreplieslist.description,style: TextStyle(fontWeight: FontWeight.normal),),
                      onTap: () {
                        // Handle the quick reply selection here
                        // You can close the dialog and perform any action
                        messageController.text = '${quiclreplieslist.name}: ${quiclreplieslist.description}';
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
  Future<void> fetchActivelabels() async {
    print("fetchActivelabels");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    //  final token = 'your_token_here'; // Replace with your actual token
    final headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(
      Uri.parse('https://customerdigitalconnect.com/label/active'),
      headers: headers, // Pass the headers here
    );


    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final data = jsonData['data'] as List<dynamic>;
      print("ActiveLabelsList");
      print("The LabelsList is:$data");


      setState(() {
        activelabels = data.map((item) =>Activelabel.fromJson(item)).toList();
      });
    } else {
      // Handle error
      print('Failed to fetch quick replies');
    }
  }
  Future<void> _showlabeltagDialog() async {
    print("labelTag List");
    // Fetch quick replies before showing the dialog
    await fetchActivelabels();
    List<String> selectedLabels = [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Label Tags'),
          content: Container(
            width: 300,
            height: 300,// Adjust the width as needed
            child: ListView.builder(
              itemCount: activelabels.length,
              itemBuilder: (context, index) {
                final labeltaglist = activelabels[index];
             //   print("The print list is:$quiclreplieslist");
                return Column(
                  children: [
                    ListTile(
                      title: Text(labeltaglist.id.toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: Text(labeltaglist.name,style: TextStyle(fontWeight: FontWeight.normal),),
                      onTap: () {
                        // Handle the quick reply selection here
                        handleLabelTap(labeltaglist.id);
                        // You can close the dialog and perform any action
                     //   messageController.text = '${labeltaglist.name}: ${labeltaglist.description}';
                      //  Navigator.pop(context);
                      //   setState(() {
                      //     if (selectedLabels.contains(labeltaglist.id.toString())) {
                      //       selectedLabels.remove(labeltaglist.id.toString());
                      //     } else {
                      //       selectedLabels.add(labeltaglist.id.toString());
                      //     }
                      //   });
                      },
                    ),

                  ],

                );
              },
            ),
          ),

          actions: [
            Row(
              children: [
                // TextButton(
                //   onPressed: () {
                //     // Close the dialog
                //   //  addLabel(selectedLabels);
                //   //  addLabel(labelId);
                //     Navigator.pop(context);
                //   },
                //   child: Text('Add Tag'),
                // ),
                TextButton(
                  onPressed: () {
                    // Close the dialog
                   // removelabel();
                    removeLabel(selectedLabels);
                    Navigator.pop(context);
                  },
                  child: Text('Remove Tag'),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> removeLabel(List<String> selectedLabels) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    String recipientPhoneNumber = widget.userPhoneNumber;
    final mobileNo = recipientPhoneNumber;

    final apiUrl = 'https://customerdigitalconnect.com/customer/label-remove/$mobileNo';

    try {
      var response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'labels': selectedLabels}), // Send the selected label IDs as JSON data.
      );

      if (response.statusCode == 200) {
        print('Labels removed successfully.');
        // Perform any other actions or UI updates as needed after removing the labels.
      } else {
        print('Failed to remove labels. Status code: ${response.statusCode}, Response: ${response.body}');
      }
    } catch (e) {
      print('Error removing labels: $e');
    }
  }

  Future<void> addLabel(int labelId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    String recipientPhoneNumber = widget.userPhoneNumber;
    final mobileNo = recipientPhoneNumber;

    // Create the API endpoint URL with the label ID
    final apiUrl = 'https://customerdigitalconnect.com/customer/label-update/$mobileNo/$labelId';

    try {
      var response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Label added successfully.');
        Navigator.push(context, MaterialPageRoute(builder: (context) => chatLisitingTab()));
        // Perform any other actions or UI updates as needed after adding the label.
      } else {
        print('Failed to add label. Status code: ${response.statusCode}, Response: ${response.body}');
        final jsonResponse = response.body != null ? jsonDecode(response.body) : null;
        print("Error jsonResponse: ${jsonResponse.toString()}");
      }
    } catch (e) {
      print('Error adding label: $e');
    }
  }
  void handleLabelTap(int labelId) {
    addLabel(labelId);
    Navigator.pop(context); // Close the label dialog
  }

  //// Send Notes
  Future<void> sendnotesToWhatsApp(String messageContent) async {

    print("Notes sending message to user");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';
    final uId = sharedPreferences.getInt("userId");
    print("badal id is: $uId");

    // Replace these values with your actual data
    String recipientPhoneNumber = widget.userPhoneNumber;
    String recipientfullName = widget.userFullName;
    print(recipientPhoneNumber);

    final messageEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "notes",
      "fromId": uId,
      "assignedto": 1,
      "fullname": recipientfullName,
      "text": {
        "preview_url": false,
        "body": messageContent,
      }
    };
    print("All fields"+messageEntry.toString());

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';

      // Convert the messageEntry map to JSON and set it as a form field
      request.fields['messageEntry'] = json.encode(messageEntry);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print(responseBody);
      if (response.statusCode == 200) {
        print('Message sent successfully.');

        setState(() {
          sentMessagetoUser.add(messageContent);

          // Add the message to chatHistory with 'Sender' type
          chatHistory.add({
            'type': 'Sender',
            'messagetype': 'text',
            'message': messageContent,
            'time': DateTime.now().toString(),
            // Add other properties if needed
          });
        });
      }
      else {
        print('Failed to send message. Status code: ${response
            .statusCode}, Response: $responseBody');
        final jsonResponse2 = responseBody != null ? jsonDecode(responseBody) : null;
        // final jsonResponse2 = jsonDecode(response.body);
        print("==error jsonResponse is that:" + jsonResponse2.toString());
        //  EasyLoading.showError(jsonResponse2!=null ? jsonResponse2['massage']:'unknown error');
      //  EasyLoading.showError(jsonResponse2 != null ? jsonResponse2['message'] ?? 'unknown error' : 'unknown error');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }


}
