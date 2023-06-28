import 'dart:convert';
import 'dart:io';
import 'package:expiry_date_tracker/models/recipe_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<RecipeModel> recipes = <RecipeModel>[];
  TextEditingController textEditingController = new TextEditingController();
  String applicationId = "6c112e86";
  String applicationKey = "a8a241eaeba5ca2af7b1c3666a4880ce";

  getRecipes(String query) async{
    String link = "https://api.edamam.com/api/recipes/v2?type=public&q=$query&app_id=6c112e86&app_key=a8a241eaeba5ca2af7b1c3666a4880ce";
    var url = Uri.parse(link);

    var response = await http.get(url);

    Map<String, dynamic> jsonData = jsonDecode(response.body);
    jsonData["hits"].forEach((element) {
      print(element.toString());
      RecipeModel recipeModel = new RecipeModel();
      recipeModel = RecipeModel.fromMap(element["recipe"]);
      recipes.add(recipeModel);
    });

    print("${recipes.toString()}");


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: Platform.isIOS? 60: 30, horizontal: 30),
            color: Colors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 60,),
                    Text("ExpiryDateTracker ", style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                      color: Colors.white
                    ),),
                    Text("Recipes", style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 23
                    ),)
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Text("What will you cook today?", style: TextStyle(
                  fontSize: 20,
                  color: Colors.white
                ),),
                SizedBox(height:8,),
                Text("Enter the engridients whose expiration date is close in order to make a delicious meal out of them from our amazing recipes and reduce food waste", style: TextStyle(
                  fontSize: 15,
                  color: Colors.white
                  ),
                ),
                SizedBox(height: 30,),
                Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: textEditingController,
                            decoration: InputDecoration(
                                hintText: "Enter ingredient",
                                hintStyle: TextStyle(
                                  fontSize: 18, color: Colors.black.withOpacity(0.5)
                                )
                            ),
                            style: TextStyle(
                              fontSize: 18
                            ),
                          ),
                        ),
                        SizedBox(width: 16,),
                        InkWell(
                          onTap: (){
                            if(textEditingController.text.isNotEmpty) {
                              getRecipes(textEditingController.text);
                              print("just do it");
                            } else{
                              print("just don't do it");
                            }
                          },
                        child: Container(
                          child: Icon(Icons.search, color: Colors.white,),
                        )
                      )
                      ],
                    ),
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}
