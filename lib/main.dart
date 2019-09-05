import 'package:flutter/material.dart';
import 'package:flutter_app/Mapping.dart';
import 'dart:async';
import 'Authentication.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      title: "MyApp",
      theme: new ThemeData(

        primaryColor: Color.fromRGBO(240, 151, 38, 1),
        primaryColorLight: Colors.blueAccent,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      routes: <String, WidgetBuilder>{
        'loginandreg.dart':(BuildContext context)=>MappingPage(),
      },
        home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  startTime() async{
    var _duration=new Duration(seconds: 2);
    return Timer(_duration, navigationPage);
  }

  void navigationPage(){
    Navigator.push(
        context,
        MaterialPageRoute(builder:(context)
        {
          return new MappingPage(auth: Auth(),);
        }
        )
    );
  }

  @override
  void initState(){
    super.initState();
    startTime();
  }

  final background=Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/back.png'),
        fit: BoxFit.cover,
      ),
    ),

  );

  final logo= Image.asset(
    'assets/logo.png',
    alignment: Alignment(0,2.0),
    height: 250,
    width: 380,
  );

  final version= Text(
    'Version 1.0',
    style: TextStyle(color: Colors.grey,
        height: 20.0),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit:StackFit.expand,
        children: <Widget>[
          background,
          SafeArea( child:
            Column(
              children: <Widget>[
                logo, version
            ],
          ),
          ),
        ],
      ),

    );
  }
}
