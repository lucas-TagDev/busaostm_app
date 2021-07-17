//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:numpakbis/screens/authenticate/sign_up.dart';
import 'package:numpakbis/screens/home_member/home_member.dart';
import 'package:numpakbis/screens/home_member/use_not_login.dart';
import 'package:numpakbis/services/auth.dart';
import 'package:numpakbis/shared/constant.dart';
import 'package:numpakbis/shared/loading_logo.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String email = '';
  String password = '';
  String error = '';

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {

    _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
      currentFocus.unfocus();
      FocusScope.of(context).requestFocus(nextFocus);
    }

    return loading ? LoadingLogo() : Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        //title: Text('ENTRAR',style: TextStyle(color: Colors.lightBlue),),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/numpakbis.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),

                  TextFormField( // email form
                    //decoration: textInputDecoration.copyWith(hintText: 'Seu e-mail',),
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        focusColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        hintText: 'Digite seu e-mail',
                        fillColor: Colors.white, filled: true
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocus,
                    onFieldSubmitted: (term){
                      _fieldFocusChange(context, _emailFocus, _passwordFocus);
                    },
                    validator: (val) => val.isEmpty ? 'Favor informe um e-mail válido' : null,
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField( // pass form
                    //decoration: textInputDecoration.copyWith(hintText: 'Senha', border: ),
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      focusColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      hintText: 'Sua senha',
                      fillColor: Colors.white, filled: true
                    ),
                    textInputAction: TextInputAction.done,
                    focusNode: _passwordFocus,
                    onFieldSubmitted: (value) async{
                      _passwordFocus.unfocus();
                      if (_formKey.currentState.validate()){
                        setState(() => loading = true);
                        dynamic result = await _auth.signInEmailPass(email, password);
                        if (result == null){
                          setState(() {
                            error = 'E-mail ou senha est'
                                'ão inválidos';
                            loading = false;
                          });
                        }
                      }
                    },
                    validator: (val) => val.length < 6 ? 'Favor informe sua senha (min 6 caracteres)' : null,
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                    obscureText: true,

                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 60,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(28),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()){
                          setState(() => loading = true);
                          dynamic result = await _auth.signInEmailPass(email, password);
                          if (result == null){
                            setState(() {
                              error = 'E-mail ou a senha estão incorretos.';
                              loading = false;
                            });
                          }
                        }
                      },
                      color: Colors.deepPurpleAccent,
                      child: Text(
                        'ENTRAR',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      FlatButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserLoginNo()),
                          );
                        },
                        child: Text(
                          'Vou criar depois',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),

                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    error,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 1,
                    ),
                  ),
                  SizedBox(height: 20,),

                ],
              ),
            ),
          ],
        ),

      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
              'Ainda não se registrou?',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white
            ),
          ),
          FlatButton(
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUp()),
              );
            },
            child: Text(
                'Criar uma conta',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),

            ),
          ),
        ],
      ),
    );
  }
}
