import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

const _brandGreen = Color(0xFF3A5C2E);

class DeliveryTrackerWidget extends StatefulWidget {
  final String status;
  final DateTime? locationUpdatedAt;
  final String pickupAddress;
  final String deliveryAddress;
  final double? currentLat;
  final double? currentLng;

  const DeliveryTrackerWidget({
    super.key,
    required this.status,
    required this.locationUpdatedAt,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.currentLat,
    required this.currentLng,
  });

  @override
  State<DeliveryTrackerWidget> createState() => _DeliveryTrackerWidgetState();
}

class _DeliveryTrackerWidgetState extends State<DeliveryTrackerWidget> {
  double? _pickupLat, _pickupLng;
  double? _deliveryLat, _deliveryLng;
  bool _geocoded = false;
  bool _geocodeFailed = false;
  String? _lastPickup, _lastDelivery;

  @override
  void initState() {
    super.initState();
    _geocodeAddresses();
  }

  @override
  void didUpdateWidget(covariant DeliveryTrackerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only re-geocode if the addresses actually changed (avoid repeat lookups on every rebuild)
    if (widget.pickupAddress != _lastPickup || widget.deliveryAddress != _lastDelivery) {
      _geocodeAddresses();
    }
  }

  Future<void> _geocodeAddresses() async {
    _lastPickup = widget.pickupAddress;
    _lastDelivery = widget.deliveryAddress;
    try {
      final pickupResults = await locationFromAddress(widget.pickupAddress);
      final deliveryResults = await locationFromAddress(widget.deliveryAddress);
      if (!mounted) return;
      if (pickupResults.isNotEmpty && deliveryResults.isNotEmpty) {
        setState(() {
          _pickupLat = pickupResults.first.latitude;
          _pickupLng = pickupResults.first.longitude;
          _deliveryLat = deliveryResults.first.latitude;
          _deliveryLng = deliveryResults.first.longitude;
          _geocoded = true;
          _geocodeFailed = false;
        });
      } else {
        setState(() => _geocodeFailed = true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _geocodeFailed = true);
    }
  }

  /// Real progress: how far along the pickup→delivery line the volunteer's
  /// current position is, clamped 0..1. Falls back to stage-based progress
  /// if we don't have coordinates yet.
  double get _progress {
    final hasRealData = _geocoded &&
        widget.currentLat != null &&
        widget.currentLng != null &&
        _pickupLat != null &&
        _deliveryLat != null;

    if (hasRealData) {
      final totalDistance = Geolocator.distanceBetween(
        _pickupLat!, _pickupLng!, _deliveryLat!, _deliveryLng!,
      );
      final traveledDistance = Geolocator.distanceBetween(
        _pickupLat!, _pickupLng!, widget.currentLat!, widget.currentLng!,
      );
      if (totalDistance <= 0) return _stageProgress;
      return (traveledDistance / totalDistance).clamp(0.0, 1.0);
    }
    return _stageProgress;
  }

  double get _stageProgress {
    switch (widget.status.toLowerCase().replaceAll('_', '')) {
      case 'pending':
        return 0.0;
      case 'accepted':
        return 0.15;
      case 'inprogress':
        return 0.55;
      case 'reached':
      case 'completed':
      case 'delivered':
        return 1.0;
      default:
        return 0.0;
    }
  }

  String? get _distanceRemainingText {
    if (!_geocoded || widget.currentLat == null || widget.currentLng == null || _deliveryLat == null) {
      return null;
    }
    final remaining = Geolocator.distanceBetween(
      widget.currentLat!, widget.currentLng!, _deliveryLat!, _deliveryLng!,
    );
    if (remaining < 1000) return '${remaining.round()} m to destination';
    return '${(remaining / 1000).toStringAsFixed(1)} km to destination';
  }

  String get _label {
    switch (widget.status.toLowerCase().replaceAll('_', '')) {
      case 'pending':
        return 'Waiting for a volunteer';
      case 'accepted':
        return 'Volunteer heading to pickup';
      case 'inprogress':
        return 'On the way to you';
      case 'reached':
        return 'Arrived at your location';
      case 'completed':
      case 'delivered':
        return 'Delivered';
      default:
        return widget.status;
    }
  }

  String _timeAgo(DateTime? time) {
    if (time == null) return 'No updates yet';
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Updated just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    return 'Updated ${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.navigation_outlined, size: 18, color: _brandGreen),
              SizedBox(width: 8),
              Text("Live Tracking", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _RouteTrack(progress: _progress),
          const SizedBox(height: 14),
          Text(_label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _brandGreen)),
          const SizedBox(height: 4),
          if (_distanceRemainingText != null)
            Text(_distanceRemainingText!, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 2),
          Text(_timeAgo(widget.locationUpdatedAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          if (_geocodeFailed)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                "Couldn't pinpoint exact addresses — showing estimated progress instead.",
                style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}

class _RouteTrack extends StatelessWidget {
  final double progress;
  const _RouteTrack({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth - 24;
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: 12,
                right: 12,
                top: 27,
                child: Container(height: 3, color: Colors.grey.shade200),
              ),
              Positioned(
                left: 12,
                top: 27,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  height: 3,
                  width: trackWidth * progress,
                  color: _brandGreen,
                ),
              ),
              const Positioned(
                left: 0,
                top: 16,
                child: _EndpointDot(icon: Icons.storefront, filled: true),
              ),
              const Positioned(
                right: 0,
                top: 16,
                child: _EndpointDot(icon: Icons.home, filled: false),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                left: 4 + (trackWidth * progress),
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _brandGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: _brandGreen.withOpacity(0.4), blurRadius: 8, spreadRadius: 1),
                    ],
                  ),
                  child: const Icon(Icons.local_shipping, color: Colors.white, size: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EndpointDot extends StatelessWidget {
  final IconData icon;
  final bool filled;
  const _EndpointDot({required this.icon, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: filled ? _brandGreen.withOpacity(0.15) : Colors.grey.shade100,
        shape: BoxShape.circle,
        border: Border.all(color: filled ? _brandGreen : Colors.grey.shade400, width: 1.5),
      ),
      child: Icon(icon, size: 13, color: filled ? _brandGreen : Colors.grey.shade500),
    );
  }
}