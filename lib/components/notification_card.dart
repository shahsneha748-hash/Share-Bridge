import 'package:flutter/material.dart';

enum NotificationType { request, pickup, alert }

class NotificationCard extends StatelessWidget {
  final NotificationType type;
  final String description;
  final String? numberField;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onEdit;

  const NotificationCard({
    required this.type,
    required this.description,
    this.numberField,
    this.onAccept,
    this.onReject,
    this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case NotificationType.request:
        return Card(
          color: Colors.orange[50],
          child: Column(
            children: [
              Text("Donation Request", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description),
              Row(
                children: [
                  ElevatedButton(onPressed: onAccept, child: const Text("Accept")),
                  ElevatedButton(onPressed: onReject, child: const Text("Reject")),
                ],
              ),
            ],
          ),
        );
      case NotificationType.pickup:
        return Card(
          color: Colors.green[50],
          child: Column(
            children: [
              Text("Pickup Scheduled", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description),
              if (numberField != null) Text("Pickup Number: $numberField"),
              TextButton(onPressed: onEdit, child: const Text("Edit")),
            ],
          ),
        );
      case NotificationType.alert:
        return Card(
          color: Colors.red[50],
          child: Column(
            children: [
              Text("Alert!", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description),
            ],
          ),
        );
    }
  }
}

