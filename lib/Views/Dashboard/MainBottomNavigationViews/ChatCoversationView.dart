import 'package:flutter/material.dart';


class ChatConversationPage extends StatefulWidget{

  ChatConversationPage();

  @override
  ChatConversationPageState createState() => ChatConversationPageState();
}

class ChatConversationPageState extends State<ChatConversationPage>{

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));

  }

  Widget openattachment(){

    return IconButton(
        icon: Icon(Icons.add),
        onPressed: () {
          showBottomSheet(
              context: context,
              builder: (context) => Container(
                color: Colors.red[100],
                height: 250,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Icon(Icons.home),
                        Icon(Icons.hot_tub),
                        Icon(Icons.hourglass_empty),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Icon(Icons.home),
                        Icon(Icons.hot_tub),
                        Icon(Icons.hourglass_empty),
                      ],
                    ),
                  ],
                ),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {

    //#EFF3F6
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Conversation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Replace with the actual number of messages
              reverse: true, // To display the latest message at the bottom
              itemBuilder: (context, index) {
                // Replace with the logic to get the actual message data
                final message = 'Hi, How are you? $index';
                final isMe = index % 2 == 0; // Replace with the logic to determine if the message is sent by the user or received

                return ChatMessage(
                  text: message,
                  isMe: isMe,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
             color: Colors.grey[200], padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
            children: [
            IconButton(
              icon: Icon(Icons.insert_emoticon),
            onPressed: () {
              // Add your logic here for opening the emoji picker
               },
              ),
              Expanded(
             child: TextField(
               onChanged: (text) {

               },
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
              /// Container For popupwindow attachment
              IconButton(
              icon: Icon(Icons.attach_file),
              onPressed: () {
                print("Attachment button clicked");
               // openattachment();

                showDialog(
                    context: context,

                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        elevation: 16,
                        child:Container(

                          color: Colors.red[100],
                          height: 150,
                          width: 150,

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Icon(Icons.home),
                                  Icon(Icons.hot_tub),
                                  Icon(Icons.hourglass_empty),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Icon(Icons.home),
                                  Icon(Icons.hot_tub),
                                  Icon(Icons.hourglass_empty),
                                ],
                              ),
                            ],
                          ),
                        ) ,
                      );
                    }
                  );

              // Add your logic here for attaching files
              },
               ),
               IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () {
                 // Add your logic here for capturing photos
               },
               ),
                IconButton(
                icon: Icon(Icons.send),
                onPressed:  () {
                // Add your logic here for sending the message
                },
               ),
               ],
               ),
               ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isMe;

  const ChatMessage({
    Key? key,
    required this.text,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
