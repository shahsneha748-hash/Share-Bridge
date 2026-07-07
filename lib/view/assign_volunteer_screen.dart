import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/create_donation_model.dart';
import '../model/volunteer_request_model.dart';
import '../viewmodel/volunteer_request_viewmodel.dart';

class AssignVolunteerScreen extends StatefulWidget {

  final CreateDonationModel donation;
  final String receiverName;
  final String receiverAddress;
  final String receiverId;

  const AssignVolunteerScreen({
    super.key,
    required this.donation,
    required this.receiverName,
    required this.receiverAddress,
    required this.receiverId,
  });

  @override
  State<AssignVolunteerScreen> createState() =>
      _AssignVolunteerScreenState();
}


class _AssignVolunteerScreenState
    extends State<AssignVolunteerScreen> {


  String? selectedVehicle;
  String? selectedTime;


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF3A5C2E),
        title: const Text(
          "Assign Volunteer",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),


      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [


            const Text(
              "Delivery Request",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),


            const SizedBox(height: 15),



            _infoCard(
              "Donation Item",
              widget.donation.itemName,
            ),


            _infoCard(
              "Receiver",
              widget.receiverName,
            ),


            _infoCard(
              "Delivery Location",
              widget.receiverAddress,
            ),



            const SizedBox(height: 20),



            const Text(
              "Pickup Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),



            const SizedBox(height: 10),



            DropdownButtonFormField<String>(

              decoration: InputDecoration(

                labelText: "Preferred Vehicle",

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

              ),


              items: [
                "Bike",
                "Car",
                "Walking",
                "Scooter"
              ]
                  .map(
                    (e)=>DropdownMenuItem(
                  value:e,
                  child:Text(e),
                ),
              )
                  .toList(),


              onChanged:(value){

                setState(() {
                  selectedVehicle=value;
                });

              },

            ),



            const SizedBox(height:15),



            DropdownButtonFormField<String>(

              decoration: InputDecoration(

                labelText:"Preferred Delivery Time",

                border:OutlineInputBorder(
                  borderRadius:BorderRadius.circular(12),
                ),

              ),


              items:[
                "Morning",
                "Afternoon",
                "Evening"
              ]
                  .map(
                    (e)=>DropdownMenuItem(
                  value:e,
                  child:Text(e),
                ),
              )
                  .toList(),


              onChanged:(value){

                setState(() {
                  selectedTime=value;
                });

              },

            ),



            const SizedBox(height:25),



            SizedBox(

              width:double.infinity,

              child:ElevatedButton(

                style:ElevatedButton.styleFrom(

                  backgroundColor:
                  const Color(0xFF3A5C2E),

                  padding:
                  const EdgeInsets.symmetric(
                    vertical:15,
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),

                ),


                onPressed: () async {


                  final vm = context.read<VolunteerRequestViewModel>();


                  final request = VolunteerRequestModel(

                    donationId: widget.donation.userId + widget.donation.itemName,
                    donorId: widget.donation.donorId,

                    donorName: widget.donation.donorName,


                    receiverId: widget.receiverId,

                    receiverName: widget.receiverName,


                    pickupLocation:
                    widget.donation.location,


                    deliveryLocation:
                    widget.receiverAddress,


                    itemName:
                    widget.donation.itemName,


                    vehicle:
                    selectedVehicle,


                    preferredTime:
                    selectedTime,


                  );



                  try {


                    await vm.createRequest(request);



                    if(!context.mounted) return;


                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      const SnackBar(

                        content:
                        Text(
                          "Volunteer request sent",

                        ),

                      ),

                    );


                    Navigator.pop(context);



                  }

                  catch(e){


                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      SnackBar(

                        content:
                        Text(
                          e.toString(),
                        ),

                      ),

                    );


                  }


                },


                child:const Text(

                  "Find Volunteer",

                  style:TextStyle(
                    color:Colors.white,
                    fontSize:16,
                    fontWeight:FontWeight.bold,
                  ),

                ),

              ),

            ),


          ],

        ),

      ),

    );

  }



  Widget _infoCard(String title,String value){

    return Container(

      width:double.infinity,

      margin:
      const EdgeInsets.only(bottom:10),

      padding:
      const EdgeInsets.all(14),


      decoration:BoxDecoration(

        color:
        const Color(0xFFF6F8F1),

        borderRadius:
        BorderRadius.circular(14),

      ),


      child:Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,


        children:[


          Text(

            title,

            style:
            const TextStyle(

              color:Colors.grey,

              fontSize:12,

            ),

          ),



          const SizedBox(height:5),



          Text(

            value,

            style:
            const TextStyle(

              fontSize:16,

              fontWeight:
              FontWeight.bold,

            ),

          ),


        ],

      ),

    );

  }


}