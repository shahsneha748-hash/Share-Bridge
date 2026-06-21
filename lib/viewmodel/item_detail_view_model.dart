import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sharebridge/repo/item_detail_repo.dart';

class ItemDetailViewModel extends ChangeNotifier {
  final ItemDetailRepo _repo;
  final Map<String, dynamic> item;

  ItemDetailViewModel(this._repo, this.item);

  bool _isFollowing = false;
  bool get isFollowing => _isFollowing;

  bool get available => item['available'] == true;

  bool get showExpiry =>
      item['category'] == 'Food' &&
          item['expires'] != null &&
          item['expires'].toString().isNotEmpty;

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
    await _repo.reportItem(item['title'] ?? '');
  }

  Future<void> blockDonor() async {
    await _repo.blockDonor(item['donorName'] ?? '');
  }

  Future<void> sendRequest() async {
    await _repo.sendRequest(item['title'] ?? '', item['donorName'] ?? '');
  }

  /// Returns null if location is missing, otherwise opens Maps.
  /// Caller handles the null case to show a snackbar.
  Future<bool> openInMaps() async {
    final double? lat = (item['mapLat'] as num?)?.toDouble();
    final double? lng = (item['mapLng'] as num?)?.toDouble();

    if (lat == null || lng == null) {
      return false;
    }

    final Uri googleMapsApp = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final Uri geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');

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
    if (item['portion'] != null) {
      list.add({'icon': Icons.group, 'label': 'Portion', 'value': item['portion']});
    }
    if (item['weight'] != null) {
      list.add({'icon': Icons.scale, 'label': 'Weight', 'value': item['weight']});
    }
    if (item['tag'] != null) {
      list.add({'icon': Icons.local_offer_outlined, 'label': 'Tag', 'value': item['tag']});
    }
    if (item['condition'] != null) {
      list.add({'icon': Icons.verified_outlined, 'label': 'Condition', 'value': item['condition']});
    }
    return list;
  }
}