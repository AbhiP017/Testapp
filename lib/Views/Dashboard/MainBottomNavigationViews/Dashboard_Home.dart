import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamcdcapp/Views/Dashboard/MainBottomNavigationViews/MainBottomnavigationViews.dart';
import 'package:teamcdcapp/Views/FirstPage.dart';
import 'package:teamcdcapp/Views/UserLogin/SignIn.dart';



class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

enum Options { Profile, Logout, }

class _DashboardState extends State<Dashboard> {


  Card makeDashboardItem(String title, IconData icon) {
    return Card(
        elevation: 1.0,
        margin: EdgeInsets.all(8.0),
        child: Container(

          decoration: BoxDecoration(color: Color.fromRGBO(220, 220, 220, 1.0)),
          child:  InkWell(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                SizedBox(height: 50.0),
                Center(
                    child: Icon(
                      icon,
                      size: 40.0,
                      color: Colors.black,
                    )),
                SizedBox(height: 20.0),
                Center(
                  child:  Text(title, style:  TextStyle(fontSize: 18.0, color: Colors.black)),
                )
              ],
            ),
          ),

          ///// end of container
        )
    );
  }
  List<String> status = ['Scrubbing Machine 1 not working', 'Scrubbing Machine 2 not working',
    'Scrubbing Machine 3 not working', 'Scrubbing Machine 4 not working'];
  List<String> ticketid = ['T-202012345678', 'T-202012356789', 'T-2020123678910', 'T-20201237891011'];

  ///  For Pop PupMenu Functionality
  var _popupMenuItemIndex = 0;
  Color _changeColorAccordingToMenuItem = Colors.red;
  PopupMenuItem _buildPopupMenuItem(String title, IconData iconData, int position) {
    return PopupMenuItem(
      value: position,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            iconData,
            color: Colors.black,
          ),
          Text(title),
        ],
      ),
    );
  }

  _onMenuItemSelected(int value) {
    setState(() {
      _popupMenuItemIndex = value;
    });

    if (value == Options.Profile.index) {
      _changeColorAccordingToMenuItem = Colors.red;
      /*Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 3,)),
      );*/
    } else if (value == Options.Logout.index) {
      _changeColorAccordingToMenuItem = Colors.green;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginView()),
      );
    }
    /*else if (value == Options.copy.index) {
      _changeColorAccordingToMenuItem = Colors.blue;
    }
    else {
      _changeColorAccordingToMenuItem = Colors.purple;
    }*/
  }

  // Array for gridview
  List<CountLabelM> countList = [];



  //// for colour code

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Future<void> logout() async {
    // Clear the user token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    // Navigate back to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FirstScreen(), // Replace LoginScreen with your actual login screen widget
      ),
    );
  }

  @override
  void initState() {

    super.initState();
    setState(() {
      // update your data model here
      GridViewList(context);
    });

  }

  //// widget card for listview data
  Widget GridViewList(BuildContext context)
  {
    final countGridview = GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      children: List.generate(
          countList.length,
              (index) => Center(
            child: InkWell(
              onTap: (){

              },
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      countList[index].label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: countList[index].labelColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.0,),
                    Text(
                      countList[index].count.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          )),
      physics: ClampingScrollPhysics(),
      childAspectRatio: 1.5,
    );

    countList.add(CountLabelM("New", "0", Colors.lightBlue));
    countList.add(CountLabelM("In Progess", "0", Colors.green));
    countList.add(CountLabelM("Resolved", "0", Colors.purple));
    countList.add(CountLabelM("Closed", "0", Colors.red));
    countList.add(CountLabelM("Pending Client", "0", _colorFromHex("#8f00ff")));
    countList.add(CountLabelM("Total Tickets", "0", Colors.orange));

    return countGridview;
  }

  Widget card(String ticketid, String status, BuildContext context) {

    return Card(

      color: _colorFromHex("#F2FFFC"),
      //  elevation: 8.0,
      //  margin: EdgeInsets.all(4.0),
      //  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                ticketid,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  color: _colorFromHex("#3AA4B6"),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }








  /////  For Floating Action Button

  /*Widget _buildFab(BuildContext context) {
    // final icons = [ Icons.sms, Icons.mail, Icons.phone ];
    // return AnchoredOverlay(
    //   showOverlay: true,
    //   overlayBuilder: (context, offset) {
    //     return CenterAbout(
    //      position: Offset(offset.dx, offset.dy - icons.length * 35.0),
    //       child: FabWithIcons(
    //        icons: icons,
    //         onIconTapped: _selectedFab,
    //       ),
    //     );
    //   },
    return FloatingActionButton(
      foregroundColor:Colors.white,
      backgroundColor:  _colorFromHex("#00ABC5"),
      onPressed: () {

        Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTicketView()),);
      },
      tooltip: 'Increment',
      child: Icon(Icons.add),

      elevation: 2.0,
    );
  }*/
  final _fab = FloatingActionButton(
    child: Icon(Icons.add),
    backgroundColor: Colors.black,
    onPressed: () {},
  );

  //// set Stack Widget in body and then wrap AppBar as last widget in Positioned widget.

  Widget setdashboard()
  {
    return Stack(children: [
      /*Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.bottomCenter,
                  colors: [Colors.red, Colors.blue])),
          height: MediaQuery.of(context).size.height * 0.3
      ),*/
      Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        child: Container(
          height: 150,
          child: PreferredSize(
            preferredSize: Size.fromHeight(140.0),
            child: AppBar(        // Add AppBar here only
              backgroundColor: _colorFromHex("#0BADBC"),
             // automaticallyImplyLeading: false,
             /*leading: InkWell(
               child: ImageIcon(
                 AssetImage("images/assets/menu-icon2x.png"),
                 color: _colorFromHex("#44C5DB"),
               ),
             ),*/
             // elevation: 0.0,
              /*title: Text("Dashboard",style: TextStyle(fontSize: 18),),
              elevation: .1,
              centerTitle: false,
              // #0BADBC
            //  b: _colorFromHex("#0BADBC"),
              actions: [
                Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: PopupMenuButton(
                      icon: Icon(Icons.account_circle_outlined,color: Colors.white),
                      onSelected: (value) {
                        _onMenuItemSelected(value as int);
                      },

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                      ),
                      itemBuilder: (ctx) => [
                        _buildPopupMenuItem('Profile', Icons.account_circle_outlined, Options.Profile.index),
                        _buildPopupMenuItem('Logout', Icons.logout_rounded, Options.Logout.index),
                        //  _buildPopupMenuItem('Copy', Icons.copy, Options.copy.index),
                        // _buildPopupMenuItem('Exit', Icons.exit_to_app, Options.exit.index),
                      ],
                    )
                ),
              ],*/
            ),
          ),
        ),
      ),
      Column(
        children: [

          /*Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(alignment: Alignment.centerLeft,
                child: Text("Assign to me",
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )),
            // child: ListView.builder(itemBuilder: itemBuilder),
            */
          /* child: ListView.builder(
                      itemCount: ticketid.length,
                      itemBuilder: (BuildContext context, int index) {
                        return card(ticketid[index], status[index], context);
                      },
                    ),*/
          /*
          ),*/
          SizedBox(height: 85),
          CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 16 / 9,
              height: 130,
              viewportFraction: 0.8,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration:
              Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: false,
              scrollDirection: Axis.horizontal,
            ),
            items: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)),
                    color: Colors.white),
                width: 270,
                // color: Colors.orange,
                height: 1,
                padding:
                EdgeInsets.fromLTRB(12, 12, 12, 12),
                margin:
                EdgeInsets.fromLTRB(10, 10, 10, 10),

                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "All Tickets",
                          style: TextStyle(
                            color: Colors.black,
                            // color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                    ),
                    SizedBox(height: 15,),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "12",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                          ),
                        )),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)),
                    color: Colors.white),
                padding:
                EdgeInsets.fromLTRB(12, 12, 12, 12),
                margin:
                EdgeInsets.fromLTRB(10, 10, 10, 10),
                width: 270,
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Open Tickets",
                          style: TextStyle(
                            color: Colors.black,
                            // color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )),
                    SizedBox(height: 15,),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "12",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        )),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)),
                    color: Colors.white),
                padding:
                EdgeInsets.fromLTRB(12, 12, 12, 12),
                margin:
                EdgeInsets.fromLTRB(10, 10, 10, 10),
                width: 270,
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "In Progress Tickets",
                          style: TextStyle(
                            color: Colors.black,
                            // color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )),
                    SizedBox(height: 15,),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          // ("20" + "%").toString(),
                          ("20").toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        )),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)),
                    color: Colors.white),
                padding:
                EdgeInsets.fromLTRB(12, 12, 12, 12),
                margin:
                EdgeInsets.fromLTRB(10, 10, 10, 10),
                width: 270,
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Resolved Tickets",
                          style: TextStyle(
                            color: Colors.black,
                            // color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )),
                    SizedBox(height: 10,),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "25",
                          style: TextStyle(
                            color: Colors.black,
                            //  fontWeight: FontWeight.w900,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                          ),
                        )),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)),
                    color: Colors.white),
                padding:
                EdgeInsets.fromLTRB(12, 12, 12, 12),
                margin:
                EdgeInsets.fromLTRB(10, 10, 10, 10),
                width: 270,
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Closed Tickets",
                          style: TextStyle(
                            color: Colors.black,
                            // color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )),
                    SizedBox(height: 10,),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "25",
                          style: TextStyle(
                            color: Colors.black,
                            //  fontWeight: FontWeight.w900,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),

          ///// Status wise ticket count
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(alignment: Alignment.centerLeft,
                child: Text("My Tickets",
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )),
            // child: ListView.builder(itemBuilder: itemBuilder),
            /* child: ListView.builder(
                      itemCount: ticketid.length,
                      itemBuilder: (BuildContext context, int index) {
                        return card(ticketid[index], status[index], context);
                      },
                    ),*/
          ),
          SizedBox(
            height: 20,
          ),
          //// here is the  grid view
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                  ),
                ],
                color: Colors.white,
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: GridViewList(context),

            ),
          ),
          /// Container For Ticket List View
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(

                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp("[0-9a-zA-Z]")),
                    ],
                    decoration: InputDecoration(

                        contentPadding: EdgeInsets.all(0.0),
                        hintText: 'Search by Ticket Id',
                        hintStyle: TextStyle(fontSize: 14.0),
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        )
                    ),
                    onChanged: (string) {
                      // _debouncer.run(() {
                      //   setState(() {
                      //     filteredUsers = users
                      //         .where((u) => (u.assetType
                      //         .toLowerCase()
                      //         .contains(string.toLowerCase()) ||
                      //         u.ticketSerialNo
                      //             .toLowerCase()
                      //             .contains(string.toLowerCase())))
                      //         .toList();
                      //   });
                      // });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(alignment: Alignment.centerLeft,
                      child: Text("Recent Tickets",
                        style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )),
                  // child: ListView.builder(itemBuilder: itemBuilder),
                  /* child: ListView.builder(
                      itemCount: ticketid.length,
                      itemBuilder: (BuildContext context, int index) {
                        return card(ticketid[index], status[index], context);
                      },
                    ),*/
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // child: card(ticketid[Index], status, context),
                  // child: ListView.builder(itemBuilder: itemBuilder),
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,

                      shrinkWrap: true,
                      itemCount: ticketid.length,
                      itemBuilder: (BuildContext context, int index) {
                        return card(ticketid[index], status[index], context);
                      },
                    ),
                  ),
                  // child: Card1(context),
                ),
              ],
            ),
          ),


          SizedBox(height: 15,),
          //// For gridview

        ],
      ),
    ],);
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(

     // backgroundColor: _colorFromHex("#F1F2F7"),
      backgroundColor: _colorFromHex("##F1F7FF"),

      /*appBar: AppBar(
        title: Text("Dashboard",style: TextStyle(fontSize: 18),),
        elevation: .1,
        centerTitle: false,
        // #0BADBC
        backgroundColor: _colorFromHex("#0BADBC"),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: PopupMenuButton(
                icon: Icon(Icons.account_circle_outlined,color: Colors.white),
                onSelected: (value) {
                  _onMenuItemSelected(value as int);
                },

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                ),
                itemBuilder: (ctx) => [
                  _buildPopupMenuItem('Profile', Icons.account_circle_outlined, Options.Profile.index),
                  _buildPopupMenuItem('Logout', Icons.logout_rounded, Options.Logout.index),
                  //  _buildPopupMenuItem('Copy', Icons.copy, Options.copy.index),
                  // _buildPopupMenuItem('Exit', Icons.exit_to_app, Options.exit.index),
                ],
              )
          ),],
        // backgroundColor: Color.fromRGBO(49, 87, 110, 1.0),
        //  backgroundColor: _colorFromHex("#EDFFFB"),
      ),*/
      // drawer
      drawer: Drawer(
        backgroundColor: _colorFromHex("##F1F2F7"),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                        height: 100,
                        width: 130,
                        // color: Colors.orange,
                        child:Image(image: AssetImage(
                          ("images/assets/cdc.png"),
                        ),)
                    ),
                  ),
                ),
                SizedBox(height: 0,),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 0.0,right: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                        height: 50,
                        width: 300,
                        // color: Colors.yellow,
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.only(
                        //         topRight: Radius.circular(40.0),
                        //         bottomRight: Radius.circular(40.0)),
                        //     color: Colors.white),
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.bar_chart_sharp,color: _colorFromHex("##44C5DB"),),
                            SizedBox(width: 20,),
                            Container(
                              //height: 50,
                              width: 210,
                              color: _colorFromHex("#0BADBC"),
                              child: InkWell(
                                onTap: (){
                                  print("Dashboard drwaer in Masters screen");

                                  /*Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 0,)),
                                  );*/

                                },
                                child: Text("Dashboard",style: TextStyle(fontSize: 18.0,
                                  //  color: _colorFromHex("#0BADBC"),
                                  color: Colors.white,
                                ),),
                              ),
                            ),
                          ],
                        )
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// This is for tickets
                        /*ExpansionTile(
                          title: Text("Tickets",style: TextStyle(fontSize: 20.0,
                            color: Colors.black,
                          ),),
                          collapsedIconColor: _colorFromHex("##44C5DB"),
                          // sets the color of the arrow when expanded
                          iconColor: _colorFromHex("##44C5DB"),
                          leading: Icon(Icons.dashboard_outlined,
                            color: _colorFromHex("##44C5DB"),), //add icon
                          childrenPadding: EdgeInsets.only(left:25), //children padding
                          children: [
                            ListTile(
                              title: Text("All Tickets",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                print("All ticket list is tapped from dashboard Screen");
                                */
                        /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 1,)),
                                );*/
                        /*
                                //action on press
                              },
                            ),

                            ListTile(
                              title: Text("Open Tickets",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                print("Report ticket list is tapped from dashboard Screen");
                                //action on press
                                */
                        /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 2,)),
                                );*/
                        /*
                              },
                            ),
                            ListTile(
                              title: Text("In Progress",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                print("In Progress is taping from dashboard Screen");
                                //action on press
                                */
                        /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 1,)),
                                );*/
                        /*
                              },
                            ),
                            ListTile(
                              title: Text("Resolved",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                print("Resolved is taping from dashboard Screen");
                                //action on press
                              },
                            ),
                            ListTile(
                              title: Text("Closed",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                print("Closed is taping from dashboard Screen");
                                */
                        /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 1,)),
                                );*/
                        /*
                                //action on press
                              },
                            ),

                            //more child menu
                          ],
                        ),*/
                        //// This is for masters
                        ExpansionTile(
                          title: Text("Masters",style: TextStyle(fontSize: 18.0,
                            color: Colors.black,
                          ),),
                          collapsedIconColor: _colorFromHex("#44C5DB"),
                          // sets the color of the arrow when expanded
                          iconColor: _colorFromHex("#44C5DB"),
                          leading: Icon(Icons.format_list_bulleted,
                            color: _colorFromHex("#44C5DB"),), //add icon
                          childrenPadding: EdgeInsets.only(left:30), //children padding
                          children: [
                            ListTile(
                              title: Text("Company",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 1,),),
                                );
                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MastersView()),
                                );*/
                                //action on press
                              },
                            ),
                            ListTile(
                              title: Text("Department",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){

                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ServiceTitleListView()),
                                );*/
                                //action on press
                              },
                            ),
                            ListTile(
                              title: Text("User",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){

                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ServiceTitleListView()),
                                );*/
                                //action on press
                              },
                            ),
                            ListTile(
                              title: Text("Roles & permissions",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){

                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ServiceTitleListView()),
                                );*/
                                //action on press
                              },
                            ),
                            ListTile(
                              title: Text("Approval Matrix",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){

                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ServiceTitleListView()),
                                );*/
                                //action on press
                              },
                            ),
                            ListTile(
                              title: Text("Customers",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){

                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ServiceTitleListView()),
                                );*/
                                //action on press
                              },
                            ),
                            //more child menu
                          ],
                        ),

                        //// Inbox
                        ExpansionTile(
                          title: Text("Inbox",style: TextStyle(fontSize: 20.0,
                            color: Colors.black,
                          ),),
                          collapsedIconColor: _colorFromHex("##44C5DB"),
                          // sets the color of the arrow when expanded
                          iconColor: _colorFromHex("##44C5DB"),
                          leading: Icon(Icons.inbox_outlined,
                            color: _colorFromHex("##44C5DB"),), //add icon
                          childrenPadding: EdgeInsets.only(left:30), //children padding
                          children: [
                            ListTile(
                              title: Text("Report 1",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 2,)),
                                );*/
                                //action on press
                              },
                            ),

                            ListTile(
                              title: Text("Report 2",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                //action on press
                              },
                            ),
                            //more child menu
                          ],
                        ),
                        //// Notifications
                        ExpansionTile(
                          title: Text("Notifications",style: TextStyle(fontSize: 20.0,
                            color: Colors.black,
                          ),),
                          collapsedIconColor: _colorFromHex("##44C5DB"),
                          // sets the color of the arrow when expanded
                          iconColor: _colorFromHex("##44C5DB"),
                          leading: Icon(Icons.notification_add_outlined,
                            color: _colorFromHex("##44C5DB"),), //add icon
                          childrenPadding: EdgeInsets.only(left:30), //children padding
                          children: [
                            ListTile(
                              title: Text("Report 1",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 2,)),
                                );*/
                                //action on press
                              },
                            ),

                            ListTile(
                              title: Text("Report 2",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                //action on press
                              },
                            ),
                            //more child menu
                          ],
                        ),
                        //// templates
                        ExpansionTile(
                          title: Text("Templates",style: TextStyle(fontSize: 20.0,
                            color: Colors.black,
                          ),),
                          collapsedIconColor: _colorFromHex("##44C5DB"),
                          // sets the color of the arrow when expanded
                          iconColor: _colorFromHex("##44C5DB"),
                          leading: Icon(Icons.message_outlined,
                            color: _colorFromHex("##44C5DB"),), //add icon
                          childrenPadding: EdgeInsets.only(left:30), //children padding
                          children: [
                            ListTile(
                              title: Text("Report 1",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 2,)),
                                );*/
                                //action on press
                              },
                            ),

                            ListTile(
                              title: Text("Report 2",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                //action on press
                              },
                            ),
                            //more child menu
                          ],
                        ),
                        ///// products
                        ExpansionTile(
                          title: Text("Products",style: TextStyle(fontSize: 20.0,
                            color: Colors.black,
                          ),),
                          collapsedIconColor: _colorFromHex("##44C5DB"),
                          // sets the color of the arrow when expanded
                          iconColor: _colorFromHex("##44C5DB"),
                          leading: Icon(Icons.propane_tank_outlined,
                            color: _colorFromHex("##44C5DB"),), //add icon
                          childrenPadding: EdgeInsets.only(left:30), //children padding
                          children: [
                            ListTile(
                              title: Text("Report 1",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 2,)),
                                );*/
                                //action on press
                              },
                            ),

                            ListTile(
                              title: Text("Report 2",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                //action on press
                              },
                            ),
                            //more child menu
                          ],
                        ),
                        //// Settings
                        ExpansionTile(
                          title: Text("Templates",style: TextStyle(fontSize: 20.0,
                            color: Colors.black,
                          ),),
                          collapsedIconColor: _colorFromHex("##44C5DB"),
                          // sets the color of the arrow when expanded
                          iconColor: _colorFromHex("##44C5DB"),
                          leading: Icon(Icons.settings,
                            color: _colorFromHex("##44C5DB"),), //add icon
                          childrenPadding: EdgeInsets.only(left:30), //children padding
                          children: [
                            ListTile(
                              title: Text("Report 1",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BottomNavigationBarView(selectedIndex: 2,)),
                                );*/
                                //action on press
                              },
                            ),

                            ListTile(
                              title: Text("Report 2",style: TextStyle(fontSize: 18.0,
                                color: Colors.black,),),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle,size: 10,color: _colorFromHex("##44C5DB"),)
                                ],
                              ),
                              onTap: (){
                                //action on press
                              },
                            ),
                            //more child menu
                          ],
                        ),
                        IconButton(onPressed: (){
                          print("logout button clicked");

                          logout();

                        }, icon: Icon(Icons.logout,color: Colors.black,))
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),

      ),

      body: SingleChildScrollView(
         child: setdashboard(),

      ),
      //  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: _buildFab(context),

    );
  }
}

class CountLabelM {
  String label;
  String count;
  Color labelColor;

  CountLabelM(this.label, this.count, this.labelColor);
}
