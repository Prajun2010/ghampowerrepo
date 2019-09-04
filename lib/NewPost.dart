import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:intl/intl.dart";
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'HomePage.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class NewPostPage extends StatefulWidget{
  State<StatefulWidget> createState(){
    return _NewPostPageState();
  }
}

class _NewPostPageState extends State<NewPostPage>{



  File sampleImage;
  String _myname;
  String _myage;
  String _mysex;
  String _myphone;
  String _myemail;
  String _mydistrict;

  String name;
  String path;
  String url;
  String url1;
  bool upload=false;
  final formKey = new GlobalKey<FormState>();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

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

    final databaseReference = Firestore.instance;
    var dbTimekey=new DateTime.now();
    var formatDate=new DateFormat('MM d, yyyy');
    var formatTime=new DateFormat('EEEE, hh:mm aaa');

    String date=formatDate.format(dbTimekey);
    String time=formatTime.format(dbTimekey);

    var data = {
      "image":url,
      "description": _myname,
      "email": _myemail,
      "phone": _myphone,
      "sex": _mysex,
      "district": _mydistrict,
      "age": _myage,
      "date": date,
      "time": time,
      "timekey": dbTimekey.toString(),
      "timestamp":FieldValue.serverTimestamp(),
    };

    await databaseReference.collection("posts")
        .document(dbTimekey.toString())
        .setData(data);


    Navigator.pop(context);
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

  checkconnection() async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // ignore: unnecessary_statements
        uploadStatusImage();
      }
    } on SocketException catch (_) {
      print('not connected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

      appBar: new AppBar(
        title: new Text("Add data"),
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
                      Column(
                        children: <Widget>[
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


                            ),

                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      FormBuilder(
                        key: _fbKey,
                        initialValue: {

                        },

                        child: Column(
                          children: <Widget>[
                            FormBuilderDateTimePicker(
                              attribute: "date",
                              inputType: InputType.date,
                              format: DateFormat("yyyy-MM-dd"),
                              decoration:
                              InputDecoration(labelText: "Appointment Time"),
                            ),
                            const SizedBox(height: 10,),
                            TextFormField(
                                decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Full Name',
                                    prefixIcon: Icon(Icons.perm_identity)
                                ),
                                style: new TextStyle(fontSize: 14, color: Colors.amber,),

                                validator: (value){
                                  return value.isEmpty ? 'Full Name is required' : null;
                                },
                                onSaved: (value){
                                  return _myname=value;
                                }) ,
                            const SizedBox(height: 10,),

                            FormBuilderSegmentedControl(
                              decoration:
                              InputDecoration(labelText: "Movie Rating (Archer)"),
                              attribute: "movie_rating",
                              options: List.generate(5, (i) => i + 1)
                                  .map(
                                      (value) => FormBuilderFieldOption(value: value))
                                  .toList(),
                            ),
                            const SizedBox(height: 10,),
                            TextFormField(
                                decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Full Name',
                                    prefixIcon: Icon(Icons.perm_identity)
                                ),
                                style: new TextStyle(fontSize: 14, color: Colors.amber,),

                                validator: (value){
                                  return value.isEmpty ? 'Full Name is required' : null;
                                },
                                onSaved: (value){
                                  return _myname=value;
                                }) ,
                            const SizedBox(height: 10,),

                            TextFormField(
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

                          ],
                        ),
                      ),

                    Padding(
                      padding: EdgeInsets.only(top:5,right: 20,left: 20),
                      child: Column(
                        children: <Widget>[
                          RaisedButton(
                            elevation: 10.0,
                            child: Text("Add new Post"),
                            textColor: Colors.white,
                            color: Colors.amber,

                            onPressed: checkconnection,
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