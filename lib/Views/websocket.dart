import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';



class MySocket extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Example',
      home: ChatScreenView(),
    );
  }
}

class ChatScreenView extends StatefulWidget {
  @override
  _ChatScreenViewState createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreenView> {
  final TextEditingController _messageController = TextEditingController();
  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://65.1.109.24:8080/chat'), // Replace with your WebSocket server URL
  );


  @override
  void initState() {
    super.initState();

    // Listen to incoming WebSocket messages and handle them using _handleIncomingMessages
   // _channel.stream.listen(_handleIncomingMessages);
  }


  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  void _sendMessage() {
    print("message send to socket");
    final message = _messageController.text;
    if (message.isNotEmpty) {
      _channel.sink.add(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Example'),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _channel.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(snapshot.data),
                  );
                } else if (snapshot.hasError) {
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
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
