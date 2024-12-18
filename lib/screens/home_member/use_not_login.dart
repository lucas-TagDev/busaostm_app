
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:numpakbis/models/bus.dart';
import 'package:numpakbis/models/bus_list.dart';
import 'package:numpakbis/models/distance.dart';
import 'package:numpakbis/models/user.dart';
import 'package:numpakbis/screens/home_member/rute.dart';
import 'package:numpakbis/screens/home_member/bus_stops.dart';
import 'package:numpakbis/screens/home_member/home_page.dart';
import 'package:numpakbis/screens/home_member/profile.dart';
import 'package:numpakbis/services/auth.dart';
import 'package:provider/provider.dart';


class UserLoginNo extends StatefulWidget {
  final UserData userData;
  UserLoginNo({ this.userData });
  @override
  _UserNotLogin createState() => _UserNotLogin();
}

class _UserNotLogin extends State<UserLoginNo> {

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  int _selectedTabIndex = 0;
  var busData;
  //API DO GOOGLE MAPS AQUI
  final _API = "AIzaSyAQxLbEz0vImixlpoxD9QopDTdtWhk3qmU";
  SocketIO socketIO;
  Dio dio = new Dio();
  DistanceMatrix _distanceMatrix;
  String _infoTracking;

  Future<void> _onCalculateDistance(lat1,lon1,lat2,lon2) async {
    try{
      Response response=await dio.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$lat1,$lon1&destinations=$lat2,$lon2&key=$_API");
      _distanceMatrix = new DistanceMatrix.fromJson(response.data);
      print(_distanceMatrix.elements[0].distance.text + ' - ' + _distanceMatrix.elements[0].distance.value.toString());
      print(_distanceMatrix.elements[0].duration.text + ' - ' + _distanceMatrix.elements[0].duration.value.toString());
      setState(() {
        _infoTracking = '${_distanceMatrix.elements[0].duration.text} (${(_distanceMatrix.elements[0].distance.value/1000).toStringAsFixed(1)} km)';
      });
    }catch(e){
      print(e);
    }
  }

  Future _onNavBarTapped(int index) async{
    return await setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    new Future.delayed(Duration.zero,() {
      setState(() {
        busData = Provider.of<BusLocInfo>(context, listen: false);
      });
    });

    //CONEXAO COM SOCKET / SERVIDOR HEROKU
    socketIO = SocketIOManager().createSocketIO(
      'https://numpakbis-server.herokuapp.com/',
      '/',
    );
    //Call init before doing anything with socket
    socketIO.init();
    //Subscribe to an event to listen to
    socketIO.subscribe('receive_message', (jsonData) async{
      print('SOCKET DITERIMA');
      //Convert the JSON data received into a Map
      if(jsonData != null){
        ReceiveMessage data = new ReceiveMessage.fromJson(jsonData);
        await _onCalculateDistance(double.parse(data.message.latitude),
            double.parse(data.message.longitude),
            double.parse(data.message.halteLat),
            double.parse(data.message.halteLong)
        );
        Bus tempBus = new Bus(
          name: data.message.nameBus,
          halteName: data.message.halteName,
          halteKey: data.message.halteKey,
          latitude: data.message.latitude,
          longitude: data.message.longitude,
          rute: data.message.ruteName,
          halteLat: data.message.halteLat,
          halteLong: data.message.halteLong,
          distance: _infoTracking,
        );
        if(data.message.status == "active"){
          if(busData.buses == null || busData.buses.isEmpty){
            busData.add(tempBus);
          }else{
            bool isContains = false;
            for(var i = 0; i<busData.buses.length;i++){
              if(busData.buses[i].name.toLowerCase() == tempBus.name.toLowerCase()){
                isContains = true;
                busData.define(tempBus,i);
              }
            }
            if(isContains == false){
              busData.add(tempBus);
            }
          }
        }else{
          if(busData.buses.isNotEmpty){
            for(var i = 0; i<busData.buses.length;i++){
              if(busData.buses[i].name.toLowerCase() == tempBus.name.toLowerCase()){
                busData.removeAt(i);
              }
            }
          }
        }
      }
    });
    //Connect to the socket
    socketIO.connect();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    if(socketIO != null){
      socketIO.disconnect();
      socketIO.destroy();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final _listPage = <Widget>[
      HomePage(),
      BusStop(),
      Rute(),
      Profile(userData: widget.userData),
    ];

    final _pageTitle = <String>[
      'BusaoSTM',
      'Encontre sua parada',
      'Rotas de Ônibus',
      'Perfil',
    ];

    final _bottomNavBarItem = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        title: Text('Início'),
        icon: Icon(Icons.home),
      ),
      BottomNavigationBarItem(
        title: Text('Paradas'),
        icon: Icon(Icons.pin_drop),
      ),
      BottomNavigationBarItem(
        title: Text('Rotas'),
        icon: Icon(Icons.directions_bus),
      )
    ];

    final _bottomNavBar = BottomNavigationBar(
      items: _bottomNavBarItem,
      currentIndex: _selectedTabIndex,
      selectedItemColor: Colors.deepPurpleAccent,
      unselectedItemColor: Colors.grey,
      elevation: 20,
      showUnselectedLabels: true,
      onTap: _onNavBarTapped,
    );

    Future<bool> _onBackPressed(){
      return showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          content: Text('Tem certeza que deseja sair do BusaoSTM ?'),
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
        backgroundColor: Colors.grey[100],
        key: _scaffoldKey,
        appBar: AppBar(
          title: new Center(child: Text(_pageTitle[_selectedTabIndex], textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),
          backgroundColor: Colors.deepPurple,
          elevation: 1,
          /*actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person, color: Colors.redAccent,),
              label: Text('Sign Out', style: TextStyle(color: Colors.redAccent),),
              onPressed: () async {
                 await _auth.signOut();
              },
            ),
          ],*/
        ),
        /*body: Center(
          child: _listPage[_selectedTabIndex],
        ),
        bottomNavigationBar: _bottomNavBar,*/
        body: Container(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Expanded(child: _listPage[_selectedTabIndex]),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0)),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0.0, 1.00), //(x,y)
                          blurRadius: 4.00,
                          color: Colors.grey,
                          spreadRadius: 1.00),
                    ],
                  ),
                  height: 70,
                  child: ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0)),
                      child: Container(
                        child: _bottomNavBar
                      )),
                )
              ],
            )),
      ),
    );
  }
}