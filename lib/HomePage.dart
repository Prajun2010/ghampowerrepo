import 'package:flutter/material.dart';
import 'package:flutter_app/search.dart';
import 'Authentication.dart';
import 'NewPost.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DetailPage.dart';
import 'package:firebase_auth/firebase_auth.dart';



class HomePage extends StatefulWidget{
  HomePage({

   this.auth,
    this.onSignedOut,
});
  final AuthImplementation auth;
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() {

    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage>{

  Firestore _firestore=Firestore.instance;
  List<DocumentSnapshot>_posts=[];
  bool _loadingPosts=true;
  String _email;
  int _perPage=10;
  DocumentSnapshot _lastDocument;
  ScrollController _scrollController=ScrollController();
  bool _gettingMorePosts=false;
  bool _morePostsAvailable=true;






  _getPosts()async{
    Query q=_firestore.collection("posts").orderBy("timestamp",descending: true).limit(_perPage);


    setState(() {
      _loadingPosts=true;
    });

    QuerySnapshot querySnapshot=await q.getDocuments();
    _posts=querySnapshot.documents;
    _lastDocument = querySnapshot.documents[querySnapshot.documents.length-1];
    setState(() {
      _loadingPosts=false;
    });
  }



  _getMorePosts() async{
    print("_getMoreProducts called");

    if(_morePostsAvailable==false){
      print("No more posts");
      return;
    }
    if(_gettingMorePosts==true){
      return;
    }

    _gettingMorePosts=true;


    Query q=_firestore.collection("posts").orderBy("timestamp",descending: true).startAfter([_lastDocument.data['timestamp']]).limit(_perPage);

    QuerySnapshot querySnapshot=await q.getDocuments();
    if(querySnapshot.documents.length<_perPage){
      _morePostsAvailable=false;
    }


    _lastDocument = querySnapshot.documents[querySnapshot.documents.length-1];
    _posts.addAll(querySnapshot.documents);

    setState(() {
      _gettingMorePosts=false;
    });
  }



  void _logoutUser() async{
    try{
      await widget.auth.signOut();
      widget.onSignedOut();
  }
  catch(e){
    print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _getPosts();
    _scrollController.addListener((){
      double maxScroll=_scrollController.position.maxScrollExtent;
      double currentScroll=_scrollController.position.pixels;
      double delta=MediaQuery.of(context).size.height*0.25;
      if(maxScroll-currentScroll<=delta){
        _getMorePosts();
      }
    });
  }



  navigateToDetail(DocumentSnapshot post){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(post: post,)));
  }
  navigateToSearch(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchPage()));
  }

  Future getemail() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    _email=user.email;
    return this._email;

  }

  Future<void> _refreshPosts() async
  {
    print('refreshing posts');
    _getPosts();
  }




  _searchbar(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(hintText: "Search..."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    getemail();

    return Scaffold(
      appBar: new AppBar(
        title: new Text("Home"),
        centerTitle: true,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.search),
            iconSize: 40,
            color: Colors.white,
            onPressed: (){
              // ignore: unnecessary_statements
              navigateToSearch();
            },
          ),
        ],
      ),
      drawer: Drawer(

        child: ListView(
          children: <Widget>[

            new SizedBox(
              height:240,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[
                    Colors.deepOrange,
                    Colors.yellowAccent,
                  ])
                ),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Material(
//                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          elevation: 10.0,
                          child: Padding(padding: EdgeInsets.all(8.0),
                            child: Image.asset('assets/logog.png',width: 100,height: 100,),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Gham Power",style: TextStyle(color: Colors.white,fontSize: 25.0),
                          ),

                        ),
                        Padding(

                          padding: const EdgeInsets.all(8.0),
                          child: _email==null?Text("loading.",style: TextStyle(color: Colors.white,fontSize: 15.0)):Text(_email,style: TextStyle(color: Colors.white,fontSize: 15.0),
                          ),
                        )
                      ],
                    ),
                  )),
            ),
            customListTile(Icons.info,"About Us",(){}),
            customListTile(Icons.wb_incandescent,"FAQ",(){}),
            customListTile(Icons.settings,"Settings",(){}),
            customListTile(Icons.lock,"Log Out",(){_logoutUser();}),
          ],
          
        )

      ),
      body: _loadingPosts==true?Container(
        child: Center(
          child: Image.asset("assets/loading1.gif",height: 150,width: 150,),
        ),
      ):Container(
        child: _posts.length==0?Center(
          child: Text("No Posts to show"),
        ):RefreshIndicator(child: ListView.builder(
            controller: _scrollController,
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
          onRefresh: _refreshPosts,
        ),
      ),


      floatingActionButton: new FloatingActionButton(

        child: Icon(Icons.add),
        backgroundColor: Colors.amber,
          onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context){
                  return new NewPostPage();
                })
            );
          }

      ),
    );
  }
}





class customListTile extends StatelessWidget{

  IconData icon;
  String text;
  Function onTap;
  customListTile(this.icon,this.text,this.onTap);


  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade700))
        ),
        child: InkWell(
          splashColor:Colors.amberAccent ,
          onTap: onTap,
          child: Container(
            height: 55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(icon),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(text,style: TextStyle(
                        fontSize: 16.0,
                      ),),
                    ),
                  ],
                ),
                Icon(Icons.arrow_right)
              ],
            ),
          ),
        ),
      ),
    );
  }


}
