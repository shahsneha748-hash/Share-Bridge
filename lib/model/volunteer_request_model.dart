import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerRequestModel {

  String requestId;

  String donationId;
  String donorId;
  String donorName;

  String receiverId;
  String receiverName;

  String pickupLocation;
  String deliveryLocation;

  String itemName;

  String? vehicle;
  String? preferredTime;

  String status;

  String? assignedVolunteerId;

  DateTime? createdAt;


  VolunteerRequestModel({

    this.requestId = '',

    required this.donationId,
    required this.donorId,
    required this.donorName,

    required this.receiverId,
    required this.receiverName,

    required this.pickupLocation,
    required this.deliveryLocation,

    required this.itemName,

    this.vehicle,
    this.preferredTime,

    this.status = "pending",

    this.assignedVolunteerId,
    this.createdAt,

  });



  factory VolunteerRequestModel.fromMap(
      Map<String,dynamic> map,
      String id,
      ){

    return VolunteerRequestModel(

      requestId: id,

      donationId: map['donationId'] ?? '',

      donorId: map['donorId'] ?? '',

      donorName: map['donorName'] ?? '',


      receiverId: map['receiverId'] ?? '',

      receiverName: map['receiverName'] ?? '',


      pickupLocation:
      map['pickupLocation'] ?? '',


      deliveryLocation:
      map['deliveryLocation'] ?? '',


      itemName:
      map['itemName'] ?? '',


      vehicle:
      map['vehicle'],


      preferredTime:
      map['preferredTime'],


      status:
      map['status'] ?? "pending",


      assignedVolunteerId:
      map['assignedVolunteerId'],

      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,

    );

  }



  Map<String,dynamic> toMap(){

    return {


      'donationId': donationId,

      'donorId': donorId,

      'donorName': donorName,


      'receiverId': receiverId,

      'receiverName': receiverName,


      'pickupLocation':
      pickupLocation,


      'deliveryLocation':
      deliveryLocation,


      'itemName':
      itemName,


      'vehicle':
      vehicle,


      'preferredTime':
      preferredTime,


      'status':
      status,


      'assignedVolunteerId':
      assignedVolunteerId,

      'createdAt': createdAt,


    };

  }

}