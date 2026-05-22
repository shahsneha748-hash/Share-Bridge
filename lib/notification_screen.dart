import 'package:flutter/material.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});


  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}


class _NotificationScreenState extends State<NotificationScreen> {
  final PageController pageController = PageController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0XFF435944),
        foregroundColor: Colors.white,
        // leading: Icon(Icons.arrow_back_sharp),
        title: Text("Notification", style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),


      body: ListView(
        // physics: NeverScrollableScrollPhysics(),
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
            padding: const EdgeInsets.only(top: 20, right: 10, left: 10),
            child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: Card(
                    color: Color(0XFFeed2d2),
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFFe8a4a4)),),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 25),
                          child: Image.asset("assets/images/alert.png", height: 20, width: 20,),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Urgent Alert", style: TextStyle(fontSize: 20, color: Color(0XFF802222), fontWeight: FontWeight.w500),),
                              Text("Food item expires today", style: TextStyle(fontSize: 17, color: Color(0XFFa95b5b), fontWeight: FontWeight.w500),)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),


                SizedBox(height: 20,),


                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Text(" Today", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w700),)
                    ],
                  ),
                ),


               SizedBox(
                    height: 90,
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFF6a965b)),),

                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            Image.asset("assets/images/p.png", height: 60, width: 60,),
                            SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top:8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("The donor accepted your request. ", style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.w500)),
                                    Text("5h", style: TextStyle(fontSize: 17, color: Colors.grey, fontWeight: FontWeight.w500)),

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
                  height: 90,
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFF859b74)),),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Image.asset("assets/images/c.png", height: 60, width: 60,),
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
                  height: 90,
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFF9ccf8c)),),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal:5),
                      child: Row(
                        children: [
                          Image.asset("assets/images/p.png", height: 60, width: 60,),
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
                  height: 90,
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFFaecea5)),),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal:5),
                      child: Row(
                        children: [
                          Image.asset("assets/images/p.png", height: 60, width: 60,),
                          SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top:8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("New message from donor.", style: TextStyle(fontSize: 17, color: Colors.black,  fontWeight: FontWeight.w500)),
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
                  height: 90,
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFFc4dba7)),),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal:5),
                      child: Row(
                        children: [
                          Image.asset("assets/images/p.png", height: 60, width: 60,),
                          SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top:8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("New post from donor.", style: TextStyle(fontSize: 17, color: Colors.black,  fontWeight: FontWeight.w500)),
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
                  height: 90,
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFFcfe8be)),),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal:5),
                      child: Row(
                        children: [
                          Image.asset("assets/images/p.png", height: 60, width: 60,),
                          SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top:8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("New post from donor.", style: TextStyle(fontSize: 17, color: Colors.black,  fontWeight: FontWeight.w500)),
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
                  height: 90,
                  width: double.infinity,
                   child: Card(
                     color: Colors.white,
                     elevation: 6,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Color(0XFFcfe8be)),),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:5),
                        child: Row(
                          children: [
                            Image.asset("assets/images/p.png", height: 60, width: 60,),
                            SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top:8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("The volunteer has accepted your request for the delivery.", style: TextStyle(fontSize: 17, color: Colors.black,  fontWeight: FontWeight.w500)),
                                    Text("Apr 3", style: TextStyle(fontSize: 17, color: Colors.grey,  fontWeight: FontWeight.w500))


                                  ],
                                ),
                              ),
                            )
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
