import 'package:contact_book/show.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'Model.dart';

class update_dark extends StatefulWidget {

  Map map;

  update_dark(this.map);


  @override
  State<update_dark> createState() => _update_darkState();
}

class _update_darkState extends State<update_dark> {

  TextEditingController name = TextEditingController();
  TextEditingController contact = TextEditingController();
  bool nameerror = false;
  bool namevalid = false;
  bool contacterror = false;

  int textLength = 0;
  int maxLength = 10;

  String contactmsg = "";
  Database? db;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    name.text = widget.map['name'];
    contact.text = widget.map['contact'];

    Model().createDatabase().then((value) {
      db = value;
    });
  }

  Future<bool> goBack()
  {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return show();
    },));
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      backgroundColor: Color(0xff5e5e5e),
      appBar: AppBar(
        backgroundColor: Color(0xff343434),
        leading: IconButton(onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
            return show();
          },));
        }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        title: Text(
          'Update Contact',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Image.asset(
                  'images/1.png',color: Colors.white,),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  print(value);
                  if (nameerror) {
                    if (value.isNotEmpty) {
                      setState(() {
                        nameerror = false;
                      });
                    }
                  }
                },
                controller: name,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(
                        0xffffffff),width: 3)),
                    border: OutlineInputBorder(),
                    hintText: "Enter Name",
                    labelText: "Name",
                    labelStyle: TextStyle(color: Color(0xffffffff)),
                    errorText: nameerror ? "Please Enter Valid Name" : null,
                    prefixIcon: Icon(Icons.person,color: Color(0xffffffff),)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    textLength = value.length;
                  });
                  if (contacterror) {
                    if (value.isNotEmpty) {
                      setState(() {
                        contacterror = false;
                      });
                    }
                  }
                },
                controller: contact,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xffffffff))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xffffffff),width: 3)),
                    counter: Offstage(),
                    suffixText:
                    '${textLength.toString()}/${maxLength.toString()}',
                    hintText: "Enter Your Contact",
                    labelText: "Contact",
                    labelStyle: TextStyle(color: Color(0xffffffff)),
                    errorText: contacterror ? contactmsg : null,
                    prefixIcon: Icon(Icons.phone,color: Color(0xffffffff),)),
              ),
            ),
            InkWell(
              onTap: () {
                String Name = name.text;
                String Phone = contact.text;
                int id = widget.map['id'];

                if (Name.isEmpty) {
                  setState(() {
                    nameerror = true;
                  });
                } else if (Phone.isEmpty) {
                  setState(() {
                    contacterror = true;
                    contactmsg = "Enter your Contact";
                  });
                } else if (Phone.length < 10) {
                  setState(() {
                    contacterror = true;
                    contactmsg = "Please Enter 10 digit Contact";
                  });
                }
                else
                {
                  String qry = "UPDATE Contact_Book set name = '$Name',contact = '$Phone' where id = '$id'";
                  db!.rawUpdate(qry).then((value) {
                    print(value);
                  });

                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                    return show();
                  },));
                }
              },
              child: Container(
                height: 50,
                width: 50,
                margin: EdgeInsets.only(left: 120, right: 120),
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                    color: Color(0xff838383),
                    shadows: [
                      BoxShadow(
                          blurRadius: 7,
                          spreadRadius: 1,
                          offset: Offset(0, 3),
                          color: Colors.black.withOpacity(0.4))
                    ],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Text(
                  "Update",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            )
          ],
        ),
      ),
    ), onWillPop: goBack);
  }
}
