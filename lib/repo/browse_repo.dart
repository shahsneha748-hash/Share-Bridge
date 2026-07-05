import 'package:sharebridge/model/browse_model.dart';

abstract class BrowseRepo {
  Stream<BrowseModel> getBrowseData();
}