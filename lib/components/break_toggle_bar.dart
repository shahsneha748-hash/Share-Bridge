import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/volunteer_model.dart';
import '../repo/volunteer_repo.dart';

/// Compact icon-only toggle for the app bar. Tap flips online/break status.
class BreakToggleChip extends StatelessWidget {
  final String uid;
  const BreakToggleChip({super.key, required this.uid});

  // 👇 put your hex codes here
  static const Color onlineColor = Color(0xFF9BD381);   // color when "Online"
  static const Color breakColor = Color(0xFFF3E99F);    // color when "On a break"

  @override
  Widget build(BuildContext context) {
    final repo = context.read<VolunteerRepo>();

    return StreamBuilder<VolunteerModel>(
      stream: repo.watchProfile(uid),
      builder: (context, snapshot) {
        final isAccepting = snapshot.data?.isAcceptingTasks ?? true;

        return IconButton(
          tooltip: isAccepting ? "Online — tap to take a break" : "On a break — tap to go online",
          onPressed: () => repo.setAcceptingTasks(uid, !isAccepting),
          padding: const EdgeInsets.all(8),
          icon: Icon(
            isAccepting ? Icons.toggle_on : Icons.toggle_off_outlined,
            color: isAccepting ? onlineColor : breakColor,
            size: 45,
          ),
        );
      },
    );
  }
}