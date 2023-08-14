import 'package:camera/camera.dart';
import 'package:expiry_date_tracker/views/preview_page.dart';
import 'package:expiry_date_tracker/views/recipe_page.dart';
import 'package:expiry_date_tracker/views/location_page.dart';
import 'package:flutter/material.dart';
import 'models/Product.dart';
import 'views/calendar_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'views/camera_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('expiry_date_tracker_logo');

  final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true, onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {});

  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExpiryDateTracker',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoggedIn = false;
  var title = 'ExpiryDateTracker';
  List<Product> products = [];
  bool toggleForm = false;

  final _inputKey = GlobalKey<FormState>();
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();

  XFile? picture;
  String? name = "";
  String? username = "";
  String? password = "";
  DateTime currentDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();


  late TextEditingController txt;
  late TextEditingController user;

  @override
  void initState() {
    super.initState();
    txt = TextEditingController()
      ..addListener(() {
        // print(txt.text);
      });

    user = TextEditingController()
      ..addListener(() {
        // print(txt.text);
      });
  }

  @override
  void dispose() {
    txt.dispose();
    user.dispose();
    super.dispose();
  }
  
  Future<void> _selectPicture(BuildContext context) async {

    final result = await availableCameras().then((value) => Navigator.push(context,
        MaterialPageRoute(builder: (_) => CameraPage(cameras: value))));

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$result')));

    if (result != null &&  result!=picture)
      setState(() {
        picture = result;
      });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(context: context, initialDate: currentDate, firstDate: DateTime(2015), lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        currentDate = pickedDate;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked_s = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        });

    if (picked_s != null && picked_s != selectedTime)
      setState(() {
        selectedTime = picked_s;
      });
  }

  Future<List<Product>> _get(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? productsString = await prefs.getString(username);

    List<Product> productsList = [];

    if (productsString != null) productsList = Product.decode(productsString);

    return productsList;
  }

  Future<void> _set(String username, List<Product> products) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String encodedData = Product.encode(products);

    await prefs.setString(username, encodedData);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      title: 'Expiry Date Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
           title: Text(title),
          // title: Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Image.asset(
          //       'assets/logo.png',
          //       fit: BoxFit.contain,
          //       height: 32,
          //     ),
          //     Container(
          //         padding: const EdgeInsets.all(8.0), child: Text('YourAppTitle'))
          //   ],
          //
          // ),

          actions: [
            if (isLoggedIn)
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    toggleForm = !toggleForm;
                  });
                },
              ),
            if (isLoggedIn)
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    toggleForm = false;
                  });
                },
              ),
          ],
        ),
        body: isLoggedIn
            ? SingleChildScrollView(
            child: Column(children: <Widget>[
              if (toggleForm)
                Card(
                    elevation: 5,
                    child: Form(
                      key: _inputKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                              padding: EdgeInsets.all(15),
                              child: TextFormField(
                                  controller: txt,
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.book_outlined),
                                    hintText: 'Name of the product',
                                    labelText: 'Product name *',
                                  ),
                                  validator: (inputString) {
                                    name = inputString;
                                    if (inputString!.length < 1) {
                                      return 'Please enter a valid name';
                                    }
                                    return null;
                                  })),
                          Padding(
                            padding: EdgeInsets.all(1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(20), child: Text(currentDate.toString().split(" ")[0])),
                                ElevatedButton(
                                  onPressed: () => _selectDate(context),
                                  child: Text('Select date'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(20), child: Text(selectedTime.format(context))),
                                ElevatedButton(
                                  onPressed: () => _selectTime(context),
                                  child: Text('Select time'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ElevatedButton(
                                  onPressed: () => _selectPicture(context),
                                  child: Text('Take a Picture'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_inputKey.currentState!.validate()) {
                                  name = txt.text;
                                  currentDate = new DateTime(currentDate.year, currentDate.month, currentDate.day, selectedTime.hour, selectedTime.minute);
                                  Product obj = new Product(name: name!, date: currentDate, time: selectedTime, image: picture);
                                  scheduler(obj);
                                  products.add(obj);
                                  _set(username!, products);
                                  setState(() {
                                    this.products = products;
                                    txt.text = "";
                                    name = "";
                                    currentDate = DateTime.now();
                                    selectedTime = TimeOfDay.now();
                                  });
                                  _messangerKey.currentState?.showSnackBar(SnackBar(content: Text('Product added successfully')));
                                }
                              },
                              child: const Text('Add'),
                            ),
                          ),
                        ],
                      ),
                    )),
              Padding(
                  padding: EdgeInsets.all(5),
                  child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child:  Text('Welcome '+ username.toString() +' to ExpiryDateTracker'),
                      ))),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 50,),
                  Padding(
                      padding: EdgeInsets.all(5),
                      child: Center(
                          child: Container(
                              padding: EdgeInsets.all(5),
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => Calendar(this.products)),
                                ),
                                child: const Text('Products calendar'),
                              )))),
                  Padding(
                      padding: EdgeInsets.all(5),
                      child: Center(
                          child: Container(
                              padding: EdgeInsets.all(5),
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => LocationPage()),
                                ),
                                child: const Text('GetLocation'),
                              )))),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 60,),
                  Padding(
                      padding: EdgeInsets.all(5),
                      child: Center(
                          child: Container(
                              padding: EdgeInsets.all(5),
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => CheckRecipe()),
                                ),
                                child: const Text('Explore recipe'),
                              )))),
                  SizedBox(width: 30,),
                  Padding(
                      padding: EdgeInsets.all(5),
                      child: Center(
                          child: Container(
                              padding: EdgeInsets.all(5),
                              width: 100,
                              child: SizedBox(
                                width: 5000,
                                child: ElevatedButton(
                                  onPressed: () => setState(() => {
                                    username = "",
                                    isLoggedIn = false
                                  }),
                                  child: const Text('Logout'),
                                ),
                              )))),
                ],
              ),
              Padding(
                  padding: EdgeInsets.all(5),
                  child: Center(
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child:  Text('Current Time: ${currentDate}'),
                          ))),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (contx, index) {
                  return Column(children: [
                    Card(
                      key: Key(products[index].name!),
                      elevation: 2,
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(18),
                        child: Column(children: [
                          Container(padding: EdgeInsets.all(5), margin: EdgeInsets.all(5), child: Text(products[index].name.toString(), style: TextStyle(fontWeight: FontWeight.bold))),
                          Container(padding: EdgeInsets.all(5), margin: EdgeInsets.all(5), child: Text(products[index].date.toString().split(" ")[0] + " " + products[index].time!.format(context) + " " + products[index].image!.name, style:  TextStyle(color: Colors.grey))),
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PreviewPage(picture: products[index].image!)),
                            ),
                            child: const Text('See Picture'),
                          )
                        ]),
                      ),
                    ),
                  ]);
                },
              ),
            ]))
            : Card(
            elevation: 5,
            child: Form(
              key: _inputKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Padding(padding: EdgeInsets.all(15),
                  // child: Image.asset(
                  //         'assets/images/logo.png',
                  //         fit: BoxFit.contain,
                  //         height: 100,
                  //       ),),

                  Padding(
                      padding: EdgeInsets.all(15),
                      child: TextFormField(
                          controller: user,
                          decoration: InputDecoration(
                            icon: Icon(Icons.account_circle),
                            hintText: 'Type in your username',
                            labelText: 'Username *',
                          ),
                          validator: (inputString) {
                            username = inputString;
                            if (inputString!.length < 1) {
                              return 'Please enter a valid username';
                            }
                            return null;
                          })
                  ),
                  Padding(padding: EdgeInsets.all(15),
                      child: TextFormField(
                          decoration: InputDecoration(
                            icon: Icon(Icons.account_circle),
                            hintText: 'Type in your paswword',
                            labelText: 'Password *',
                          ),
                          validator: (inputString) {
                            password = inputString;
                            if (inputString!.length < 5) {
                              return 'Please enter a valid password';
                            }
                            return null;
                          })
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_inputKey.currentState!.validate()) {
                          username = user.text;
                          user.text = "";
                          _get(username!).then((List<Product> productsList) => {
                            setState(() {
                              this.products = productsList;
                              isLoggedIn = true;
                            })
                          });
                          _messangerKey.currentState?.showSnackBar(SnackBar(content: Text('Logged in successfully')));
                        }
                      },
                      child: const Text('Login'),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  void scheduler(Product product) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('product_notif_channel_id', 'product_notif_channel', channelDescription: 'Channel for Product expiration notification', icon: 'expiry_date_tracker_logo', sound: RawResourceAndroidNotificationSound('notification'), largeIcon: DrawableResourceAndroidBitmap('expiry_date_tracker_logo'));

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(sound: 'notification.wav', presentAlert: true, presentBadge: true, presentSound: true);

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    var dayBefore = product.date?.subtract(const Duration(days: 1));

    await flutterLocalNotificationsPlugin.schedule(0, 'The product will expire tomorrow', product.name, dayBefore!, platformChannelSpecifics);
  }
}
