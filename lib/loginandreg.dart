import 'package:flutter/material.dart';
import 'Authentication.dart';
import 'package:flutter_app/DialogBox.dart';
import 'package:firebase_auth/firebase_auth.dart';



class loginandreg extends StatefulWidget
{

  loginandreg({
    this.auth,
    this.onSignedIn,

});
  final AuthImplementation auth;
  final VoidCallback onSignedIn;
  State<StatefulWidget> createState(){
    return _LoginRegisterState();
  }

}

enum FormType{
  login,register
}

class _LoginRegisterState extends State<loginandreg>{
  DialogBox dialogBox=new DialogBox();
  final formKey = new GlobalKey<FormState>();
  FormType _formType =FormType.login;
  String _email="";
  String _password="";

  //methods
  bool validateAndSave(){
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    else{
      return false;
    }
  }

  void validateAndSubmit() async{
    if(validateAndSave()){
      try{
        if(_formType==FormType.login){
          String userId = await widget.auth.signIn(_email, _password);
          //dialogBox.information(context, "Congratulations!","you have been signed in");
          print("login userId="+userId);
          print("login email="+_email);

        }
        else{
          String userId = await widget.auth.signUp(_email, _password);
          //dialogBox.information(context, "Congratulations!","you have been registered");
          print("Register userId="+userId);
          print("Register email="+_email);

        }
        widget.onSignedIn();
      }
      catch(e){
        dialogBox.information(context, "Error!!! ", "Could not sign in. :(");
        print("Error="+e.toString());
      }
    }
  }


  void moveToRegister(){
    formKey.currentState.reset();

    setState(() {
      _formType=FormType.register;
    });
  }

  void moveToLogin(){
    formKey.currentState.reset();

    setState(() {
      _formType=FormType.login;
    });
  }



  //Design
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("My app login"),
      ),
        resizeToAvoidBottomPadding: false,
        body: new Container(
        margin: EdgeInsets.all(15.0),
        child: new Form(

          key: formKey,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: createInputs() + createButtons(),
          ),
        ),
      ),
    );
  }


  List<Widget>createInputs(){
    return
      [
        SizedBox(height: 10.0,),
        logo(),
        SizedBox(height: 20.0,),

        new TextFormField(
          decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Email'),
          style: new TextStyle(fontSize: 25, color: Colors.amber,),
          validator: (value){
            return value.isEmpty ? 'Email is required.' : null;
          },
          onSaved: (value){
            return _email = value;
          },
        ),
        SizedBox(height: 10.0,),
        new TextFormField(
          decoration: new InputDecoration(border: OutlineInputBorder(),labelText: 'Password'),
          style: new TextStyle(fontSize: 25, color: Colors.amber,),
          obscureText: true,
          validator: (value){
            return value.isEmpty ? 'Password is required.' : null;
          },
          onSaved: (value){
            return _password = value;
          },
        ),
        SizedBox(height: 20.0,),
      ];
  }

  Widget logo(){
    return new Hero(
      tag: 'hero',
      child: new CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 110.0,
        child: Image.asset('assets/logo.png'),
      ),
    );
  }



  List<Widget>createButtons(){
    if(_formType == FormType.login){
      return
        [
          new RaisedButton(
            child: new Text("Login",style: new TextStyle(fontSize: 20.0)),
            textColor: Colors.white,
            color: Colors.green,
            onPressed: validateAndSubmit,
          ),

          new FlatButton(
            child: new Text("Create account here",style: new TextStyle(fontSize: 14.0)),
            textColor: Colors.black,
            onPressed: moveToRegister,

          )
        ];
    }
    else{
      return
        [
          new RaisedButton(
            child: new Text("Register",style: new TextStyle(fontSize: 20.0)),
            textColor: Colors.white,
            color: Colors.green,
            onPressed: validateAndSubmit,
          ),

          new FlatButton(
            child: new Text("Have an Account? Login here!",style: new TextStyle(fontSize: 14.0)),
            textColor: Colors.black,
            onPressed: moveToLogin,

          )
        ];
    }
  }
}