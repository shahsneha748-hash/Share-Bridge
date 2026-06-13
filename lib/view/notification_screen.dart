import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/model/notification_model.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:sharebridge/model/notification_model.dart';
import 'package:sharebridge/notification_service.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});


  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {     // Notification Screen => Pure UI, listens to ViewModel via Provider.

  @override
  void initState(){
    NotificationService notificationService = NotificationService();
    // notificationService.requestNotificationPermission();
    // notificationService.getFcmToken();
    super.initState();

  }

   final PageController pageController = PageController();

  // PUSH NOTIFICATION
  void firebaseMessaging() async {
    // Firebasemessaging initialize
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    // FCM Token
    String? token = await messaging.getToken();
    print("FCM Token: $token");

    // foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      final title = message.notification!.title ?? "N/A";
      final body = message.notification!.body ?? "N/A";

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(body,
              maxLines: 1,
              style: TextStyle(overflow: TextOverflow.ellipsis),
            ),
        ),
    );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0XFF435944),
        foregroundColor: Colors.white,
        // leading: Icon(Icons.arrow_back_sharp),
        title: Text("Notification", style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w500),                   // whenever we click "Notification" inkwell button a notification will be appear ouside the app not inside app notification with a sound.
        ),
      ),


      body: ListView(
        scrollDirection: Axis.vertical,
        // scrollDirection: Axis.horizontal,                  // default ma horizontal huncha
        controller: pageController,
        // onPageChanged: (int index){
        //   setState(() {
        //     currentIndex = index;
        //   });
        // },
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10, right: 10, left: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100,
                    child: Card(
                      color: Color(0XFFeed2d2),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: Color(0XFFe8a4a4)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                Image.asset("assets/images/Hazel1.png", height: 60, width: 60,),
                                Padding(
                                  padding: EdgeInsets.only(left: 10, bottom: 25),
                                  child: Image.asset("assets/images/alert1.png",
                                      height: 20, width: 20),
                                ),
                                SizedBox(width: 5),

                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Urgent Alert",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Color(0XFF802222),
                                                fontWeight: FontWeight.w500)),
                                        Text("Food item expires today",
                                            style: TextStyle(
                                                fontSize: 17,
                                                color: Color(0XFFa95b5b),
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Today",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w700)),
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFF6a965b)),),

                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            Image.asset("assets/images/p1.png", height: 60, width: 60,),
                            SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top:8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Julie accepted your food donation request. ", style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.w500)),
                                    Row(
                                      children: [
                                        Text("5h", style: TextStyle(fontSize: 17, color: Colors.grey, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Text(" Yesterday", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFF859b74)),),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            Image.asset("assets/images/Sam1.png", height: 60, width: 60,),
                            SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top:8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Food donation expiring in 3 days. ", style: TextStyle(fontSize: 17, color: Colors.black,  fontWeight: FontWeight.w500)),
                                    Text("6d", style: TextStyle(fontSize: 17, color: Colors.grey,  fontWeight: FontWeight.w500))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),

                  Row(
                    children: [
                      Text(" This week", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFF9ccf8c)),),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:5),
                        child: Row(
                          children: [
                            Image.asset("assets/images/Julie1.png", height: 60, width: 60,),
                            SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top:8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Food donation expiring in 7 days. ", style: TextStyle(fontSize: 17, color: Colors.black,  fontWeight: FontWeight.w500),),
                                    Text("6d", style: TextStyle(fontSize: 17, color: Colors.grey, fontWeight: FontWeight.w500),)
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Text(" This month", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 100,
                    child: Card(
                      color: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: Colors.grey),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            Image.asset("assets/images/Jolie1.png", height: 60, width: 60,),
                            SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top:8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Jolie requested your food donation.", style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.w500)),
                                    Row(
                                      children: [
                                        Text("Apr 30 ", style: TextStyle(fontSize: 17, color: Colors.grey, fontWeight: FontWeight.w500)),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),

                  SizedBox(
                    height: 100,
                    child: Card(
                      color: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: Colors.grey),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            Image.asset("assets/images/Sunny1.png", height: 60, width: 60,),
                            SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top:8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Sunny offered to deliver your donation.", style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.w500)),
                                    Row(
                                      children: [
                                        Text("Apr 25", style: TextStyle(fontSize: 17, color: Colors.grey, fontWeight: FontWeight.w500)),
                                        SizedBox(width: 10),
                                        ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFFaecea5)),),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:5),
                        child: Row(
                          children: [
                            Image.asset("assets/images/Julie1.png", height: 60, width: 60,),
                            SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top:8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Julie donated some clothing items.", style: TextStyle(fontSize: 17, color: Colors.black,  fontWeight: FontWeight.w500)),
                                    Text("Apr 20", style: TextStyle(fontSize: 17, color: Colors.grey,  fontWeight: FontWeight.w500))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10,),

                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFFc4dba7)),),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:5),
                        child: Row(
                          children: [
                            Image.asset("assets/images/Mila1.png", height: 60, width: 60,),
                            SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top:8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Mila donated some food items.", style: TextStyle(fontSize: 17, color: Colors.black,  fontWeight: FontWeight.w500)),
                                    Text("Apr 11", style: TextStyle(fontSize: 17, color: Colors.grey,  fontWeight: FontWeight.w500))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10,),

                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFFc4dba7)),),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:5),
                        child: Row(
                          children: [
                            Image.asset("assets/images/Mila1.png", height: 60, width: 60,),
                            SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top:8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Mila rejected your food donation request.", style: TextStyle(fontSize: 17, color: Colors.black,  fontWeight: FontWeight.w500)),
                                    Text("Apr 11", style: TextStyle(fontSize: 17, color: Colors.grey,  fontWeight: FontWeight.w500))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),


                  SizedBox(height: 10,),

                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFFcfe8be)),),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:5),
                        child: Row(
                          children: [
                            Image.asset("assets/images/Bob1.png", height: 60, width: 60,),
                            SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top:8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Pickup time scheduled at 8AM.", style: TextStyle(fontSize: 17, color: Colors.black,  fontWeight: FontWeight.w500)),
                                    Text("Apr 8", style: TextStyle(fontSize: 17, color: Colors.grey,  fontWeight: FontWeight.w500))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10,),

                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFFcfe8be)),),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:5),
                        child: Row(
                          children: [
                            Image.asset("assets/images/Leo1.png", height: 60, width: 60,),
                            SizedBox(width: 10),
                            Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top:8),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Leo offered to deliver your donation.", style: TextStyle(fontSize: 17, color: Colors.black,  fontWeight: FontWeight.w500)),
                                        Row(
                                          children: [
                                            Text("Apr 3", style: TextStyle(fontSize: 17, color: Colors.grey,  fontWeight: FontWeight.w500)),
                                            SizedBox(width: 10),
                                             ],
                                        ),
                                      ]
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Note: ⚡ Flow Recap
// Model → defines notification data. (Eg: Model = raw data only (like a database row).)
// Repo → fetches/saves notifications from Firestore. (Eg: repo = only defines what function exits with hiding implementation of functions. Eg: addUser, deleteUser, etc. so that MVVM architecture is clean)
// ViewModel → manages state, exposes clean methods.
// View → displays notifications, calls ViewModel methods.   (Eg: Notification Screen => Pure UI, listens to ViewModel via Provider.)