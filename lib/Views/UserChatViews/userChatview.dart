import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

  // Function to handle incoming WebSocket messages and add them to the StreamController
  void _handleIncomingMessages(dynamic data) {
    _messagesStreamController.add(data);
  }

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
  }

  @override
  Widget build(BuildContext context) {
    return FlutterEasyLoading(
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.userPhoneNumber}'),
          centerTitle: true,
          //  automaticallyImplyLeading: false,
          backgroundColor: _colorFromHex("#0BADBC"),
        ),
        body: Column(
          children: [
            Expanded(
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
                  return CircularProgressIndicator();
                },

              ),
            ),
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
    }

    setState(() {
      sentMessagetoUser.add("You: $messageContent");
    });

    // Call the sendMessageToWhatsApp function with the message content
    sendMessageToWhatsApp(messageContent,);
    //  messageController.clear();
  }



  Future<void> sendMessage(Map<String, dynamic> messageEntry) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var newToken = sharedPreferences.getString("token");
    final token = newToken.toString();

    String url = "https://customerdigitalconnect.com/outgoing/send-message";

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(messageEntry),
      );

      if (response.statusCode == 200) {
        print("Message sent successfully");
        // Update the chat history with the sent message
        setState(() {
          chatHistory.add("You: $messageContent");
        });
        messageController.clear();
      } else {
        print("Failed to send message. Status code: ${response.statusCode}, Response: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> sendMessageToWhatsApp(String messageContent) async {
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
      } else {
        print('Failed to send message. Status code: ${response
            .statusCode}, Response: $responseBody');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }


}


