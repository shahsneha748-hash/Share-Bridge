import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Tasks")),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('volunteer_tasks')
            .where('assignedVolunteerId', isEqualTo: uid)
            .where('status', isEqualTo: 'accepted')
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No tasks yet"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();

              return ListTile(
                title: Text(data['donationTitle'] ?? ''),
                subtitle: Text(data['deliveryLocation'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}