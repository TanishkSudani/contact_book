import 'package:contact_book/Model.dart';
import 'package:contact_book/create_cont.dart';
import 'package:contact_book/update_.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:swipe_to/swipe_to.dart';

class show extends StatefulWidget {
  const show({Key? key}) : super(key: key);

  @override
  State<show> createState() => _showState();
}

class _showState extends State<show> {
  Database? db;

  bool status = false;

 Future<List<Map>?> datalist() async {

    db = await Model().createDatabase() as Database?;

      String qry = "SELECT * FROM Contact_Book";
   List<Map> l = await db!.rawQuery(qry) as List<Map>;

    print("Return l :- $l");
    return l;
  }


  bool search = false;
  List<String> temp = [];
  List<String> Name = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: search ? AppBar(
          backgroundColor: Color(0xff00035d),
          leading: IconButton(onPressed: () {
            setState(() {
              search = false;
            });
          }, icon: FaIcon(FontAwesomeIcons.close,color: Colors.white,)),
          title: TextField(
            autofocus: true,
            onChanged: (value) {

              temp.clear();
              setState(() {

              });

            },
            cursorColor: Colors.white,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Search Contact here ...",
              hintStyle: TextStyle(color: Colors.white)
            ),
          ),
        ) : AppBar(
          backgroundColor: Color(0xff00035d),
          centerTitle: true,
          title: Text(
            'Contact Book',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          actions: [
            IconButton(onPressed: () {
              setState(() {
                search = true;
              });
            }, icon: FaIcon(FontAwesomeIcons.search,color: Colors.white,),)
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
        body:  FutureBuilder(future: datalist(),builder: (context, snapshot) {


          if(snapshot.connectionState == ConnectionState.done)
            {
              List<Map>? l = snapshot.data;
              print("$l");
                if(snapshot.hasData)
                  {

                    return ListView.builder(
                      itemCount: l!.length,
                      itemBuilder: (context, index) {
                        Map map = l![index];
                        String name = map['name'];
                        String contact = map['contact'];
                        int id = map['id'];

                        return SwipeTo(
                          onRightSwipe: () {
                            launch("tel://${contact}");
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                            height: 80,
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(
                                color: Color(0xffffffff),
                                shadows: [
                                  BoxShadow(
                                      blurRadius: 7,
                                      spreadRadius: 1,
                                      offset: Offset(0, 3),
                                      color: Colors.black.withOpacity(0.4))
                                ],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: ListTile(
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
                                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                              return Update(map);
                                            },));
                                          },
                                        ),
                                        ListTile(
                                          title: Text("Delete"),
                                          onTap: () {
                                            Navigator.pop(context);
                                            String qry = "DELETE from Contact_Book where id = '$id'";
                                            db!.rawDelete(qry).then((value) {
                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                                return show();
                                              },));
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
                        );
                      },
                    );
                  }
                else if(snapshot.hasError)
                  {
                    return Center(child: Text("No Data Error"));
                  }
                else
                  {
                    return Center(child: Text("No Data Found"));
                  }
            }

          return Center(child: CircularProgressIndicator(color: Color(0xff00035d),),);
        },)

    );
  }
}
