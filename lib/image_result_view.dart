import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_search_pixabay/globals.dart';
import 'package:image_search_pixabay/favourite_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

class image_result_view extends StatefulWidget {
  var ApiKey="25971755-20594a0ab785428e571aedb46";
  final String keyWord;

image_result_view({required this.keyWord});

  @override
  _image_resultState createState() => _image_resultState();
}

class _image_resultState extends State<image_result_view> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Color _iconColor = Colors.white;
  var imagesData;
  int currentPage = 1;
  int size = 10;
  int totalPages = 1;
  String photo = "photo";

  ScrollController _scrollController = ScrollController();
  List<dynamic> hits = [];

  @override
  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    getData(widget.keyWord);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent)
        if (currentPage < totalPages) {
          ++currentPage;
          getData(widget.keyWord);
        }
    });
  }

  @override
  void dispose() {

    _connectivitySubscription.cancel();
    _scrollController.dispose();
    super.dispose();
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
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
  void getData(String keyWord) {
    String url = "https://pixabay.com/api/?"
        "key=25971755-20594a0ab785428e571aedb46"
        "&q=${keyWord}"
        "&image_type=${photo}";

    http.get(Uri.parse(url)).then((onResp) {
      setState(() {
        this.imagesData= json.decode(onResp.body);
        hits.addAll(imagesData['hits']);
        if (imagesData['totalHits'] % size == 0)
          totalPages = imagesData['totalHits'] ~/ size;
        else
          totalPages = 1 + (imagesData['totalHits'] / size).floor() as int;
      });
    }).catchError((onError) {

    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;


    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          title: Text("PicFinder",
            style: TextStyle(color: Colors.white, ),
          ),
          centerTitle: false,
          actions: <Widget>[
            GestureDetector(child: 
            Icon(
               Icons.favorite,color: Colors.red,
            ),
              onTap:()=>route_favourite() ,
            ),
            Padding(padding: EdgeInsets.all(10.0))
          ],
        ),

        body: (imagesData == null ? Center(child:
        CircularProgressIndicator()) :
        GridView.count(
          crossAxisCount: 2,
          children: List.generate(hits.length, (index) {
            if(globals.favourites.length==0) {
                globals.isFavourited = false;
    }
            else {
              if (globals.favourites.contains(
                  hits[index]['previewURL'].toString()) == true)
                globals.isFavourited = true;
              else
                globals.isFavourited = false;
            }

            return Stack(
              children:<Widget>[ Container(
                height: screenSize.height/2,
                width:screenSize.width/2,
                child:
                GestureDetector(
                  child: Hero(
                    tag: 'imageHero',

                    child: Image.network(
                      hits[index]['previewURL'], fit: BoxFit.fill,),
                  ),
                  onTap: ()
                  {
                    globals.url = hits[index]['previewURL'];
                    Navigator.of(context).push(create_route());
                    // globals.isFavourited=globals().favourites.contains(hits[index]['previewURL'].toString());
                  },
                ),

              ),
            Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                    child: Icon(globals.isFavourited?Icons.favorite:Icons.favorite_border,
                    color: globals.isFavourited?Colors.red:null),
                  onTap: ()=>tapped(index),
                  // {
                  //     setState(() {
                  //       if(globals.isFavourited) {
                  //         globals().favourites!.remove(
                  //             globals.url);
                  //         globals.isFavourited=false;
                  //       }
                  //       else{
                  //         globals().favourites!.add(globals.url);
                  //         globals.isFavourited=true;
                  //       }
                  //     });
                  // },
                ),
              )
            ]
            );
          }
          ),
        )
        )
    );
  }
void tapped(int index){

    setState(() {
      for(var i=0;i<=20;i++){
        if(index==i){
          if(globals.favourites.length==0){
            globals.favourites.add(hits[index]['previewURL']);
            globals.isFavourited=true;
          }else {
            if (globals.favourites.contains(hits[index]['previewURL'].toString()) == true) {
              globals.favourites.remove(hits[index]['previewURL'].toString());
              globals.isFavourited = false;
            }
            else{
              globals.favourites.add(hits[index]['previewURL']);
              globals.isFavourited=true;
            }
          }
        }

      }
    });

}
  Route create_route() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            fullscreen_image(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        }
    );
  }

void route_favourite() {

    Navigator.of(context).push(new MaterialPageRoute(builder: (context){
      return new favourite_page();
    }));
  // return PageRouteBuilder(
  //     pageBuilder: (context, animation, secondaryAnimation) =>
  //         favourite_page(),
      // transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //   const begin = Offset(0.0, 1.0);
      //   const end = Offset.zero;
      //   const curve = Curves.ease;
      //
      //   final tween = Tween(begin: begin, end: end);
      //   final curvedAnimation = CurvedAnimation(
      //     parent: animation,
      //     curve: curve,
      //   );
      //
      //   return SlideTransition(
      //     position: tween.animate(curvedAnimation),
      //     child: child,
      //   );
      // }
 // );
}
}

class fullscreen_image extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Container(
           height: 250,
            child: Image.network(globals.url,fit: BoxFit.fill,),
          ),
        ),
      onTap: (){
          //Navigator.pop(context);
      },),
    );
  }

}

