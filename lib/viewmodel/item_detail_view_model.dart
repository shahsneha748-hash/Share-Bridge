import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sharebridge/repo/item_detail_repo.dart';

class ItemDetailViewModel extends ChangeNotifier {
  final ItemDetailRepo _repo;
  final Map<String, dynamic> item;

  ItemDetailViewModel(this._repo, this.item) {
    _loadDonorProfilePicture();
  }

  bool _isFollowing = false;
  bool get isFollowing => _isFollowing;

  String? _donorProfilePicture;
  String? get donorProfilePicture => _donorProfilePicture;

  Future<void> _loadDonorProfilePicture() async {
    final donorId = item['donorId']?.toString() ?? '';
    if (donorId.isEmpty) return;
    final url = await _repo.getDonorProfilePicture(donorId);
    if (url != null && url.isNotEmpty) {
      _donorProfilePicture = url;
      notifyListeners();
    }
  }

  bool get available => item['isDonated'] != true;

  bool get showExpiry =>
      item['category']?.toString().toLowerCase() == 'food' &&
          item['expiryDate'] != null &&
          item['expiryDate'].toString().isNotEmpty;

  String get donorInitial => (item['donorName'] ?? 'U')[0].toString().toUpperCase();

  Future<void> toggleFollow() async {
    final newState = await _repo.toggleFollow(
      item['donorName'] ?? '',
      _isFollowing,
    );
    _isFollowing = newState;
    notifyListeners();
  }

  Future<void> reportItem() async {
    await _repo.reportItem(item['itemName'] ?? '');
  }

  Future<void> blockDonor() async {
    await _repo.blockDonor(item['donorName'] ?? '');
  }

  Future<void> sendRequest() async {
    await _repo.sendRequest(item);
  }

  /// Opens Maps using lat/lng if available, otherwise falls back to
  /// searching by the text location string.
  Future<bool> openInMaps() async {
    final double? lat = (item['mapLat'] as num?)?.toDouble();
    final double? lng = (item['mapLng'] as num?)?.toDouble();

    Uri googleMapsApp;
    Uri geoUri;

    if (lat != null && lng != null) {
      googleMapsApp = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    } else {
      final location = item['location']?.toString();
      if (location == null || location.isEmpty) {
        return false;
      }
      final encoded = Uri.encodeComponent(location);
      googleMapsApp = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$encoded');
      geoUri = Uri.parse('geo:0,0?q=$encoded');
    }

    try {
      if (await canLaunchUrl(googleMapsApp)) {
        await launchUrl(googleMapsApp, mode: LaunchMode.externalApplication);
        return true;
      } else if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Builds the feature list (portion/weight/tag/condition) for the grid.
  List<Map<String, dynamic>> get features {
    final list = <Map<String, dynamic>>[];
    if (item['portion'] != null && item['portion'].toString().isNotEmpty) {
      list.add({'icon': Icons.group, 'label': 'Portion', 'value': item['portion']});
    } else if (item['portionCount'] != null) {
      list.add({'icon': Icons.group, 'label': 'Portion', 'value': '${item['portionCount']} portions'});
    }
    if (item['weight'] != null) {
      list.add({'icon': Icons.scale, 'label': 'Weight', 'value': item['weight']});
    }
    if (item['tags'] != null && (item['tags'] as List).isNotEmpty) {
      list.add({'icon': Icons.local_offer_outlined, 'label': 'Tag', 'value': (item['tags'] as List).join(', ')});
    }
    if (item['condition'] != null) {
      list.add({'icon': Icons.verified_outlined, 'label': 'Condition', 'value': item['condition']});
    }
    return list;
  }
}