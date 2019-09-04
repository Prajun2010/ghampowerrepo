import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter_app/editPost.dart';

import 'HomePage.dart';


class DetailPage extends StatefulWidget {

  final DocumentSnapshot post;
  DetailPage({this.post});

  @override
  _DetailPageState createState() => _DetailPageState();
}



class _DetailPageState extends State<DetailPage> {



  @override

  Widget build(BuildContext context) {

    String timekey=widget.post.data['timekey'];
    String name=widget.post.data['description'];
    String email=widget.post.data['email'];
    String phone=widget.post.data['phone'];
    String age=widget.post.data['age'];
    String sex=widget.post.data['sex'];
    String district=widget.post.data['district'];

    goToHomePage(){
      Navigator.push(
          context,
          MaterialPageRoute(builder:(context)
          {
            return new HomePage();
          }
          )
      );
    }

    void _showDialog(){
      showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: new Text("Are you sure you want to delete?"),
              content: new Text("Once the data is deleted, It is not recoverable"),
              actions: <Widget>[
                new FlatButton(onPressed: (){Navigator.pop(context);}, child: new Text("Cancel")),
                new FlatButton(onPressed: (){
                  final db = Firestore.instance;
                  db.collection('posts').document(timekey).delete();
                  Navigator.push(context,MaterialPageRoute(builder: (context){return new HomePage();}));
                  }, child: new Text("Delete"))
              ],
            );
          }
      );
    }



    return Scaffold(
      appBar: AppBar(
        title:Text(widget.post.data['description']) ,
      ),
      body: Container(
        child: Card(
          child: ListTile(
            title: Text(widget.post.data['description']),

          ),
        ),
      ),
      bottomNavigationBar: new BottomAppBar(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new IconButton(icon: new Icon(Icons.edit),padding: EdgeInsets.only(top: 10,bottom: 10,right: 30,left: 30),iconSize: 30, onPressed: (){
              Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext)=>new editPostPage(
                name: name,email: email,sex: sex,phone: phone,age: age,district: district,index: widget.post,timekey:timekey,
              )));
            }),
            new IconButton(icon: new Icon(Icons.search),padding: EdgeInsets.only(top: 10,bottom: 10,right: 30,left: 30),iconSize: 30, onPressed: null),
            new IconButton(icon: new Icon(Icons.delete_forever),padding: EdgeInsets.only(top: 10,bottom: 10,right: 30,left: 30),iconSize: 30, onPressed: _showDialog,)
          ],
        ),

      ),
    );
  }
}
