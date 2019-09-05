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
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

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
  final background=Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/back.png'),
        fit: BoxFit.cover,
      ),
    ),

  );
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
        dialogBox.information(context, "Error!", "Signin failed");
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
      resizeToAvoidBottomPadding: true,

      body: Padding(

        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 80.0, bottom:16.0),
        child: new SingleChildScrollView(
            reverse: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom:16.0),
              child: new Form(

                key: formKey,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: createInputs() + createButtons(),
                ),
              ),
            )
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
          obscureText: false,
          style: style,
          decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          prefixIcon: Icon(Icons.person),
           border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12.0))),
          validator: (value){
            return value.isEmpty ? 'Email is required.' : null;
          },
          onSaved: (value){
            return _email = value;
          },
        ),



        SizedBox(height: 20.0,),
        new TextFormField(
          obscureText: true,
          style: style,
          decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",

          prefixIcon: Icon(Icons.lock),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12.0))),
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
          Padding(
            padding: const EdgeInsets.all(0),
            child: new Material(

              elevation: 5.0,
              borderRadius: BorderRadius.circular(12.0),
              color: Color.fromRGBO(240, 151, 38, 1),

              child: MaterialButton(
                minWidth: 250,

                padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                onPressed: validateAndSubmit,
                child: Text("Login",
                    textAlign: TextAlign.center,
                    style: style.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          new FlatButton(
            child: new Text("Forgot Password?",style: new TextStyle(fontSize: 14.0)),
            textColor: Colors.redAccent,
            onPressed: moveToRegister,

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
          new Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(12.0),
            color: Color.fromRGBO(240, 151, 38, 1),

            child: MaterialButton(
              minWidth:250,
              padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              onPressed: validateAndSubmit,
              child: Text("Register",
                  textAlign: TextAlign.center,
                  style: style.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
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


