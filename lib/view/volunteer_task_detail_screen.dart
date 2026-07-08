import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/volunteer_task_model.dart';
import '../viewmodel/volunteer_task_viewmodel.dart';


class TaskDetailScreen extends StatelessWidget {

  final VolunteerTaskModel task;


  const TaskDetailScreen({
    super.key,
    required this.task,
  });



  @override
  Widget build(BuildContext context) {


    final viewModel =
    context.read<VolunteerTaskViewModel>();



    final status =
    task.status.toLowerCase();



    return Scaffold(


      appBar: AppBar(

        title: const Text(
          "Task Details",
        ),

        backgroundColor:
        const Color(0xFF3A5C2E),

        foregroundColor:
        Colors.white,

      ),




      body: Padding(

        padding:
        const EdgeInsets.all(16),


        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children: [



            // Item Image

            if(task.itemImage.isNotEmpty)

              ClipRRect(

                borderRadius:
                BorderRadius.circular(12),


                child: Image.network(

                  task.itemImage,

                  height:200,

                  width:
                  double.infinity,


                  fit:
                  BoxFit.cover,

                ),

              ),



            const SizedBox(height:20),




            // Item name

            Text(

              task.itemName.isEmpty
                  ? "Donation Item"
                  : task.itemName,


              style:
              const TextStyle(

                fontSize:24,

                fontWeight:
                FontWeight.bold,

              ),

            ),




            const SizedBox(height:20),




            _infoRow(

              "Pickup Location",

              task.pickupAddress,

            ),




            _infoRow(

              "Delivery Location",

              task.dropAddress,

            ),




            _infoRow(

              "Receiver",

              task.receiverName.isEmpty
                  ? "Not provided"
                  : task.receiverName,

            ),




            const SizedBox(height:20),




            Container(

              width:
              double.infinity,


              padding:
              const EdgeInsets.all(12),


              decoration:
              BoxDecoration(

                color:
                Colors.orange.shade100,


                borderRadius:
                BorderRadius.circular(12),

              ),


              child: Text(

                "Status: ${task.status}",


                style:
                const TextStyle(

                  fontWeight:
                  FontWeight.bold,

                ),

              ),

            ),




            const Spacer(),




            // Pending -> Accept

            if(status == "pending")

              _actionButton(

                context,

                viewModel,

                "Accept Task",

                "Accepted",

              ),





            // Accepted -> Start

            if(status == "accepted")

              _actionButton(

                context,

                viewModel,

                "Start Delivery",

                "InProgress",

              ),





            // InProgress -> Reached

            if(status == "inprogress")

              _actionButton(

                context,

                viewModel,

                "Mark Reached",

                "Reached",

              ),




            // Reached waiting

            if(status == "reached")

              const Center(

                child: Text(

                  "Waiting for receiver confirmation",

                  style:
                  TextStyle(

                    color:
                    Colors.grey,

                  ),

                ),

              ),



            // Completed

            if(status == "completed")

              const Center(

                child: Text(

                  "Task Completed",

                  style:
                  TextStyle(

                    color:
                    Colors.green,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),

              ),



          ],

        ),

      ),

    );

  }






  Widget _actionButton(

      BuildContext context,

      VolunteerTaskViewModel viewModel,

      String title,

      String newStatus,

      ){


    return SizedBox(

      width:
      double.infinity,


      child:
      ElevatedButton(


        style:
        ElevatedButton.styleFrom(

          backgroundColor:
          const Color(0xFF3A5C2E),


          foregroundColor:
          Colors.white,

        ),



        onPressed: () async {


          await viewModel.updateStatus(

            task.taskId,

            newStatus,

          );



          if(context.mounted){

            Navigator.pop(context);

          }


        },


        child:
        Text(title),


      ),

    );


  }






  Widget _infoRow(

      String title,

      String value,

      ){


    return Padding(

      padding:
      const EdgeInsets.only(

        bottom:10,

      ),


      child:
      Row(

        crossAxisAlignment:
        CrossAxisAlignment.start,


        children:[


          Text(

            "$title: ",

            style:
            const TextStyle(

              fontWeight:
              FontWeight.bold,

            ),

          ),



          Expanded(

            child:
            Text(value),

          )


        ],


      ),

    );


  }


}