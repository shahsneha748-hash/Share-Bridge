import 'package:flutter/material.dart';

Widget _urgentAlertCard() {
  return Card(
    color: const Color(0XFFeed2d2),
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: Color(0XFFe8a4a4)),
    ),
    child: ListTile(
      leading: Image.asset("assets/images/alert1.png", height: 40, width: 40),
      title: const Text("⚠️ Urgent Alert",
          style: TextStyle(fontSize: 20, color: Color(0XFF802222))),
      subtitle: const Text("Food item expires today",
          style: TextStyle(fontSize: 17, color: Color(0XFFa95b5b))),
    ),
  );
}
