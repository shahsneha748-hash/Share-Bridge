import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../constants/colors.dart';

class MapLocationPicker extends StatefulWidget {
  const MapLocationPicker({super.key});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng _pickedLocation = const LatLng(27.7172, 85.3240); // Kathmandu default
  String _address = 'Move the map to select location';
  bool _isLoading = false;
  bool _isFetchingAddress = false;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    // Do NOT call _getCurrentLocation() here — map controller isn't
    // attached yet. We wait for onMapReady instead.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Called once FlutterMap has finished initializing ──
  void _onMapReady() {
    _mapReady = true;
    _getCurrentLocation();
  }

  // ── Get current GPS location ──
  Future<void> _getCurrentLocation() async {
    if (!_mapReady) return;

    setState(() => _isLoading = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are OFF. Please enable GPS.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied. Enable it in app settings.')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      final latLng = LatLng(position.latitude, position.longitude);
      _moveCamera(latLng);
      await _getAddressFromLatLng(latLng);
    } catch (e) {
      debugPrint('Location error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: $e')), // TEMP: shows real error
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Move map camera ──
  void _moveCamera(LatLng latLng) {
    if (!_mapReady) return;
    _mapController.move(latLng, 16);
    setState(() => _pickedLocation = latLng);
  }

  // ── Reverse geocode: LatLng → address ──
  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    setState(() => _isFetchingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((s) => s != null && s.isNotEmpty).toList();
        setState(() {
          _address = parts.isNotEmpty
              ? parts.join(', ')
              : 'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
      setState(() => _address =
      'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}');
    } finally {
      if (mounted) setState(() => _isFetchingAddress = false);
    }
  }

  // ── Forward geocode: search text → LatLng ──
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      List<Location> locations = [];
      try {
        locations = await locationFromAddress('$query, Nepal');
      } catch (e) {
        debugPrint('Search attempt 1 failed: $e');
      }
      if (locations.isEmpty) {
        try {
          locations = await locationFromAddress(query);
        } catch (e) {
          debugPrint('Search attempt 2 failed: $e');
        }
      }

      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);
        _moveCamera(latLng);
        await _getAddressFromLatLng(latLng);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location not found. Try a different search.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Search failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')), // TEMP: shows real error
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmLocation() {
    Navigator.pop(context, _address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Pick Pickup Location',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          // ── OpenStreetMap ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickedLocation,
              initialZoom: 14,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onMapReady: _onMapReady,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() => _pickedLocation = position.center!);
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _getAddressFromLatLng(_pickedLocation);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sharebridge.app',
              ),
            ],
          ),

          // ── Center Pin (fixed, map moves under it) ──
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.location_pin, size: 48, color: AppColors.darkGreen),
            ),
          ),

          // ── Search Bar ──
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: _searchLocation,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search location...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: AppColors.darkGreen, size: 20),
                    onPressed: () => _searchLocation(_searchController.text),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onChanged: (v) => setState(() {}),
              ),
            ),
          ),

          // ── My Location Button ──
          Positioned(
            right: 12,
            bottom: 220, // raised higher so it can't overlap the card
            child: FloatingActionButton.small(
              heroTag: 'myLocation',
              backgroundColor: Colors.white,
              onPressed: () {
                debugPrint('Location button tapped'); //
                _getCurrentLocation();
              },
              child: const Icon(Icons.my_location, color: AppColors.darkGreen),
            ),
          ),

          // ── Loading overlay ──
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.2),
              child: const Center(child: CircularProgressIndicator(color: AppColors.darkGreen)),
            ),

          // ── Bottom Address Card ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected Location',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.darkGreen, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _isFetchingAddress
                            ? const SizedBox(
                          height: 16,
                          child: LinearProgressIndicator(color: AppColors.darkGreen),
                        )
                            : Text(
                          _address,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isFetchingAddress ? null : _confirmLocation,
                      child: const Text('Confirm Location',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
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