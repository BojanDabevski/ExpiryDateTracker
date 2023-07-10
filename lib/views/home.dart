import 'dart:convert';
import 'dart:io';
import 'package:expiry_date_tracker/models/recipe_model.dart';
import 'package:expiry_date_tracker/views/recipe_view.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckRecipe extends StatefulWidget {
  const CheckRecipe({Key? key}) : super(key: key);

  @override
  State<CheckRecipe> createState() => _CheckRecipeState();
}

class _CheckRecipeState extends State<CheckRecipe> {

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
      RecipeModel recipeModel = new RecipeModel(image: '', label: '', source:'',url: '');
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
                ),
                SizedBox(height: 30,),
                Container(
                  child: GridView(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200, mainAxisSpacing: 10.0
                      ),
                    children: List.generate(recipes.length, (index)  {
                      return GridTile(
                        child: RecipieTile(
                        title: recipes[index].label,
                        desc: recipes[index].source,
                        imgUrl: recipes[index].image,
                        url: recipes[index].url,
                        ));
                    }),
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
class RecipieTile extends StatefulWidget {
  final String title, desc, imgUrl, url;

  RecipieTile({required this.title, required this.desc, required this.imgUrl, required this.url});

  @override
  _RecipieTileState createState() => _RecipieTileState();
}

class _RecipieTileState extends State<RecipieTile> {
  _launchURL(String url) async {
    print(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (kIsWeb) {
              _launchURL(widget.url);
            } else {
              print(widget.url + " this is what we are going to see");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RecipeView(
                        postUrl: widget.url,
                      )));
            }
          },
          child: Container(
            margin: EdgeInsets.all(8),
            child: Stack(
              children: <Widget>[
                Image.network(
                  widget.imgUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: 200,
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.white30, Colors.white],
                          begin: FractionalOffset.centerRight,
                          end: FractionalOffset.centerLeft)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              ),
                        ),
                        Text(
                          widget.desc,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

