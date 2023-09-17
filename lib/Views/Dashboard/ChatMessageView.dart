import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> chatHistory = [];

  TextEditingController messageController = TextEditingController();

  Future<void> sendMessagetouser(String message) async {
    final url = Uri.parse('https://example.com/send-message');
    final response = await http.post(url, body: {'message': message});

    if (response.statusCode == 200) {
      setState(() {
        chatHistory.add('User: $message');
        chatHistory.add('Bot: ${response.body}');
      });
      messageController.clear();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to send message'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  void _handleSendMessage() {
    print("send message is tapped");
    // Get the message content from the text field
    String messageContent = messageController.text;

    // Construct the messageEntry parameter
    Map<String, dynamic> messageEntry = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": "919616921038",
      "type": "text",
      "fromId": 14,
      "assignedto": 1,
      "fullname": "badal badal",
      "text": {
        "preview_url": false,
        "body": messageContent,
      }
    };

    // Call the sendMessage function with the messageEntry
    sendMessage(messageEntry);
  }

  // void _handleSendMessage() async {
  //   // Get the message content from the text field
  //   print("handle send message");
  //   String messageContent = messageController.text;
  //
  //   // Get the user ID from SharedPreferences
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   int? uId = sharedPreferences.getInt("userId"); // Use 'int?' to handle nullable value
  //
  //   // Construct the messageEntry parameter
  //   Map<String, dynamic> messageEntry = {
  //     "messaging_product": "whatsapp",
  //     "recipient_type": "individual",
  //     "to": "919616921038",
  //     "type": "text",
  //     "fromId": uId,
  //     "assignedto": 1,
  //     "fullname": "badal badal",
  //     "text": {
  //       "preview_url": false,
  //       "body": messageContent,
  //     }
  //   };
  //
  //   print("Message Entry: $messageEntry"); // Add this line to print the messageEntry
  //
  //   // Call the sendMessage function with the messageEntry
  //   sendMessage(messageEntry);
  // }



  // Future<void> _handleSendMessage() async {
  //   print("send button is clicked");
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //  var newToken = sharedPreferences.getString("token");
  //  final token = newToken.toString();
  //   var uId = sharedPreferences.getInt("userId");
  //   String fromId = uId.toString();
  //   String messageContent = messageController.text;
  //
  //   Map<String, dynamic> messageEntry = {
  //     "messaging_product": "whatsapp",
  //     "recipient_type": "individual",
  //     "to": "919616921038",
  //     "type": "text",
  //     "fromId": fromId,
  //     "assignedto": 1,
  //     "fullname": "badal badal",
  //     "text": {
  //       "preview_url": false,
  //       "body": messageContent,
  //     }
  //   };
  //
  //   try {
  //     var response = await http.post(
  //       Uri.parse('https://customerdigitalconnect.com/outgoing/send-message'),
  //       headers: {
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: messageEntry,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print('Message sent successfully.');
  //     } else {
  //       print('Failed to send message. Status code: ${response.statusCode}, Response: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  // Future<void> _handleSendMessage() async {
  //   print("send message is tapped");
  //   // Get the message content from the text field
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  // // var Uid= sharedPreferences.getInt("userId").toString();
  // //  print("badal id is: ${Uid.toString()}");
  // //  print("badal id is: ${uId.toString()}");
  //   String messageContent = messageController.text;
  //
  //   // Construct the messageEntry parameter
  //   Map<String, dynamic> messageEntry = {
  //     "messaging_product": "whatsapp",
  //     "recipient_type": "individual",
  //     "to": "919616921038",
  //     "type": "text",
  //     "fromId": "14",
  //     "assignedto": "1",
  //     "fullname": "badal badal",
  //     "text": {
  //       "preview_url": false,
  //       "body": messageContent,
  //     }
  //   };
  //
  //   // Call the sendMessage function with the messageEntry
  //   sendMessage(messageEntry);
  // }



  @override
  Widget build(BuildContext context) {
    return FlutterEasyLoading(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat '),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatHistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(chatHistory[index]),
                  );
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
                  ///? for send message button click
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {

                     // onSendButtonPressed();
                      _handleSendMessage();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
        'Content-Type': 'application/json', // Set the content type to JSON
        'Authorization': 'Bearer $token',
      },
      body: json.encode(messageEntry), // Send the messageEntry map directly as the request body
    );

    if (response.statusCode == 200) {
      // Request successful, handle the response if needed
      print("Message sent successfully");
    } else {
      print("Failed to send message. Status code: ${response.statusCode}, Response: ${response.body}");
    }
  } catch (e) {
    print("Error: $e");
  }
}







Future<void> sendMessageToWhatsApp(Map<String, dynamic> messageEntry) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var newToken = sharedPreferences.getString("token");
  final token = newToken.toString();
  final apiUrl = 'https://customerdigitalconnect.com/outgoing/send-message';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(messageEntry),
    );

    if (response.statusCode == 200) {
      print('Message sent successfully.');
    } else {
      print('Failed to send message. Status code: ${response.statusCode}, Response: ${response.body}');
    }
  } catch (e) {
    print('Error sending message: $e');
  }
}

// void sendMessage(Map<String, dynamic> messageEntry) async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   var newToken = sharedPreferences.getString("token");
//   final token = newToken.toString();
//
//   String url = "https://customerdigitalconnect.com/outgoing/send-message";
//
//   try {
//     var response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: json.encode(messageEntry), // Convert messageEntry to a JSON string
//     );
//
//     if (response.statusCode == 200) {
//       // Request successful, handle the response if needed
//       print("Message sent successfully");
//     } else {
//       print("Failed to send message. Status code: ${response.statusCode}, Response: ${response.body}");
//     }
//   } catch (e) {
//     print("Error: $e");
//   }
// }
// void sendMessage(Map<String, dynamic> messageEntry) async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   var newToken = sharedPreferences.getString("token");
//   final token = newToken.toString();
//
//   String url = "https://customerdigitalconnect.com/outgoing/send-message";
//   try {
//     // Create a new instance of http.Client
//     var client = http.Client();
//
//     // Make the HTTP POST request with form fields
//     var response = await client.post(
//       Uri.parse(url),
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//       body: messageEntry, // Pass the messageEntry directly as form fields
//     );
//
//     // Process the response
//     if (response.statusCode == 200) {
//       // Request successful, handle the response if needed
//       print("Message sent successfully");
//     } else {
//       // Request failed, handle the error
//       print("Failed to send message. Status code: ${response.statusCode}, Response: ${response.body}");
//       final jsonResponse = response.body != null ? jsonDecode(response.body) : null;
//       print("==error jsonResponse is that: " + jsonResponse.toString());
//     }
//
//     // Close the client to release resources
//     client.close();
//   } catch (e) {
//     // Handle any exceptions that may occur during the request
//     print("Error: $e");
//   }
//
//   // try {
//   //   // Convert the messageEntry map to JSON
//   //   String requestBodyJson = jsonEncode(messageEntry);
//   //
//   //   print("The body is:"+requestBodyJson);
//   //
//   //   // Set the headers for the request
//   //   var headers = {
//   //     'Content-Type': 'application/json',
//   //     'Authorization': 'Bearer $token',
//   //   };
//   //
//   //   // Make the HTTP POST request with the JSON body and headers
//   //   var response = await http.post(
//   //     Uri.parse(url),
//   //     headers: headers,
//   //     body: requestBodyJson,
//   //   );
//   //
//   //   // Process the response
//   //   if (response.statusCode == 200) {
//   //     // Request successful, handle the response if needed
//   //     print("Message sent successfully");
//   //   } else {
//   //     // Request failed, handle the error
//   //     print("Failed to send message. Status code: ${response.statusCode}, Response: ${response.body}");
//   //     final jsonResponse = response.body != null ? jsonDecode(response.body) : null;
//   //     print("==error jsonResponse is that: " + jsonResponse.toString());
//   //   }
//   // } catch (e) {
//   //   // Handle any exceptions that may occur during the request
//   //   print("Error: $e");
//   // }
// }

// void sendMessage(Map<String, dynamic> messageEntry) async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   var newToken = sharedPreferences.getString("token");
//   final token = newToken.toString();
//
//   String url = "https://customerdigitalconnect.com/outgoing/send-message";
//
//   try {
//     var request = http.MultipartRequest('POST', Uri.parse(url));
//     request.headers['Authorization'] = 'Bearer $token';
//
//     // Add form fields for each entry in the messageEntry map
//     for (var entry in messageEntry.entries) {
//       request.fields[entry.key] = entry.value.toString();
//       print(request.fields[entry.key]);
//     }
//
//     var response = await request.send();
//     var responseBody = await response.stream.bytesToString();
//     print("the response body is"+responseBody);
//     if (response.statusCode == 200) {
//       // Request successful, handle the response if needed
//       print("Message sent successfully");
//     } else {
//       print("Failed to send message. Status code: ${response.statusCode}, Response: $responseBody");
//       final jsonResponse = responseBody != null ? jsonDecode(responseBody) : null;
//            print("==error jsonResponse is that: " + jsonResponse.toString());
//     }
//   } catch (e) {
//     print("Error: $e");
//   }
//
//   // try {
//   //   var response = await http.post(
//   //     Uri.parse(url),
//   //     headers: {
//   //       'Content-Type': 'application/json',
//   //       'Authorization': 'Bearer $token',
//   //     },
//   //     body: jsonEncode(messageEntry),
//   //   );
//   //
//   //   if (response.statusCode == 200) {
//   //     // Request successful, handle the response if needed
//   //     print("Message sent successfully");
//   //   } else {
//   //     print("Failed to send message. Status code: ${response.statusCode}");
//   //     final jsonResponse = response.body != null ? jsonDecode(response.body) : null;
//   //     print("==error jsonResponse is that: " + jsonResponse.toString());
//   //     EasyLoading.showError(jsonResponse != null ? jsonResponse['message'] ?? 'Unknown error' : 'Unknown error');
//   //   }
//   // } catch (e) {
//   //   print("Error: $e");
//   // }
// }


// void sendMessage(String messageContent) async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   var newToken = sharedPreferences.getString("token");
//   final token = newToken.toString();
//   final uId = sharedPreferences.getInt("userId");
//   print("badal id is: $uId");
//
//   String url = "https://customerdigitalconnect.com/outgoing/send-message";
//
//   // Construct the messageEntry parameter as per the provided Postman data
//
//
//   try {
//     var response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode(messageEntry), // Send messageEntry directly as the request body
//     );
//     // ... Your existing code ...
//   } catch (e) {
//     // ... Your existing code ...
//   }
// }


void main() {
  runApp(
    MaterialApp(
      home: ChatScreen(),
    ),
  );
}
