import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:intl/intl.dart";
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class editPostPage extends StatefulWidget{

  editPostPage({
    this.name,this.age,this.email,this.sex,this.phone,this.district,this.index,this.timekey
});

  final index;
  final String name;
  final String timekey;
  final String age;
  final String email;
  final String sex;
  final String phone;
  final String district;

  State<StatefulWidget> createState(){
    return _editPostPageState();
  }
}

class _editPostPageState extends State<editPostPage>{

  TextEditingController editname ;
  TextEditingController editemail;
  TextEditingController editphone;
  TextEditingController editage;
  TextEditingController editsex;
  TextEditingController editdistrict;

  var _formKey = GlobalKey<FormState>();

  File sampleImage;
  String _myname;
  String _myage;
  String _mysex;
  String _myphone;
  String _myemail;
  String _mydistrict;


  String path;
  String url;
  String url1;
  bool upload=false;
  final formKey = new GlobalKey<FormState>();


  Future getImageCamera(BuildContext context) async{
    File tempImage = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 500,maxHeight: 650);
    setState(() {
      path=tempImage.path;
      sampleImage=tempImage;
      upload=true;
    });
    Navigator.of(context).pop();
  }
  Future getImageGallery(BuildContext context) async{
    File tempImage = await ImagePicker.pickImage(source: ImageSource.gallery,maxWidth: 500,maxHeight: 650);

    setState(() {
      path=tempImage.path;
      sampleImage=tempImage;
      upload=true;
    });
    Navigator.of(context).pop();
  }
  Future getImageAvatar(BuildContext context) async{

    setState(() {
      sampleImage=null;
      upload=true;
    });
    Navigator.of(context).pop();
  }


  bool validateAndSave(){
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }else{return false;}
  }


  uploadStatusImage() async{
    print("called once");
    if(validateAndSave()){
      final StorageReference postImageRef= FirebaseStorage.instance.ref().child("Post Images");

      var timeKey=new DateTime.now();
      if(upload==true) {
        final StorageUploadTask uploadTask = postImageRef.child(
            timeKey.toString() + ".jpg").putFile(sampleImage);


        // ignore: non_constant_identifier_names
        var ImageUrl = await(await uploadTask.onComplete).ref
            .getDownloadURL();

        this.url = ImageUrl.toString();

        print("Image Url= " + url);


        var dbTimekey = new DateTime.now();
        var formatDate = new DateFormat('MM d, yyyy');
        var formatTime = new DateFormat('EEEE, hh:mm aaa');

        String date = formatDate.format(dbTimekey);
        String time = formatTime.format(dbTimekey);


        saveTodatabase(url);
      }
      else{
        this.url = "https://firebasestorage.googleapis.com/v0/b/demoapp-9a150.appspot.com/o/Post%20Images%2Favatar.png?alt=media&token=e4b06f7f-743a-400e-a459-1011235cd5bf";
        saveTodatabase(url);
      }
    }
  }



  saveTodatabase(url) async {
    print("Error here");
    final databaseReference = Firestore.instance;

    var data = {
      "image":url,
      "description": _myname,
      "email": _myemail,
      "phone": _myphone,
      "sex": _mysex,
      "district": _mydistrict,
      "age": _myage,

    };
    print(widget.index);

    await databaseReference.collection("posts")
        .document(widget.timekey)
        .updateData(data);

    goToHomePage();

    //ref.child("Posts").push().set(data);
  }


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

  @override






  void initState(){
    super.initState();
    _myname=widget.name;
    _mysex=widget.sex;
    _mydistrict=widget.district;
    _myage=widget.age;
    _myemail=widget.email;
    _myphone=widget.phone;



    editname = new TextEditingController(text: widget.name);
    editemail =new TextEditingController(text: widget.email);
    editphone=new TextEditingController(text: widget.phone);
    editage =new TextEditingController(text: widget.age);
    editsex =new TextEditingController(text: widget.sex);
    editdistrict =new TextEditingController(text: widget.district);
  }

  Widget build(BuildContext context) {



    return new Scaffold(

      appBar: new AppBar(
        title: new Text("Edit data of "+widget.name),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          child: Form(
            key: formKey,
            child: Container(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 0,bottom: 10,right: 20,left: 20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 0.0,),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.center,

                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Color(0xff476cfb),
                          child: ClipOval(
                            child: new SizedBox(
                              width: 180.0,
                              height: 180.0,
                              child: (sampleImage!=null)?Image.file(sampleImage, fit: BoxFit.fill,):CircleAvatar(backgroundImage: AssetImage("assets/avatar.png"),backgroundColor: Colors.amber, ),

                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 0,left: 0),
                      child: IconButton(

                        icon: Icon(
                          Icons.add_a_photo,
                          size: 30.0,

                        ),
                        onPressed: (){
                          _onButtonPressed();
                        },

                      ),),
                    const SizedBox(height: 10,),
                    TextFormField(
                        controller: editname,
                        decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Full Name',
                            prefixIcon: Icon(Icons.perm_identity)
                        ),
                        style: new TextStyle(fontSize: 14, color: Colors.amber,),

                        validator: (value){
                          return value.isEmpty ? 'Full Name is required' : null;
                        },
                        onSaved: (value){
                          setState(() {
                            _myname=value;
                          });

                        }) ,
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: editphone,
                        keyboardType: TextInputType.numberWithOptions(),
                        decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Phone',
                            prefixIcon: Icon(Icons.phone)
                        ),
                        style: new TextStyle(fontSize: 14, color: Colors.amber,),

                        validator: (value){
                          return value.isEmpty ? 'Phone is required' : null;
                        },
                        onSaved: (value){
                          return _myphone=value;
                        }) ,
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: editemail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Email',
                            prefixIcon: Icon(Icons.email)
                        ),
                        style: new TextStyle(fontSize: 14, color: Colors.amber,),

                        validator: (value){
                          return value.isEmpty ? 'Email is required' : null;
                        },
                        onSaved: (value){
                          return _myemail=value;
                        }) ,
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: editage,
                        decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Age',
                            prefixIcon: Icon(Icons.cake)
                        ),
                        style: new TextStyle(fontSize: 14, color: Colors.amber,),

                        validator: (value){
                          return value.isEmpty ? 'Age is required' : null;
                        },
                        onSaved: (value){
                          return _myage=value;
                        }) ,
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: editsex,
                        decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Sex',
                            prefixIcon: Icon(Icons.wc)
                        ),
                        style: new TextStyle(fontSize: 14, color: Colors.amber,),

                        validator: (value){
                          return value.isEmpty ? 'Sex is required' : null;
                        },
                        onSaved: (value){
                          return _mysex=value;
                        }) ,
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: editdistrict,
                        decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'District',
                            prefixIcon: Icon(Icons.map)
                        ),
                        style: new TextStyle(fontSize: 14, color: Colors.amber,),

                        validator: (value){
                          return value.isEmpty ? 'District is required' : null;
                        },
                        onSaved: (value){
                          return _mydistrict=value;
                        }),
                    Padding(
                      padding: EdgeInsets.only(top:5,right: 20,left: 20),
                      child: Column(
                        children: <Widget>[
                          RaisedButton(
                            elevation: 10.0,
                            child: Text("Add new Post"),
                            textColor: Colors.white,
                            color: Colors.amber,

                            onPressed: (){
                              print("called");
                              uploadStatusImage();

                            },
                          ),

                        ],
                      ),

                    ),




                  ],
                ),
              ),
            ),
          ),
        ),
      ),
//      body: Form(
//        key: _formKey,
//        child: Padding(
//          padding: EdgeInsets.all(10),
//         child: new ListView(
//          children: <Widget>[
//            Padding(
//              padding: const EdgeInsets.only(top: 10),
//              child: Align(
//                alignment: Alignment.center,
//
//                child: CircleAvatar(
//                  radius: 100,
//                  backgroundColor: Color(0xff476cfb),
//                  child: ClipOval(
//                    child: new SizedBox(
//                      width: 180.0,
//                      height: 180.0,
//                      child: (sampleImage!=null)?Image.file(sampleImage, fit: BoxFit.fill,):CircleAvatar(backgroundImage: AssetImage("assets/avatar.png"),backgroundColor: Colors.amber, ),
//
//                    ),
//                  ),
//                ),
//              ),
//            ),
//            Padding(
//              padding: EdgeInsets.only(top: 0,left: 0),
//              child: IconButton(
//                icon: Icon(
//                  Icons.add_a_photo,
//                  size: 30.0,
//                ),
//                onPressed: (){
//                  _onButtonPressed();
//                },
//
//              ),),
//
//            Padding(
//              padding: EdgeInsets.only(top: 8, bottom: 8,left: 15,right: 15),
//              child: TextFormField(
//                decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Full Name',
//
//                ),
//                style: new TextStyle(fontSize: 14, color: Colors.amber,),
//
//                validator: (value){
//                  return value.isEmpty ? 'Full Name is required' : null;
//                },
//                onSaved: (value){
//                  return _myValue=value;
//                } ,
//              ),
//            ),
//            Padding(
//              padding: EdgeInsets.only(top: 8, bottom: 8,left: 15,right: 15),
//              child: TextFormField(
//                decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Full Name',
//
//                ),
//                style: new TextStyle(fontSize: 14, color: Colors.amber,),
//
//                validator: (value){
//                  return value.isEmpty ? 'Full Name is required' : null;
//                },
//                onSaved: (value){
//                  return _myValue=value;
//                } ,
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: TextFormField(
//                decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Full Name',
//
//                ),
//                style: new TextStyle(fontSize: 14, color: Colors.amber,),
//
//                validator: (value){
//                  return value.isEmpty ? 'Full Name is required' : null;
//                },
//                onSaved: (value){
//                  return _myValue=value;
//                } ,
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: TextFormField(
//                decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Full Name',
//
//                ),
//                style: new TextStyle(fontSize: 14, color: Colors.amber,),
//
//                validator: (value){
//                  return value.isEmpty ? 'Full Name is required' : null;
//                },
//                onSaved: (value){
//                  return _myValue=value;
//                } ,
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: TextFormField(
//
//                decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Email',
//
//                ),
//                style: new TextStyle(fontSize: 14, color: Colors.amber,),
//                keyboardType: TextInputType.emailAddress,
//                validator: (email){
//                  return email.isEmpty ? 'Email is required' : null;
//                },
//                onSaved: (email){
//                  return email=email;
//                } ,
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: TextFormField(
//
//                decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Phone number'),
//                style: new TextStyle(fontSize: 14, color: Colors.amber,),
//                keyboardType: TextInputType.phone,
//                inputFormatters: [
//                  WhitelistingTextInputFormatter.digitsOnly,
//                ],
//                validator: (phone){
//                  return phone.isEmpty ? 'Phone Number is required' : null;
//                },
//                onSaved: (phone){
//                  return phone=phone;
//                } ,
//              ),
//            ),
//            Padding(
//
//              padding: const EdgeInsets.all(8.0),
//              child: TextFormField(
//
//                decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Email'),
//                style: new TextStyle(fontSize: 14, color: Colors.amber,),
//                validator: (value){
//                  return value.isEmpty ? 'Description is required' : null;
//                },
//                onSaved: (value){
//                  return _myValue=value;
//                } ,
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: new TextFormField(
//
//                decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Email'),
//                style: new TextStyle(fontSize: 14, color: Colors.amber,),
//                validator: (value){
//                  return value.isEmpty ? 'Description is required' : null;
//                },
//                onSaved: (value){
//                  return _myValue=value;
//                } ,
//              ),
//            ),
//            Padding(
//
//              padding: EdgeInsets.only(top:5,right: 20,left: 20),
//
//
//              child: Column(
//                children: <Widget>[
//
//
//                  RaisedButton(
//                    elevation: 10.0,
//                    child: Text("Add new Post"),
//                    textColor: Colors.white,
//                    color: Colors.amber,
//
//                    onPressed: uploadStatusImage,
//                  ),
//
//                ],
//              ),
//
//            ),
//          ],
//
//        ),
//
//      )),


      floatingActionButton: new FloatingActionButton(
        onPressed: null,
        tooltip: 'Add image',
        child: new Icon(Icons.keyboard_arrow_right),
      ),
    );
  }
  void _onButtonPressed(){
    showModalBottomSheet(context: context, builder: (context){
      return Column(
        children: <Widget>[
          ListTile(

            title: Text("Please select an option",style: TextStyle(fontSize: 25,color: Colors.amber),textAlign: TextAlign.center,),
            onTap: (){

            },
          ),
          Card(child: ListTile(
            leading: Icon(Icons.camera),
            title: Text("Select Image from Camera",style: TextStyle(fontSize: 20),),
            subtitle: Text('Note: The app will need access to your camera',style: TextStyle(fontSize: 10),),
            trailing: Icon(Icons.arrow_right),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 5.0),
            onTap: (){
              getImageCamera(context);
            },
          )),
          Card(child:ListTile(
            leading: Icon(Icons.add_photo_alternate),
            title: Text("Select Image from Gallery",style: TextStyle(fontSize: 20),),
            subtitle: Text('Note: The app will need access to your Gallery photos',style: TextStyle(fontSize: 10),),
            trailing: Icon(Icons.arrow_right),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 5.0),
            onTap: (){

              getImageGallery(context);
            },
          )),
          Card(child:ListTile(
            leading: CircleAvatar(backgroundImage: AssetImage("assets/avatar.png"),backgroundColor: Colors.amber,) ,
            title: Text("Use the default avatar",style: TextStyle(fontSize: 20),),
            subtitle: Text('Note: you will reset the image to its original avatar',style: TextStyle(fontSize: 10),),
            trailing: Icon(Icons.arrow_right),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 5.0),
            onTap: (){
              getImageAvatar(context);
            },
          )),
        ],
      );
    });
  }
}