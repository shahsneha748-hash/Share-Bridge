class AdminVolunteerModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String availability;
  final String citizenshipNumber;
  final String citizenshipImage;
  final String selfieImage;
  final String vehicle;
  final String status;
  final String submittedAt;

  AdminVolunteerModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.availability,
    required this.citizenshipNumber,
    required this.citizenshipImage,
    required this.selfieImage,
    required this.vehicle,
    required this.status,
    required this.submittedAt,
  });

  factory AdminVolunteerModel.fromMap(
      Map<String, dynamic> map,
      String docId, {
        required String name,
        required String email,
        required String phone,
        required String address,
      }) {
    return AdminVolunteerModel(
      id: docId,
      userId: map['userId'] ?? '',
      name: name,
      email: email,
      phone: phone,
      address: address,
      availability: map['availability'] ?? 'N/A',
      citizenshipNumber: map['citizenshipNumber'] ?? 'N/A',
      citizenshipImage: map['citizenshipImage'] ?? '',
      selfieImage: map['selfieImage'] ?? '',
      vehicle: map['vehicle'] ?? 'N/A',
      status: map['status'] ?? 'Pending',
      submittedAt: map['submittedAt'] ?? '',
    );
  }
}