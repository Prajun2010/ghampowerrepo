import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'DetailPage.dart';



class SearchPage extends StatefulWidget {
  @override
  _SearchPage createState() => new _SearchPage();
}

class _SearchPage extends State<SearchPage> {

  List<DocumentSnapshot>_posts=[];
  bool _loadingPosts=true;



  searchByName(String searchField) async{
    print(searchField);
    Query q= Firestore.instance.collection('posts').where('description', isEqualTo: searchField.substring(0, 1).toUpperCase() + searchField.substring(1));
    setState(() {
      _loadingPosts=true;
    });
    QuerySnapshot querySnapshot=await q.getDocuments();
    _posts=querySnapshot.documents;

    setState(() {
      _loadingPosts=false;
    });
    print(_posts);
    return _posts;
  }

  navigateToDetail(DocumentSnapshot post){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(post: post,)));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

        body: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(

              autofocus: true,
              onChanged: (val) {
                searchByName(val);
              },
              decoration: InputDecoration(
                  prefixIcon: IconButton(
                    color: Colors.amber,
                    icon: Icon(Icons.arrow_back),
                    iconSize: 20.0,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  contentPadding: EdgeInsets.only(left: 25.0),
                  hintText: 'Search by name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0))),
            ),
          ),
          SizedBox(height: 10.0),
          _loadingPosts==true?Container(
            child: Center(
              child: Image.asset("assets/loading1.gif",height: 150,width: 150,),
            ),
          ):Container(
            child: _posts.length==0?Center(
              child: Text("No Data to show with name:"),
            ):ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _posts.length,
                itemBuilder: (BuildContext ctx,int index){
                  return Card(child:ListTile(

                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(_posts[index].data['image']),radius: 30,
                    ),

                    title: Text(_posts[index].data['description'],style: TextStyle(fontSize: 22,color: Colors.amber,),),
                    subtitle: Text(_posts[index].data['date']+"\n"+_posts[index].data['time'],style: TextStyle(fontSize: 15),),
                    isThreeLine: true,
                    trailing: Icon(Icons.keyboard_arrow_right),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 5.0),
                    onTap: (){
                      navigateToDetail(_posts[index]);
                    },

                    onLongPress: (){
                      // do something else
                    },
                  )
                  );
                }),


          ),
        ]));
  }
}
