import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamcdcapp/Views/Dashboard/MainBottomNavigationViews/ChatlistingTabs.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'MainBottomNavigationViews/OpenChatInboxScreen.dart';


class ChatMessage {
  final String type;
  final String messageType;
  final String message;
  final String time;
  final String name;
  final bool isOpen;

  ChatMessage({
    required this.type,
    required this.messageType,
    required this.message,
    required this.time,
    required this.name,
    required this.isOpen,
  });
}

class ChatScreenView extends StatefulWidget {

  final String userPhoneNumber;
 // final String userName;

  ChatScreenView({required this.userPhoneNumber});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreenView> {
  List<String> chatHistory = [];
  TextEditingController messageController = TextEditingController();
  String messageContent = '';
  List<String> sentMessagetoUser = [];


  ///// Hex colour code
  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }





  ////  for socket connection

  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://65.1.109.24:8080/chat'), // Replace with your WebSocket server URL
  );
  final StreamController<String> _messagesStreamController = StreamController();

  //   WebSocket Handling - _handleIncomingMessages:
  // Function to handle incoming WebSocket messages and add them to the StreamController
  void _handleIncomingMessages(dynamic data) {
    print("Received Data: $data");
    if (data != null) {
      final jsonData = json.decode(data as String);
      final String messageType = jsonData['messagetype'] ?? '';
      final String messageContent = jsonData['message'] ?? '';
      final String senderName = jsonData['name'] ?? '';

      if (messageType == 'text' && messageContent.isNotEmpty) {
       // final isOutgoing = senderName == 'You'; // Assuming 'You' indicates outgoing message
        final formattedMessage = '$senderName: $messageContent';
        print('Formatted Message: $formattedMessage');
        setState(() {
          chatHistory.add(formattedMessage);
        });
        _messagesStreamController.add(messageContent); // Add only the message content
      }
    }
  }

  /*void _handleIncomingMessages(dynamic data) {
   // _messagesStreamController.add(data);
    if (data != null) {
      final jsonData = json.decode(data as String);
      final String messageType = jsonData['messagetype'] ?? '';
      final String messageContent = jsonData['message'] ?? '';
      final String senderName = jsonData['name'] ?? '';

      if (messageType == 'text' && messageContent.isNotEmpty) {
        final isOutgoing = senderName == 'You'; // Assuming 'You' indicates outgoing message
        final formattedMessage = '$senderName: $messageContent\n$isOutgoing'; // Use a separator to indicate outgoing status
     //   chatHistory.add(formattedMessage);
        _messagesStreamController.add(formattedMessage);
      }
    }
  }*/

  @override
  void dispose() {
    _channel.sink.close();
    _messagesStreamController.close(); // Close the StreamController when disposing
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Listen to incoming WebSocket messages and handle them using _handleIncomingMessages
     _channel.stream.listen(_handleIncomingMessages);
    fetchChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterEasyLoading(
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.userPhoneNumber}'),
          centerTitle: true,
        actions: [IconButton(
          icon: Icon(Icons.roller_shades_closed_outlined,color: Colors.white),
          onPressed:(){
            closeChat();
            print("closed chat");
          },
        )
        ],
        //  automaticallyImplyLeading: false,
          backgroundColor: _colorFromHex("#0BADBC"),
        ),
        body: Column(
          children: [
            /*Expanded(
              child: StreamBuilder(
                stream: _messagesStreamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    // Check if the received data is a valid JSON message
                    try {
                      final jsonData = json.decode(snapshot.data!);
                      final String messageType = jsonData['messagetype'];
                      final String messageContent = jsonData['message'];
                      final String recipientPhoneNumber = jsonData['mobileNo'];
                      final String senderName = jsonData['name'];
                      // Check if the message type is "text" and the message content is not empty
                      if (messageType == 'text' && messageContent.isNotEmpty) {
                        // Check if the recipient phone number matches the particular user's phone number
                        if (recipientPhoneNumber == widget.userPhoneNumber) {
                          // Display the incoming WebSocket message using ListTile or any other widget
                          return ListTile(
                            title: Text('Received Message: $messageContent'),
                          );
                        }
                      }
                    } catch (e) {
                      // Handle JSON parsing errors, if any
                      print('Error parsing incoming message: $e');
                    }
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),*/
            //////   Latest
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: chatHistory.length,
                      itemBuilder: (context, index) {
                      //  final chatMessage = chatHistory[index];
                     //   final isOutgoing = chatMessage.startsWith('You:');
                       // final isOutgoing = chatMessage['type'] == 'Sender';
                        final chatMessage = chatHistory[index];

                        final isOutgoing = chatMessage.startsWith('You:'); // Assuming your outgoing messages start with "You:"
                        final alignment = isOutgoing ? Alignment.centerRight : Alignment.centerLeft;
                      //  final alignment = isOutgoing ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart;
                        final bgColor = isOutgoing ? Colors.blue : Colors.grey.shade300;

                        return Align(
                          alignment: alignment,
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                             // crossAxisAlignment: CrossAxisAlignment.start,
                             // mainAxisAlignment: MainAxisAlignment,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 1.0),
                                  child: Text(
                                    chatMessage,
                                    style: TextStyle(color: isOutgoing ? Colors.white : Colors.black),
                                  ),
                                ),


                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  StreamBuilder(
                    stream: _messagesStreamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        try {
                          final jsonData = json.decode(snapshot.data as String);
                          final messageType = jsonData['messagetype'];
                          final messageContent = jsonData['message'];
                          final senderName = jsonData['name'];

                          if (messageType == 'text' && messageContent.isNotEmpty) {
                            final isOutgoing = senderName == 'You';
                            final chatMessage = ChatMessage(
                              type: isOutgoing ? 'Sender' : 'Receiver',
                              messageType: messageType,
                              message: messageContent,
                              time: jsonData['time'],
                              name: senderName,
                              isOpen: jsonData['isopen'],
                            );

                            chatHistory.add(chatMessage.message);
                            setState(() {}); // Trigger a rebuild to show the new message
                          }
                        } catch (e) {
                          print('Error parsing incoming message: $e');
                        }
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      return Container(); // Empty container if no new message
                    },
                  )



                ],
              ),
            ),


            /*Expanded(
              child: StreamBuilder(
                stream: _messagesStreamController.stream,
                builder: (context, snapshot){
                  if (snapshot.hasData){
                    final message = snapshot.data as String;
                    print('Received Message: $message');
                    return   ListView.builder(
                      itemCount: sentMessagetoUser.length + 1,
                      itemBuilder: (context, index) {
                        if (index == sentMessagetoUser.length) {
                          // Display incoming WebSocket message at the end of the list
                          return ListTile(
                            title: Text(snapshot.data!),
                          );
                        }
                        else{
                          return ListTile(
                            title: Align(
                              alignment: Alignment.centerRight,
                                child: Text(sentMessagetoUser[index])),
                          );
                        }

                      },
                    );
                  }
                  else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return Center(child: CircularProgressIndicator());
                },

              ),
            ),*/

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _handleSendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSendMessage() {
    print("Message sending");
    // Get the message content from the text field
    String messageContent = messageController.text;
    if (messageContent.isNotEmpty) {
      _channel.sink.add(messageContent);
      // setState(() {
      //   chatHistory.add("You: $messageContent"); // Add outgoing message to chat history
      // });
      setState(() {
        sentMessagetoUser.add("You: $messageContent");
      });
    }

    // Call the sendMessageToWhatsApp function with the message content
    sendMessageToWhatsApp(messageContent,);
    messageController.clear();
  }
//  creating function send message via websocket


  Future<void> sendMessageToWebSocket(String messageContent) async {
    print("Sending out going mesg");
    // Replace these values with your actual data
    String recipientPhoneNumber = widget.userPhoneNumber;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
  //  int uId = // Replace this with the user ID of the sender;
    int uId = sharedPreferences.getInt("userId")?? 0;
    print("the sender id is: $uId");
    final messageData = {
      "type": "text", // Type of message, e.g., "text", "image", etc.
      "to": recipientPhoneNumber,
      "fromId": uId,
      "body": messageContent,
      // Add any other fields you need for your message data
    };

    String jsonMessage = json.encode(messageData);

    try {
      print('Sending Message: $jsonMessage');
      _channel.sink.add(jsonMessage);
      setState(() {
        sentMessagetoUser.add(messageContent);
      });
      print('Message sent successfully through WebSocket.');
    } catch (e) {
      print('Error sending message through WebSocket: $e');
    }
  }
///   creating api function for sending outgoing messages to particular user
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
    print(recipientPhoneNumber);

    final messageEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": recipientPhoneNumber,
      "type": "text",
      "fromId": uId,
      "assignedto": 1,
      "fullname": "badal badal",
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

  ///// creating api function to display chatHistory of particular user
  ////  for tik  sent single, deliverd double, read blue double,

  Future<void> fetchChatHistory() async {
    print("This is chat history api calling");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");
    final token = newToken.toString();
    final apiUrl = 'https://customerdigitalconnect.com/chatlist/history/number/${widget.userPhoneNumber}';

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

        // Clear the chatHistory list and populate it with the chat history
        chatHistory.clear();
        for (final messageData in chatHistoryData) {
          final messageType = messageData['messagetype'];
          final messageContent = messageData['message'];
          final senderName = messageData['name'];
          final formattedMessage = '$senderName: $messageContent';

          chatHistory.add(formattedMessage);
        }
        print('fetching chat history:$chatHistoryData');

        setState(() {}); // Trigger a rebuild to show the chat history
      } else {
        print('Failed to fetch chat history. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chat history: $e');
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
      }
    } catch (e) {
      print('Error closing chat: $e');
    }
  }



}


