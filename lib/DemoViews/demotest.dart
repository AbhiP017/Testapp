import 'package:flutter/material.dart';



class DemoTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("widget.title"),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 70,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(Icons.home),
              Icon(Icons.alarm),
              MyMiddleIcon(),
              Icon(Icons.album),
              Icon(Icons.assignment_ind),
            ],
          ),
        ),
        shape: CircularNotchedRectangle(),
        color: Colors.blueGrey[50],
      ),
    );
  }
}

class MyMiddleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}