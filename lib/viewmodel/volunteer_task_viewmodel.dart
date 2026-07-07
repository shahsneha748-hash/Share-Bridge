import 'dart:async';

import 'package:flutter/material.dart';

import '../model/volunteer_task_model.dart';
import '../repo/volunteer_task_repo.dart';



class VolunteerTaskViewModel extends ChangeNotifier {



  final VolunteerTaskRepo repo;


  final String volunteerId;



  VolunteerTaskViewModel({

    required this.repo,

    required this.volunteerId,

  }){


    fetchTasks();


  }




  List<VolunteerTaskModel> tasks = [];



  bool loading = false;



  String? errorMessage;



  String? actingOnTaskId;




  StreamSubscription? subscription;






  void fetchTasks(){



    loading = true;

    notifyListeners();




    subscription =
        repo.getVolunteerTasks(volunteerId)
            .listen((data){



          tasks = data;


          loading = false;


          errorMessage = null;


          notifyListeners();



        },


            onError:(error){



              loading = false;


              errorMessage =
                  error.toString();



              notifyListeners();


            });


  }






  List<VolunteerTaskModel> get pendingTasks {


    return tasks.where((task){


      return task.status.toLowerCase()
          ==
          "pending";


    }).toList();


  }







  List<VolunteerTaskModel> get activeTasks {


    return tasks.where((task){


      final status =
      task.status.toLowerCase();



      return status == "accepted" ||

          status == "in_progress" ||

          status == "reached";



    }).toList();


  }







  List<VolunteerTaskModel> get pastTasks {


    return tasks.where((task){


      final status =
      task.status.toLowerCase();



      return status == "completed" ||

          status == "rejected";



    }).toList();


  }







  Future<void> updateStatus(

      String taskId,

      String status,

      ) async {



    try{


      actingOnTaskId = taskId;

      notifyListeners();



      await repo.updateTaskStatus(

        taskId,

        status,

      );



    }


    finally{


      actingOnTaskId = null;

      notifyListeners();


    }


  }







  Future<void> accept(String id) async {


    await updateStatus(

      id,

      "accepted",

    );


  }






  Future<void> reject(String id) async {


    await updateStatus(

      id,

      "rejected",

    );


  }






  Future<void> markReached(String id) async {


    await updateStatus(

      id,

      "reached",

    );


  }







  @override

  void dispose(){


    subscription?.cancel();


    super.dispose();


  }


}