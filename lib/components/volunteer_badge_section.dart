import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/volunteer_model.dart';
import '../repo/volunteer_repo.dart';

const _brandGreen = Color(0xFF3A5C2E);

class _BadgeDef {
  final String title;
  final IconData icon;
  final int threshold;
  const _BadgeDef(this.title, this.icon, this.threshold);
}

const _badges = [
  _BadgeDef('First Delivery', Icons.emoji_events_outlined, 1),
  _BadgeDef('5 Deliveries', Icons.local_shipping_outlined, 5),
  _BadgeDef('10 Deliveries', Icons.military_tech_outlined, 10),
  _BadgeDef('25 Deliveries', Icons.workspace_premium_outlined, 25),
  _BadgeDef('50 Deliveries', Icons.stars_outlined, 50),
  _BadgeDef('100 Deliveries', Icons.emoji_events, 100),
  _BadgeDef('150 Deliveries', Icons.shield_outlined, 150),
  _BadgeDef('250 Deliveries', Icons.diamond_outlined, 250),
  _BadgeDef('500 Deliveries — Legendary', Icons.auto_awesome, 500),
];

class VolunteerBadgesSection extends StatefulWidget {
  final String uid;
  const VolunteerBadgesSection({super.key, required this.uid});

  @override
  State<VolunteerBadgesSection> createState() => _VolunteerBadgesSectionState();
}

class _VolunteerBadgesSectionState extends State<VolunteerBadgesSection> {
  int? _lastSeenCount;

  void _checkForNewUnlock(int newCount) {
    if (_lastSeenCount == null) {
      // First load — just remember it, don't celebrate for pre-existing badges.
      _lastSeenCount = newCount;
      return;
    }
    if (newCount == _lastSeenCount) return;

    final newlyUnlocked = _badges.where(
          (b) => newCount >= b.threshold && (_lastSeenCount! < b.threshold),
    );
    _lastSeenCount = newCount;

    if (newlyUnlocked.isNotEmpty) {
      final badge = newlyUnlocked.last; // highest newly-crossed threshold
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showCelebration(badge);
      });
    }
  }

  void _showCelebration(_BadgeDef badge) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _brandGreen.withOpacity(0.12),
                  border: Border.all(color: _brandGreen, width: 2),
                ),
                child: Icon(badge.icon, color: _brandGreen, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                "New Badge Unlocked!",
                style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                badge.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Nice!"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VolunteerModel>(
      stream: context.read<VolunteerRepo>().watchProfile(widget.uid),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (profile == null || profile.status != 'Approved') {
          return const SizedBox.shrink();
        }

        final count = profile.completedTasksCount;
        _checkForNewUnlock(count);

        final isLegendary = count >= 500;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isLegendary ? Icons.auto_awesome : Icons.emoji_events_outlined,
                    size: 18,
                    color: isLegendary ? Colors.amber.shade700 : _brandGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isLegendary ? 'Legendary Volunteer' : 'Volunteer Badges',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text('$count delivered',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _badges.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final badge = _badges[i];
                    final unlocked = count >= badge.threshold;
                    return _BadgeTile(badge: badge, unlocked: unlocked);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final _BadgeDef badge;
  final bool unlocked;
  const _BadgeTile({required this.badge, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? _brandGreen.withOpacity(0.12) : Colors.grey.shade100,
              border: Border.all(
                color: unlocked ? _brandGreen : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Icon(
              badge.icon,
              color: unlocked ? _brandGreen : Colors.grey.shade400,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: unlocked ? Colors.black87 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}