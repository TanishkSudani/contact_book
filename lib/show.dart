import 'package:contact_book/Model.dart';
import 'package:contact_book/create_cont.dart';
import 'package:contact_book/update_.dart';
import 'package:contact_book/update_dark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:swipe_to/swipe_to.dart';

class show extends StatefulWidget {
  @override
  State<show> createState() => _showState();
}

class _showState extends State<show> {
  Database? db;

  bool status = false;
  List<Map>? data;

  Future<List<Map>?> datalist() async {
    db = await Model().createDatabase() as Database?;

    String qry = "SELECT * FROM Contact_Book";
    List<Map> l = await db!.rawQuery(qry) as List<Map>;
    data = l;
    print("Return l :- $l");
    return l;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPref();
  }

  initPref() async {
    Model.prefs = await SharedPreferences.getInstance();

    mode = Model.prefs!.getBool('mode')!;

      await Model.prefs!.setBool('mode', false);

  }

  bool mode = false;
  bool search = false;
  List<Map> temp = [];
  List<String> Name = [];

  @override
  Widget build(BuildContext context) {
    return mode ? Scaffold(
      backgroundColor: Color(0xff5e5e5e),
        appBar: search
            ? AppBar(
          backgroundColor: Color(0xff343434),
          leading: IconButton(
              onPressed: () {
                temp = data!;
                setState(() {
                  search = false;
                });
              },
              icon: FaIcon(
                FontAwesomeIcons.close,
                color: Colors.white,
              )),
          title: TextField(
            style: TextStyle(color: Colors.white,fontSize: 20),
            autofocus: true,
            onChanged: (value) {
              temp.clear();

              for (int i = 0; i < data!.length; i++) {
                if (data![i]
                    .toString()
                    .toLowerCase()
                    .contains(value.trim().toLowerCase())) {
                  temp.add(data![i]);
                }
              }

              setState(() {});
            },
            cursorColor: Colors.grey,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search Contact here ...",
                hintStyle: TextStyle(color: Colors.grey)),
          ),
        )
            : AppBar(
          backgroundColor: Color(0xff343434),
          leading: IconButton(onPressed: () {
            mode = !mode;
            setState(() {

            });
          }, icon: Icon(Icons.sunny,color: Colors.white,)),
          centerTitle: true,
          title: Text(
            'Contact Book',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  search = true;
                });
              },
              icon: FaIcon(
                FontAwesomeIcons.search,
                color: Colors.white,
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff343434),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) {
                return create_cont();
              },
            ));
          },
          child: Icon(Icons.add,color: Colors.white,),
        ),
        body: search ? FutureBuilder(
          future: datalist(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<Map>? l = snapshot.data;
              print("$l");
              if (snapshot.hasData) {
                return AnimationLimiter(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    itemCount: temp!.length,
                    itemBuilder: (context, index) {
                      Map map = temp[index];
                      String name = map['name'];
                      String contact = map['contact'];
                      int id = map['id'];

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        delay: Duration(milliseconds: 100),
                        child: SlideAnimation(
                          duration: Duration(milliseconds: 2500),
                          curve: Curves.fastLinearToSlowEaseIn,
                          // horizontalOffset: -99000,
                          verticalOffset: -250,
                          child: ScaleAnimation(
                            duration: Duration(milliseconds: 1500),
                            curve: Curves.fastLinearToSlowEaseIn,
                            child: SwipeTo(
                              onRightSwipe: () {
                                //set the number here
                                FlutterPhoneDirectCaller.callNumber(contact);
                              },
                              child: Container(
                                margin:
                                EdgeInsets.only(left: 10, right: 10, top: 10),
                                height: 80,
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: ShapeDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    shadows: [
                                      BoxShadow(
                                          blurRadius: 7,
                                          spreadRadius: 0,
                                          offset: Offset(0, 0),
                                          color: Colors.white.withOpacity(0.2))
                                    ],
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10))),
                                child: ListTile(
                                  trailing: GestureDetector(
                                      onTap: () {
                                        FlutterPhoneDirectCaller.callNumber(
                                            contact);
                                      },
                                      child: Icon(Icons.call,color: Colors.black,size: 30)),
                                  title: Text("${name}"),
                                  subtitle: Text("${contact}"),
                                  leading: Image.network(
                                      'https://cdn.onlinewebfonts.com/svg/img_237553.png'),
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return SimpleDialog(
                                          backgroundColor: Color(0xff000000),
                                          title: Text(
                                            "Select Choice",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          children: [
                                            ListTile(
                                              title: Text("Update",style: TextStyle(color: Colors.white),),
                                              onTap: () {
                                                Navigator.pop(context);
                                                Navigator.pushReplacement(context,
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return update_dark(map);
                                                      },
                                                    ));
                                              },
                                            ),
                                            ListTile(
                                              title: Text("Delete",style: TextStyle(color: Colors.white),),
                                              onTap: () {
                                                Navigator.pop(context);
                                                String qry =
                                                    "DELETE from Contact_Book where id = '$id'";
                                                db!.rawDelete(qry).then((value) {
                                                  Navigator.pushReplacement(
                                                      context, MaterialPageRoute(
                                                    builder: (context) {
                                                      return show();
                                                    },
                                                  ));
                                                });
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text("No Data Error"));
              } else {
                return Center(child: Text("No Data Found"));
              }
            }

            return Center(
              child: CircularProgressIndicator(
                color: Color(0xff00035d),
              ),
            );
          },
        ) :FutureBuilder(
          future: datalist(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<Map>? l = snapshot.data;
              print("$l");
              if (snapshot.hasData) {
                return AnimationLimiter(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    itemCount: l!.length,
                    itemBuilder: (context, index) {
                      Map map = l[index];
                      String name = map['name'];
                      String contact = map['contact'];
                      int id = map['id'];

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        delay: Duration(milliseconds: 100),
                        child: SlideAnimation(
                          duration: Duration(milliseconds: 2500),
                          curve: Curves.fastLinearToSlowEaseIn,
                          // horizontalOffset: -99000,
                          verticalOffset: -250,
                          child: ScaleAnimation(
                            duration: Duration(milliseconds: 1500),
                            curve: Curves.fastLinearToSlowEaseIn,
                            child: SwipeTo(
                              onRightSwipe: () {
                                //set the number here
                                FlutterPhoneDirectCaller.callNumber(contact);
                              },
                              child: Container(
                                margin:
                                EdgeInsets.only(left: 10, right: 10, top: 10),
                                height: 80,
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: ShapeDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    shadows: [
                                      BoxShadow(
                                          blurRadius: 7,
                                          spreadRadius: 0,
                                          offset: Offset(0, 0),
                                          color: Colors.white.withOpacity(0.2))
                                    ],
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10))),
                                child: ListTile(
                                  trailing: GestureDetector(
                                      onTap: () {
                                        FlutterPhoneDirectCaller.callNumber(
                                            contact);
                                      },
                                      child: Icon(Icons.call,color: Colors.black,size: 30)),
                                  title: Text("${name}"),
                                  subtitle: Text("${contact}"),
                                  leading: Image.network(
                                      'https://cdn.onlinewebfonts.com/svg/img_237553.png'),
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return SimpleDialog(
                                          title: Text(
                                            "Select Choice",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          children: [
                                            ListTile(
                                              title: Text("Update"),
                                              onTap: () {
                                                Navigator.pop(context);
                                                Navigator.pushReplacement(context,
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return update_dark(map);
                                                      },
                                                    ));
                                              },
                                            ),
                                            ListTile(
                                              title: Text("Delete"),
                                              onTap: () {
                                                Navigator.pop(context);
                                                String qry =
                                                    "DELETE from Contact_Book where id = '$id'";
                                                db!.rawDelete(qry).then((value) {
                                                  Navigator.pushReplacement(
                                                      context, MaterialPageRoute(
                                                    builder: (context) {
                                                      return show();
                                                    },
                                                  ));
                                                });
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text("No Data Error"));
              } else {
                return Center(child: Text("No Data Found"));
              }
            }

            return Center(
              child: CircularProgressIndicator(
                color: Color(0xff00035d),
              ),
            );
          },
        )
    ) : Scaffold(
      appBar: search
          ? AppBar(
              backgroundColor: Color(0xff00035d),
              leading: IconButton(
                  onPressed: () {
                    temp = data!;
                    setState(() {
                      search = false;
                    });
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.close,
                    color: Colors.white,
                  )),
              title: TextField(
                style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),
                autofocus: true,
                onChanged: (value) {
                  temp.clear();

                  for (int i = 0; i < data!.length; i++) {
                    if (data![i]
                        .toString()
                        .toLowerCase()
                        .contains(value.trim().toLowerCase())) {
                      temp.add(data![i]);
                    }
                  }

                  setState(() {});
                },
                cursorColor: Colors.white,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search Contact here ...",
                    hintStyle: TextStyle(color: Colors.white)),
              ),
            )
          : AppBar(
              backgroundColor: Color(0xff00035d),
              leading: IconButton(onPressed: () {
                mode = !mode;
                setState(() {

                });
              }, icon: Icon(Icons.dark_mode_sharp,color: Colors.white,)),
              centerTitle: true,
              title: Text(
                'Contact Book',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      search = true;
                    });
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.search,
                    color: Colors.white,
                  ),
                )
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff00035d),
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return create_cont();
            },
          ));
        },
        child: Icon(Icons.add),
      ),
      body: search ? FutureBuilder(
        future: datalist(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<Map>? l = snapshot.data;
            print("$l");
            if (snapshot.hasData) {
              return AnimationLimiter(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemCount: temp!.length,
                  itemBuilder: (context, index) {
                    Map map = temp[index];
                    String name = map['name'];
                    String contact = map['contact'];
                    int id = map['id'];

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      delay: Duration(milliseconds: 100),
                      child: SlideAnimation(
                        duration: Duration(milliseconds: 2500),
                        curve: Curves.fastLinearToSlowEaseIn,
                        // horizontalOffset: -99000,
                        verticalOffset: -250,
                        child: ScaleAnimation(
                          duration: Duration(milliseconds: 1500),
                          curve: Curves.fastLinearToSlowEaseIn,
                          child: SwipeTo(
                            onRightSwipe: () {
                              //set the number here
                              FlutterPhoneDirectCaller.callNumber(contact);
                            },
                            child: Container(
                              margin:
                              EdgeInsets.only(left: 10, right: 10, top: 10),
                              height: 80,
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: ShapeDecoration(
                                  color: Color(0xffffffff),
                                  shadows: [
                                    BoxShadow(
                                        blurRadius: 7,
                                        spreadRadius: 0,
                                        offset: Offset(0, 0),
                                        color: Colors.black.withOpacity(0.4))
                                  ],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: ListTile(
                                trailing: GestureDetector(
                                    onTap: () {
                                      FlutterPhoneDirectCaller.callNumber(
                                          contact);
                                    },
                                    child: Image.asset(
                                      'images/call.png',
                                      height: 30,
                                    )),
                                title: Text("${name}"),
                                subtitle: Text("${contact}"),
                                leading: Image.network(
                                    'https://cdn.onlinewebfonts.com/svg/img_237553.png'),
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        title: Text(
                                          "Select Choice",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        children: [
                                          ListTile(
                                            title: Text("Update"),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.pushReplacement(context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return Update(map);
                                                    },
                                                  ));
                                            },
                                          ),
                                          ListTile(
                                            title: Text("Delete"),
                                            onTap: () {
                                              Navigator.pop(context);
                                              String qry =
                                                  "DELETE from Contact_Book where id = '$id'";
                                              db!.rawDelete(qry).then((value) {
                                                Navigator.pushReplacement(
                                                    context, MaterialPageRoute(
                                                  builder: (context) {
                                                    return show();
                                                  },
                                                ));
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("No Data Error"));
            } else {
              return Center(child: Text("No Data Found"));
            }
          }

          return Center(
            child: CircularProgressIndicator(
              color: Color(0xff00035d),
            ),
          );
        },
      ) :FutureBuilder(
        future: datalist(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<Map>? l = snapshot.data;
            print("$l");
            if (snapshot.hasData) {
              return AnimationLimiter(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemCount: l!.length,
                  itemBuilder: (context, index) {
                    Map map = l[index];
                    String name = map['name'];
                    String contact = map['contact'];
                    int id = map['id'];

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      delay: Duration(milliseconds: 100),
                      child: SlideAnimation(
                        duration: Duration(milliseconds: 2500),
                        curve: Curves.fastLinearToSlowEaseIn,
                        // horizontalOffset: -99000,
                        verticalOffset: -250,
                        child: ScaleAnimation(
                          duration: Duration(milliseconds: 1500),
                          curve: Curves.fastLinearToSlowEaseIn,
                          child: SwipeTo(
                            onRightSwipe: () {
                              //set the number here
                              FlutterPhoneDirectCaller.callNumber(contact);
                            },
                            child: Container(
                              margin:
                                  EdgeInsets.only(left: 10, right: 10, top: 10),
                              height: 80,
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: ShapeDecoration(
                                  color: Color(0xffffffff),
                                  shadows: [
                                    BoxShadow(
                                        blurRadius: 7,
                                        spreadRadius: 0,
                                        offset: Offset(0, 0),
                                        color: Colors.black.withOpacity(0.4))
                                  ],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: ListTile(
                                trailing: GestureDetector(
                                    onTap: () {
                                      FlutterPhoneDirectCaller.callNumber(
                                          contact);
                                    },
                                    child: Image.asset(
                                      'images/call.png',
                                      height: 30,
                                    )),
                                title: Text("${name}"),
                                subtitle: Text("${contact}"),
                                leading: Image.network(
                                    'https://cdn.onlinewebfonts.com/svg/img_237553.png'),
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        title: Text(
                                          "Select Choice",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        children: [
                                          ListTile(
                                            title: Text("Update"),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.pushReplacement(context,
                                                  MaterialPageRoute(
                                                builder: (context) {
                                                  return Update(map);
                                                },
                                              ));
                                            },
                                          ),
                                          ListTile(
                                            title: Text("Delete"),
                                            onTap: () {
                                              Navigator.pop(context);
                                              String qry =
                                                  "DELETE from Contact_Book where id = '$id'";
                                              db!.rawDelete(qry).then((value) {
                                                Navigator.pushReplacement(
                                                    context, MaterialPageRoute(
                                                  builder: (context) {
                                                    return show();
                                                  },
                                                ));
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("No Data Error"));
            } else {
              return Center(child: Text("No Data Found"));
            }
          }

          return Center(
            child: CircularProgressIndicator(
              color: Color(0xff00035d),
            ),
          );
        },
      )
    );
  }
}
