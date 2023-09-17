
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamcdcapp/DemoViews/WhatsappDemo.dart';

import 'OpenChatInboxScreen.dart';


class chatLisitingTab extends StatefulWidget{

  chatLisitingTab();

  @override
  State<chatLisitingTab> createState() => _chatLisitingTabState();
}

class _chatLisitingTabState extends State<chatLisitingTab> with TickerProviderStateMixin{


  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
  int _currentIndex = 0;
  late TabController tabController;





  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this,);
    fetchdata();
   // prefs;
  }
  String myText = 'Hello, World!';

  @override
  Widget build(BuildContext context) {

    Color color1 = _colorFromHex("#00ABC5");

    return DefaultTabController(length: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(title: Text("All Chats"),
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: _colorFromHex("#0BADBC"),
            
            actions: [

              Container(
                child: Row(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: IconButton(
                          icon: Icon(Icons.search,color: Colors.white),
                          onPressed: (){
                            print("Notification is printing");
                            /*Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserNotifications()),
                          );*/
                          },


                        )
                    ),

                    Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: IconButton(
                          icon: Icon(Icons.filter_alt_outlined,color: Colors.white),
                          onPressed: () {

                          },


                        )
                    ),
                  ],
                ),
              ),

            ],

          ///
            bottom:PreferredSize(
              preferredSize: new Size(20.0, 20.0),

              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: tabController,
                  indicatorColor:Colors.pink,
                  labelColor: Colors.pink,
                  unselectedLabelColor: Colors.grey,



                  tabs: [
                    Tab(child: Text("OPEN",style: TextStyle(fontSize: 16),),
                    ),
                    Tab(child: Text("CLOSED", style: TextStyle(fontSize: 16),))
                  ],
                ),
              ),
            ),
          ),

          body: Container(
            color: Colors.amber,
            child: TabBarView(

              controller: tabController,
              children: [

                OpenChatViewDesign(),
                ClosedChatViewDesign(),
               // ListViewTest()
              //  UserFilterDemo(),
              //  ResolveTickets()
              ],
            ),
            
          ),
        )
    );

  }

 fetchdata () async {

   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

   var newtoken = sharedPreferences.getString("token");
  // var LatestToken = sharedPreferences.getString("firebase_token");
   print("pathak token is:"+newtoken.toString());
 }

}