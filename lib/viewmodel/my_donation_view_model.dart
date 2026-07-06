import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sharebridge/model/donation_record.dart';
import 'package:sharebridge/repo/my_donation_repo.dart';

class MyDonationsViewModel extends ChangeNotifier {
  final MyDonationsRepo repository;

  MyDonationsViewModel({required this.repository});

  List<DonationRecord> donations = [];
  bool isLoading = false;

  StreamSubscription<List<DonationRecord>>? _subscription;

  void getDonationsForUser(String userId) {
    isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = repository.getDonationsForUser(userId).listen(
          (data) {
        donations = data;
        isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint("Error fetching donations: $error");
        donations = [];
        isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}