import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_search_pixabay/globals.dart';

class favourite_page extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text("Favourites",
        style: TextStyle(color: Colors.white),
    ),
          centerTitle: true,
        ),
      body: (globals.favourites.length==0?
    Center(
        child: Text("No favourites added",style: TextStyle(color: Colors.lightGreen,fontSize:30.0)
        )
    ):
      GridView.count(crossAxisCount: 2,
      children: List.generate(globals.favourites.length, (index) {
        return Container(
          height: screenSize.height/2,
          width: screenSize.width/2,
         child: Image.network(globals.favourites[index],fit: BoxFit.fill,),

        );
      }),))
    );
  }

}