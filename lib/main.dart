import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_search_pixabay/image_result_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_search_pixabay/connection_check.dart';
import 'globals.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart';
void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FirstPage(title:"title"),
  ));
}

class FirstPage extends StatefulWidget {
  FirstPage({Key? key, required this.title}) : super(key: key);
  final String title;


  @override
  _FirstPageState createState() => _FirstPageState();
}
class _FirstPageState extends State<FirstPage>{
  var category_name = new TextEditingController();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  @override
  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
//checking the internet connectivity use the connectivity_plus pacakage
  Future<void> initConnectivity() async {
    late ConnectivityResult result;

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Material(
        color: Colors.white,
        child: Center(
          widthFactor: screenSize.width,
          heightFactor: screenSize.height,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 100.0),
              ),
              Center(
                child: Text("Pic Finder",style: TextStyle(fontFamily: 'Pacifico',
                fontSize: 30.0,
                color: Colors.lightGreen,
                fontWeight: FontWeight.normal),),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
              ),
              new Image.asset(
                'assets/images/gallery-icon.png',
                width: 200.0,
                height: 200.0,
              ),

              new ListTile(
                title: new TextFormField(
                  controller: category_name,
                  decoration: new InputDecoration(
                    labelText: "Enter a category",
                    hintText: 'eg: flower, nature, animals...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0)),
                    contentPadding:
                        const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
              ),
              new ListTile(
                title: new Material(
                  color: Colors.lightGreen,
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(25.0),

                  child: new MaterialButton(
                    height: 47.5,
                    onPressed: () {
                     if(_connectionStatus.toString()=="ConnectivityResult.none"){
                       Navigator.of(context).push(new MaterialPageRoute(builder: (context){
                         return new connection_not_available();
                       }));
               }
        else{              Navigator.of(context).push(new MaterialPageRoute(builder: (context){
                        return new image_result_view(keyWord: category_name.text,);
                      }));
                    //category_name.text="";
                    }
  },
                    child: Text('Search',
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold,
                        color: Colors.white)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
class connection_not_available extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          title: Text("PicFinder",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
      body: Center(
          child: Text("Please check your internet connection!",style: TextStyle(color: Colors.lightGreen,fontSize:20.0)
          )
      )
    );
  }

}
