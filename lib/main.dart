import 'package:flutter/material.dart';
import 'package:flutter_app/Mapping.dart';

import 'Authentication.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      title: "MyApp",
      theme: new ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.amber,
        primaryColorLight: Colors.blueAccent,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),

        home: MappingPage(auth: Auth(),),
    );
  }
}