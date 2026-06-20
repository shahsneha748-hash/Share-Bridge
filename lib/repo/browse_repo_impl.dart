import 'package:sharebridge/model/browse_model.dart';
import 'package:sharebridge/repo/browse_repo.dart';
import 'package:sharebridge/view/item_data.dart';

class BrowseRepoImpl implements BrowseRepo {
  @override
  BrowseModel fetchBrowseData() {
    return BrowseModel(allItems: List<Map<String, dynamic>>.from(sharedItems));
  }
}