import 'package:contact_book/create_cont.dart';
import 'package:contact_book/show.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: splash(),
    theme: ThemeData(fontFamily: 'SfPro'),
  ));
}

class splash extends StatefulWidget {
  const splash({Key? key}) : super(key: key);

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    go();

  }


  go() async {

    await Future.delayed(Duration(seconds: 5));
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) {
        return show();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.network('https://assets4.lottiefiles.com/private_files/lf30_uvrwjrrs.json'),
      ),
    );
  }
}
