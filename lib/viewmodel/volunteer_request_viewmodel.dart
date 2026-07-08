import 'package:flutter/material.dart';

import '../model/volunteer_request_model.dart';
import '../repo/volunteer_request_repo.dart';



class VolunteerRequestViewModel
    extends ChangeNotifier {


  final VolunteerRequestRepo repo;


  VolunteerRequestViewModel(
      this.repo
      );



  bool loading = false;


  List<VolunteerRequestModel> requests=[];



  Future<void> createRequest(
      VolunteerRequestModel request
      ) async {


    loading=true;

    notifyListeners();


    await repo.createRequest(request);


    loading=false;

    notifyListeners();


  }



  void listenRequests(){


    repo.getVolunteerRequests()
        .listen((data){


      requests=data;


      notifyListeners();


    });


  }



  Future<void> acceptRequest(
      String id
      ) async {


    await repo.updateRequestStatus(
        id,
        "accepted"
    );


  }



  Future<void> rejectRequest(
      String id
      ) async {


    await repo.updateRequestStatus(
        id,
        "rejected"
    );


  }


}