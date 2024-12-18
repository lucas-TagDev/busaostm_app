


import 'package:flutter/material.dart';
import 'package:numpakbis/models/send_data.dart';
import 'package:numpakbis/models/user.dart';
import 'package:numpakbis/screens/home_operator/bg_service_operator..dart';
import 'package:numpakbis/screens/home_operator/form_operator.dart';
import 'package:numpakbis/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OperatorWrapper extends StatefulWidget {
  final UserData userData;
  OperatorWrapper({ this.userData });
  @override
  _OperatorWrapperState createState() => _OperatorWrapperState();
}

class _OperatorWrapperState extends State<OperatorWrapper> {


  bool _flag;
  var sendDataInfo2;
  final AuthService _auth = AuthService();


  /// Will get the serviceStarted from shared_preferences
  /// will return false if null
  Future<bool> _getBoolFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final serviceStarted = prefs.getBool('serviceStarted');
    if (serviceStarted == null) {
      return false;
    }
    return serviceStarted;
  }

  Future<void> _setFlag() async {
    bool currentFlag = await _getBoolFromSharedPref();
    setState(() => _flag = currentFlag);
  }

  _decideAppBar(SendDataInfo info){
    return info.flag2Val == false ? AppBar(
      title: Text('MOTORISTA'),
      backgroundColor: Colors.deepPurple,
      elevation: 0,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: FlatButton.icon(
            color: Colors.red,
            icon: Icon(Icons.person, color: Colors.white,),
            label: Text('Sair', style: TextStyle(color: Colors.white),),
            onPressed: (){
              _showConfirm();
            },
          ),
        ),
      ],
    )
        : AppBar(
      title: Text('Enviando dados'),
      backgroundColor: Colors.deepPurple,
      elevation: 0,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setFlag();

  }

  _showConfirm(){
    return showDialog(
      context: context,
      builder: (context)=>AlertDialog(
        content: Text('deseja realmente sair?'),
        actions: <Widget>[
          FlatButton(
            child: Text('NÃO'),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('SIM'),
            onPressed: () async{
              Navigator.pop(context);
              await _auth.signOut();
            },
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {

    var sendDataInfo = Provider.of<SendDataInfo>(context);

    print('Flag2 = ${sendDataInfo.flag2Val}');

    Future<bool> _onBackPressed(){
      return showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          content: Text('Você realmente deseja sair do BusaoSTM?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Não'),
              onPressed: ()=>Navigator.pop(context,false),
            ),
            FlatButton(
              child: Text('Sim'),
              onPressed: (){
                Navigator.pop(context,true);
              },
            ),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _decideAppBar(sendDataInfo),
        body: sendDataInfo.flag2Val == false ? FormOperator(userData: widget.userData,) : BackgroundService(),
      ),
    );
  }
}

