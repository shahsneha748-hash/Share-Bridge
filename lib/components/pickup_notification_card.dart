import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:sharebridge/model/notification_model.dart';

  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Color(0XFF6a965b)),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // children: [
          //   Image.asset("assets/images/Mila1.png", height: 80, width: 80),
          //    SizedBox(height: 8),
          //   Text(title, style:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          //   Text(description, style:  TextStyle(fontSize: 16, color: Colors.grey)),
          //    SizedBox(height: 8),
          //   Row(
          //     children: [
          //       TextButton(
          //         onPressed: (){
          //           //send push notification and increase badge number by 1 and add a new notification card to receiver on this news
          //         },
          //         child: const Text("Accept", style: TextStyle(color: Colors.green,),
          //       ),
          //       ),
          //     SizedBox(height: 10),
          //       TextButton(
          //         onPressed: (){
          //           //send push notification and increase badge number by 1 and add a new notification card to receiver on this news
          //         },
          //         child: const Text("Reject", style: TextStyle(color: Colors.red,),
          //       ),),
          //     ],
          //   ),
          // ],
        ),
      ),
    );
  }
