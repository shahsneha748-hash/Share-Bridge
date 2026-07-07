import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/volunteer_task_model.dart';
import '../viewmodel/volunteer_task_viewmodel.dart';


const _brandGreen = Color(0xFF3A5C2E);



class HistoryScreen extends StatelessWidget {

  const HistoryScreen({
    super.key,
  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: Colors.white,


      body: SafeArea(

        child: Consumer<VolunteerTaskViewModel>(

          builder: (context, vm, _) {


            if (vm.loading) {

              return const Center(

                child: CircularProgressIndicator(),

              );

            }



            final historyTasks = vm.pastTasks;



            if (historyTasks.isEmpty) {

              return const Center(

                child: Padding(

                  padding: EdgeInsets.all(24),


                  child: Column(

                    mainAxisAlignment:
                    MainAxisAlignment.center,


                    children: [


                      Icon(

                        Icons.history,

                        size: 70,

                        color: Colors.grey,

                      ),



                      SizedBox(height: 16),



                      Text(

                        "No delivery history",

                        style: TextStyle(

                          fontSize: 18,

                          fontWeight: FontWeight.bold,

                        ),

                      ),



                      SizedBox(height: 6),



                      Text(

                        "Completed and rejected tasks will appear here.",

                        textAlign: TextAlign.center,

                        style: TextStyle(

                          color: Colors.grey,

                        ),

                      ),


                    ],

                  ),

                ),

              );

            }




            return ListView.separated(


              padding: const EdgeInsets.all(16),


              itemCount: historyTasks.length,


              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),



              itemBuilder: (context, index) {


                return HistoryCard(

                  task: historyTasks[index],

                );


              },


            );

          },

        ),

      ),

    );

  }

}






class HistoryCard extends StatelessWidget {


  final VolunteerTaskModel task;



  const HistoryCard({

    super.key,

    required this.task,

  });




  @override
  Widget build(BuildContext context) {


    final completed =
        task.status.toLowerCase()
            ==
            "completed";



    return Card(


      elevation: 2,


      shape: RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(14),

      ),



      child: Padding(


        padding:
        const EdgeInsets.all(14),



        child: Column(


          crossAxisAlignment:
          CrossAxisAlignment.start,



          children: [



            Row(


              children: [


                Icon(


                  completed
                      ? Icons.check_circle
                      : Icons.cancel,


                  color: completed
                      ? _brandGreen
                      : Colors.red,


                  size: 22,


                ),



                const SizedBox(width: 8),




                Text(


                  completed
                      ? "Completed"
                      : "Rejected",



                  style: TextStyle(


                    fontWeight:
                    FontWeight.bold,



                    color: completed
                        ? _brandGreen
                        : Colors.red,


                  ),

                ),




                const Spacer(),




                if (task.respondedAt != null)

                  Text(


                    "${task.respondedAt!.day}/"
                        "${task.respondedAt!.month}/"
                        "${task.respondedAt!.year}",



                    style: const TextStyle(

                      color: Colors.grey,

                      fontSize: 12,

                    ),

                  ),


              ],


            ),




            const SizedBox(height: 14),




            _detailRow(

              "Item",

              task.itemName.isEmpty
                  ? "Donation item"
                  : task.itemName,

            ),




            _detailRow(

              "Pickup",

              task.pickupAddress,

            ),




            _detailRow(

              "Drop",

              task.dropAddress,

            ),




            _detailRow(

              "Receiver",

              task.receiverName.isEmpty
                  ? "Unknown"
                  : task.receiverName,

            ),




          ],


        ),


      ),


    );

  }






  Widget _detailRow(

      String title,

      String value,

      ) {


    return Padding(

      padding:
      const EdgeInsets.only(bottom: 8),


      child: Row(


        crossAxisAlignment:
        CrossAxisAlignment.start,


        children: [



          Text(

            "$title: ",

            style:
            const TextStyle(

              fontWeight:
              FontWeight.bold,

              fontSize: 13,

            ),

          ),




          Expanded(

            child: Text(

              value,

              style:
              const TextStyle(

                fontSize: 13,

              ),

            ),

          ),


        ],


      ),


    );


  }


}