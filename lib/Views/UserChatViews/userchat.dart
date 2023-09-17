import 'dart:async';
import 'dart:ffi';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamcdcapp/Model/ActiveUsers.dart';
import 'package:teamcdcapp/Model/quickrepliesList.dart';
import 'package:teamcdcapp/Views/Dashboard/MainBottomNavigationViews/ChatlistingTabs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';

//import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:geolocator/geolocator.dart';


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

class UserChatScreenView extends StatefulWidget {
  final String userPhoneNumber;
  final String userFullName;


  UserChatScreenView({required this.userPhoneNumber,required this.userFullName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<UserChatScreenView> {
//  GlobalKey<_ChatScreenState> loadingKey = GlobalKey<_ChatScreenState>();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController sendNotesController = TextEditingController();
  List<Map<String, dynamic>> chatHistory = [];
  List<String> sentMessagetoUser = [];
  List<User> activeusers = [];
  ScrollController _scrollController = ScrollController();  ///   for displaying last message in chat screen

  List<String> selectedTemplates = [];
  String selectedTemplateName = "";

  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://65.1.109.24:8080/chat'), // Replace with your WebSocket server URL
  );
  final StreamController<String> _messagesStreamController = StreamController();
  final StreamController<String> _incomingMessagesStreamController = StreamController();
 // bool isEmojiPickerVisible = false;
  List<QuickReply> quickReplies = [];
  List<CatalogOrderItem> catalogOrderItems = [];


  ///// Hex colour code
  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }



  @override
  void initState() {
    super.initState();
    _channel.stream.listen(_handleIncomingMessages);
    fetchChatHistory();
    getAlluser();
    fetchQuickReplies();
    Map<String, dynamic> orderResponse = {
      // Your order response data here
    };

    _processOrderResponse(orderResponse);

  }

  //////   for display popupwindow

  void _openFileAttachmentPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select File"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Display options for different file types here
                ElevatedButton(
                  onPressed: () async {
                    // Handle image attachment
                    Navigator.pop(context);
                    //_handleImageAttachment();
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);


                   if (result != null) {
                 String filePath = result.files.single.path!;
                 String recipientPhoneNumber = widget.userPhoneNumber;

                  // await sendDocumentToWhatsApp(filePath, recipientPhoneNumber);
                    await sendImageToWhatsApp(filePath, recipientPhoneNumber);
                   } else {
                    // User canceled the file picking
                    }
                  },

                  child: Text("Attach Image"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Handle document attachment
                    Navigator.pop(context);
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);


                    if (result != null) {
                      String filePath = result.files.single.path!;
                      String recipientPhoneNumber = widget.userPhoneNumber;

                      // await sendDocumentToWhatsApp(filePath, recipientPhoneNumber);
                      await sendDocumentToWhatsApp(filePath, recipientPhoneNumber);
                    } else {
                      // User canceled the file picking
                    }
                   },

                  child: Text("Attach Document"),
                ),
                ElevatedButton(
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

                  child: Text("Audio"),
                ),
                ElevatedButton(
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

                  child: Text("Video"),
                ),
                /*ElevatedButton(
                  onPressed: () async {
                    // Handle document attachment
                    Navigator.pop(context);
                    String recipientPhoneNumber = widget.userPhoneNumber;
                    sendLocationToWhatsApp(recipientPhoneNumber);
                   },

                  child: Text("location"),
                ),*/
                // Add more options for audio, video, etc.
              ],
            ),
          ),
        );
      },
    );
  }

  // void _processOrderResponse(Map<String, dynamic> orderResponse) {
  //   if (orderResponse.containsKey('catalogOrderItems')) {
  //     final List<dynamic> itemsData = orderResponse['catalogOrderItems'];
  //
  //     catalogOrderItems = itemsData.map((item) {
  //       return CatalogOrderItem(
  //         productRetailerId: item['product_retailer_id'],
  //         quantity: int.parse(item['quantity']),
  //         itemPrice: double.parse(item['item_price']),
  //         currency: item['currency'],
  //       );
  //     }).toList();
  //
  //     // Calculate total price for each item and overall total price
  //     double overallTotalPrice = 0;
  //     for (final item in catalogOrderItems) {
  //       item.totalPrice = item.quantity * item.itemPrice;
  //       overallTotalPrice += item.totalPrice;
  //     }
  //
  //     // Print overall total price for verification
  //     print('Overall Total Price: $overallTotalPrice');
  //   }
  // }

  void _processOrderResponse(Map<String, dynamic> orderResponse) {
    print("_processOrderResponse");
    if (orderResponse.containsKey('catalogOrderItems')) {
      final List<dynamic> itemsData = orderResponse['catalogOrderItems'];

      catalogOrderItems = itemsData.map((item) {
        final CatalogOrderItem catalogItem = CatalogOrderItem(
          productRetailerId: item['product_retailer_id'],
          quantity: int.parse(item['quantity']),
          itemPrice: double.parse(item['item_price']),
          currency: item['currency'],
          totalPrice: 0, // Initialize totalPrice
        );

        catalogItem.totalPrice = catalogItem.quantity * catalogItem.itemPrice;
        return catalogItem;
      }).toList();

      // Calculate overall total price
      double overallTotalPrice = catalogOrderItems.fold(
          0, (total, item) => total + item.totalPrice);

      // Print overall total price for verification
      print('Overall Total Price: $overallTotalPrice');
    }
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
                        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);


                        if (result != null) {
                          String filePath = result.files.single.path!;
                          String recipientPhoneNumber = widget.userPhoneNumber;

                          // await sendDocumentToWhatsApp(filePath, recipientPhoneNumber);
                          await sendImageToWhatsApp(filePath, recipientPhoneNumber);
                        } else {
                          // User canceled the file picking
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

                          // await sendDocumentToWhatsApp(filePath, recipientPhoneNumber);
                          await sendDocumentToWhatsApp(filePath, recipientPhoneNumber);
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
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Handle image attachment
                        Navigator.pop(context);
                       SendNotesDialog();
                      },
                      child: Icon(
                        Icons.note_alt_outlined,
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
              Row(
               // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Spa'),
                  ),
                  SizedBox(width: 45,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Notes'),
                  ),

                  // SizedBox(width: 10,),
                ],
              ),
            ],
          );
        });
  }

  void _showQuickRepliesDialog() {
    print("Quick Replies List");
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
                  final quickReply = quickReplies[index];
                  return ListTile(
                    title: Text(quickReply.name,style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Text(quickReply.description,style: TextStyle(fontWeight: FontWeight.normal),),
                    onTap: () {
                      // Handle the quick reply selection here
                      // You can close the dialog and perform any action
                      messageController.text = '${quickReply.name}: ${quickReply.description}';
                      Navigator.pop(context);
                    },
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

  void _handleIncomingMessages(dynamic data) {
    print("Received Data: $data");
    if (data != null) {
      final jsonData = json.decode(data as String);
      final String messageType = jsonData['messagetype'] ?? '';
      final String messageContent = jsonData['message'] ?? '';
      final String senderName = jsonData['name'] ?? '';

      if (messageType == 'text' && messageContent.isNotEmpty) {
        setState(() {
          chatHistory.add({
            'type': 'Receiver',
            'messagetype': messageType,
            'message': messageContent,
            'name': senderName,
            'time': jsonData['time'], // Make sure this is provided in your JSON data
          });
        });
      }
      else if (messageType == 'image' && messageContent.isNotEmpty) {
        setState(() {
          chatHistory.add({
            'type': 'Receiver',
            'messagetype': messageType,
            'message': jsonData['fileUrl'], // Store the image URL
            'name': senderName,
            'time': jsonData['time'],
          });
        });
      }
      else if (messageType == 'document' && messageContent.isNotEmpty) {
        setState(() {
          chatHistory.add({
            'type': 'Receiver',
            'messagetype': messageType,
            'message': jsonData['fileUrl'], // Store the document URL
            'name': senderName,
            'time': jsonData['time'],
          });
        });
      }
    }
  }
  // void _showDropdownPopup(BuildContext context) {
  //   User? selectedUser;
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //
  //         title: Text('Assigned To'),
  //         content: DropdownButtonFormField<User>(
  //
  //           value: activeusers.isNotEmpty ? activeusers[0] : null,
  //           decoration: InputDecoration(
  //               border: OutlineInputBorder(),
  //               labelText: 'Select User',
  //               hintText: 'Select User'),
  //           validator: (value) =>
  //           value == null ? 'Please enter a user' : null,
  //           onChanged: (User? newValue) {
  //             setState(() {
  //               selectedUser = newValue;
  //               print(selectedUser);// Update selected user
  //              // _assignUserOnInit(selectedUser!);
  //               // Pass the selectedUser object
  //
  //               if (selectedUser != null) {
  //                 _assignUserOnInit(selectedUser.userId);
  //               }
  //
  //               Navigator.of(context).pop();
  //             });
  //             // Handle dropdown value change
  //           },
  //           items: activeusers.map((User user) {
  //             return DropdownMenuItem<User>(
  //               value: user,
  //               child: Text('${user.firstName} ${user.lastName}'),
  //             );
  //           }).toList(),
  //         ),
  //       );
  //     },
  //   );
  // }
  void _showDropdownPopup(BuildContext context) {
    User? selectedUser;

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
                print(selectedUser); // Update selected user

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


  @override
  Widget build(BuildContext context) {

    return Scaffold(
     backgroundColor:_colorFromHex("#ece5dd"),
      appBar: AppBar(
        title: Text('${widget.userFullName}'),
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
        children: [
          Expanded(
            child: ListView.builder(
            //  key: Key(counter.toString()),
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final chatMessage = chatHistory[index];
                if(index==chatHistory.length-1){
                  print("chatMessage");
                  print(chatMessage);
                }
                final isSender = chatMessage['type'] == 'Sender';
                final alignment = isSender ? MainAxisAlignment.end : MainAxisAlignment.start;
              //  final alignment = isSender ? Alignment.centerRight : Alignment.centerLeft;
                final bgColor = isSender ? _colorFromHex("#dcf8c6"): Colors.white;
                final textColor = isSender ? Colors.black : Colors.black;

                final apiDateFormat = DateFormat("yyyy-MM-ddTHH:mm");
                final apiDateFormatnew = DateFormat("yyyy-MM-dd HH:mm:ss");

                final today = DateTime.now();
                var messageDate;
                try {
                  messageDate = apiDateFormat.parse(chatMessage['time'] ?? '');
                } on Exception catch (e) {
                  messageDate = apiDateFormatnew.parse(chatMessage['time'] ?? '');
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
                    dateDisplay = "Last week (${dayFormat.format(messageDate)}), ${dateFormatter.format(messageDate)}";
                  } else if (messageDate.isAfter(oneMonthAgo)) {
                    final dateFormatter = DateFormat('dd-MM-yyyy');
                    dateDisplay = "Last month (${dayFormat.format(messageDate)}), ${dateFormatter.format(messageDate)}";
                   // dateDisplay = "Last month";
                  } else {
                    dateDisplay = previousDayName;
                  }
                }


                if (chatMessage['mobileNo'] != widget.userPhoneNumber) {
                  return Container(); // Skip messages from other users
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

                // Display order details


                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: alignment,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,

                          children: [

                            if (chatMessage['messagetype'] == 'text') // Regular text message
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  chatMessage['message'] ?? '',
                                  maxLines: null,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                            if (chatMessage['messagetype'] == 'image' && chatMessage['fileUrl'] != null)
                            // Image message
                              Image.network(
                                chatMessage['fileUrl'],
                                width: 200, // Adjust the width as needed
                              ),

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
                                      color: textColor,
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
                                    style: TextStyle(color: textColor),
                                    softWrap: true, // Allow text to wrap to the next line
                                  ),
                                ),
                              ),


                            if (chatMessage['messagetype'] == 'order')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Catalog ID: ${chatMessage['catalogId']}'),
                                  SizedBox(height: 10),

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
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
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
              if (snapshot.hasData) {
                final incomingMessage = snapshot.data!;
                final messageParts = incomingMessage.split(':'); // Split message by colons

                if (messageParts.length >= 3) {
                  final senderName = messageParts[0].trim();
                  final messageType = messageParts[1].trim();
                  final messageContent = messageParts[2].trim();

                  if (messageType == 'text' && messageContent.isNotEmpty && senderName == widget.userPhoneNumber) {
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.grey[200],
             // padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.insert_emoticon),
                    onPressed: () {
                    //  openEmojiPicker();

                    },
                  ),
                  Expanded(
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
                  ),
                  /*if (isEmojiPickerVisible)
                    EmojiPicker(
                      rows: 3,
                      columns: 7,
                      onEmojiSelected: (emoji, category) {
                        messageController.text += emoji.emoji;
                      },
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

                  IconButton(
                    icon: Icon(Icons.sticky_note_2_outlined), // Replace with your sticker icon
                    onPressed: () async {
                      // Replace 'filePath' with the actual path of the sticker image
                      String filePath = 'path_to_sticker_image.png';
                      String recipientPhoneNumber = widget.userPhoneNumber;

                      await sendStickerToWhatsApp(filePath, recipientPhoneNumber);
                    },
                  ),
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

        ],
      ),
    );
  }


  //////  here Api calling functions and handling.

  void scrollToBottom() {
    /*_scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );*/
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }


  // void _handleSendMessage() async {
  //   final messageContent = messageController.text;
  //   if (messageContent.isNotEmpty) {
  //     final outgoingMessage = {
  //       'type': 'Sender',
  //       'messagetype': 'text',
  //       'message': messageContent,
  //       'time': DateTime.now().toString(),
  //     };
  //
  //     setState(() {
  //       chatHistory.add(outgoingMessage);
  //     });
  //     //  addMessage(outgoingMessage);
  //
  //     bool messageSent = false;
  //     // bool messageSent = false;
  //
  //     try {
  //       // Send the message to WhatsApp
  //       await sendMessageToWhatsApp(messageContent);
  //       messageSent = true;
  //     } catch (e) {
  //       print('Error sending message to WhatsApp: $e');
  //     }
  //
  //     // Delay the removal of the temporary outgoing message to avoid flickering
  //     if (messageSent) {
  //       Future.delayed(Duration(milliseconds: 100), () {
  //         setState(() {
  //           chatHistory.remove(outgoingMessage);
  //         });
  //         //  scrollToBottom();
  //       });
  //
  //     } else {
  //       EasyLoading.show(status: "Something went wrong");
  //     }
  //
  //     messageController.clear();
  //     // scrollToBottom();
  //   }
  // }

  void _handleSendMessage() async {
    final messageContent = messageController.text;
    if (messageContent.isNotEmpty) {
      final outgoingMessage = {
        'type': 'Sender',
        'messagetype': 'text',
        'message': messageContent,
        'time': DateTime.now().toString(),
      };

      setState(() {
        chatHistory.add(outgoingMessage);
      });

      bool messageSent = false;

      try {
        // Send the message to WhatsApp
        await sendMessageToWhatsApp(messageContent);
        messageSent = true;
      } catch (e) {
        print('Error sending message to WhatsApp: $e');
      }

      // Delay the removal of the temporary outgoing message to avoid flickering
      if (messageSent) {
        Future.delayed(Duration(milliseconds: 100), () {
          setState(() {
            chatHistory.remove(outgoingMessage);
          });
          //  scrollToBottom();
        });

      } else {
        // Handle the case when the message couldn't be sent
        // Update message status or style as needed
        // For example: outgoingMessage['status'] = 'error';
      }

      messageController.clear();
      // scrollToBottom();
    }
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
    String recipientPuserName = widget.userFullName;
    print(recipientPhoneNumber);

    final messageEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "text",
      "fromId": uId,
      "assignedto": 1,
      "fullname": recipientPuserName,
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


  // Future<void> sendMessageToWhatsApp(String messageContent) async {
  //
  //   print("sending message to user");
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   var newToken = sharedPreferences.getString("token");
  //   final token = newToken.toString();
  //   final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';
  //   final uId = sharedPreferences.getInt("userId");
  //   print("badal id is: $uId");
  //
  //   // Replace these values with your actual data
  //   String recipientPhoneNumber = widget.userPhoneNumber;
  //   String recipientfullName = widget.userFullName;
  //   print(recipientPhoneNumber);
  //
  //   final messageEntry = {
  //     "messaging_product": "whatsapp",
  //     "recipient_type": "individual",
  //     "to": recipientPhoneNumber,
  //     "type": "text",
  //     "fromId": uId,
  //     "assignedto": 1,
  //     "fullname": recipientfullName,
  //     "text": {
  //       "preview_url": false,
  //       "body": messageContent,
  //     }
  //   };
  //   print("All fields"+messageEntry.toString());
  //
  //   try {
  //     var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
  //     request.headers['Authorization'] = 'Bearer $token';
  //
  //     // Convert the messageEntry map to JSON and set it as a form field
  //     request.fields['messageEntry'] = json.encode(messageEntry);
  //
  //     var response = await request.send();
  //     var responseBody = await response.stream.bytesToString();
  //     print(responseBody);
  //     if (response.statusCode == 200) {
  //       print('Message sent successfully.');
  //       /*setState(() {
  //         sentMessagetoUser.add(messageContent);
  //       });*/
  //       setState(() {
  //         sentMessagetoUser.add(messageContent);
  //
  //         // Add the message to chatHistory with 'Sender' type
  //         chatHistory.add({
  //           'type': 'Sender',
  //           'messagetype': 'text',
  //           'message': messageContent,
  //           'time': DateTime.now().toString(),
  //           // Add other properties if needed
  //         });
  //       });
  //     }
  //     else {
  //       print('Failed to send message. Status code: ${response
  //           .statusCode}, Response: $responseBody');
  //       final jsonResponse2 = responseBody != null ? jsonDecode(responseBody) : null;
  //       // final jsonResponse2 = jsonDecode(response.body);
  //       print("==error jsonResponse is that:" + jsonResponse2.toString());
  //       //  EasyLoading.showError(jsonResponse2!=null ? jsonResponse2['massage']:'unknown error');
  //       EasyLoading.showError(jsonResponse2 != null ? jsonResponse2['message'] ?? 'unknown error' : 'unknown error');
  //     }
  //   } catch (e) {
  //     print('Error sending message: $e');
  //   }
  // }

  void addMessage(Map<String, dynamic> message) {
    setState(() {
      chatHistory.add(message);
    });
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
        //   chatHistory.clear(); // Clear existing chat history before adding new data
        //   for (final messageData in chatHistoryData) {
        //     final messageType = messageData['messagetype'];
        //     final messageContent = messageData['message'];
        //     final formattedMessage = messageContent;
        //
        //     chatHistory.add({
        //       'type': 'Receiver', // Assuming incoming messages are always from the other party
        //       'messagetype': messageType,
        //       'message': messageContent,
        //       'time': messageData['time'], // Ensure you have the time field in the JSON response
        //     });
        //   }
        });
      } else {
        print('Failed to fetch chat history. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chat history: $e');
    }
  }

   //// function for closed chat
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
        EasyLoading.showError(jsonResponse2 != null ? jsonResponse2['message'] ?? 'unknown error' : 'unknown error');
      }
    } catch (e) {
      print('Error closing chat: $e');
    }
  }

  /////  For assign to user

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
        print("The userIddd$assignedToUserId");
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('assignedToUserId', assignedToUserId);
      ///   prefs.setInt('assignedToUserId') ?? 0;

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
    final sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final recipientPhoneNumber = widget.userPhoneNumber;
    print(recipientPhoneNumber);
    final uId = sharedPreferences.getInt("userId");
    // var userid = sharedPreferences.getInt("userId");
    // final useridd = userid?.toInt();
    // print("the useridd is:$useridd");
    final uidd =sharedPreferences.getDouble("assignedToUserId");
    print("The Uidd is a$uidd");

  //  final assignedToUserId = user.userId;
    // print("badal id is: $uId");

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = {
      "mobileNo": recipientPhoneNumber,
      "messagetype": "assigned",
      "fromId": uId, // Use the fetched userId
      "assignedto": uidd, // Use the fetched userId
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

  ////  for send document

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
      } else {
        print('Failed to send document. Status code: ${response.statusCode}, Response: $responseBody');
      }
    } catch (e) {
      print('Error sending document: $e');
    }
  }
///// for send image
  Future<void> sendImageToWhatsApp(String filePath, String recipientPhoneNumber) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';

    final uId = sharedPreferences.getInt("userId");


    final messageEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "image",
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
  /*Future<Position> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      } else if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print('Error getting location: $e');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position; // Return a default position in case of errors
    }
  }

  Future<void> sendLocationToWhatsApp(String recipientPhoneNumber) async {
    try {
      Position position = await getCurrentLocation(); // Get current location
      print('Current Location: Latitude ${position.latitude}, Longitude ${position.longitude}');

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      final newToken = sharedPreferences.getString("token");
      final token = newToken.toString();
      final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';

      final uId = sharedPreferences.getInt("userId");

      final messageEntry = {
        "messaging_product": "whatsapp",
        "recipient_type": "individual",
        "to": recipientPhoneNumber,
        "type": "location",
        "fromId": uId.toString(),
        "caption": "testing",
        "assignedto": "1",
        "fullname": "badal badal",
        "latitude": position.latitude.toString(), // Set latitude dynamically
        "longitude": position.longitude.toString(), // Set longitude dynamically
        "locationName": "LOCATIONNAME",
        "locationAddress": "Location Address"
      };

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['messageEntry'] = json.encode(messageEntry);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Location sent successfully.');
      } else {
        print('Failed to send location. Status code: ${response.statusCode}, Response: $responseBody');
      }
    } on PlatformException catch (e) { // Use PlatformException
      print('Error sending location: ${e.message}');
    } catch (e) {
      print('Error sending location: $e');
    }
  }*/

  ///// For send Stickers
  Future<void> sendStickerToWhatsApp(String filePath, String recipientPhoneNumber) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';

    final uId = sharedPreferences.getInt("userId");

    final messageEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "sticker",
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

  //// here is the function of send template

  Future<void> sendTemplateToWhatsApp(Map<String, dynamic> selectedTemplate) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';
    final uId = sharedPreferences.getInt("userId");

    String recipientPhoneNumber = widget.userPhoneNumber;
    String recipientfullname = widget.userFullName;
    print("The user full name is:$recipientfullname");


    final templateEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "template",
      "fromId": uId,
      "assignedto": 1,
      "fullname": recipientfullname,
      "templateName": selectedTemplate['templateName'], // Use the selected template name
      "templateBody": {
        "body": "body",
        "bodyattribute": [recipientfullname]
        //...selectedTemplate['body']['bodyattribute']]
       // selectedTemplate['body']['bodyattribute'], // Use the body attribute from the selected template
      },
      "templateHeader": {
        "header": selectedTemplate['header']['header'], // Use the header from the selected template
        "headerFileType": selectedTemplate['header']['headerFileType'], // Use the header file type from the selected template
        "link": selectedTemplate['header']['file'], // Use the link to the header file from the selected template
      },
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';

      // Convert the templateEntry map to JSON and set it as a form field
      request.fields['messageEntry'] = json.encode(templateEntry);
      print("templateEntry");
      print(templateEntry);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Template message sent successfully.');
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
        // You can show a message or return early
        return; // This exits the function
      }

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // if (templates == null) {
              //   // Return a loading indicator while data is being fetched
              //   return Center(child: CircularProgressIndicator());
              // }
              if (templates.isEmpty) {
                // Return a loading indicator while data is being fetched
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

  ///// For catalog sending functions

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
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['messageEntry'] = json.encode(templateEntry);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('catlog template message sent successfully.');
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
    String interactiveName = 'foodAndBaverages'; // Replace with the actual interactive name

    final templateEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "interactive",
      "fromId": uId,
      "assignedto": 1,
      "fullname": recipientFullName,
      "interactiveName": interactiveName,
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['messageEntry'] = json.encode(templateEntry);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('catlog template message sent successfully.');
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
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['messageEntry'] = json.encode(templateEntry);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('catlog template message sent successfully.');
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
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['messageEntry'] = json.encode(templateEntry);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('catlog template message sent successfully.');
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
  void fetchQuickReplies() async {
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
        });
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
        EasyLoading.showError(jsonResponse2 != null ? jsonResponse2['message'] ?? 'unknown error' : 'unknown error');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }




}
