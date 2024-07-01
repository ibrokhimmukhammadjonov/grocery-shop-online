import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String id;
  final String deviceId;
  final String uId;
  final String name;
  final String phoneNumber;

  Account({required this.id, required this.deviceId, required this.uId, required this.name, required this.phoneNumber});


  factory Account.fromFirestore(DocumentSnapshot doc) {

    Map data = doc.data() as Map;
    return Account(
      id: doc.id,
      deviceId: data['deviceId'],
      uId: data['uId'] ?? '',
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uId': uId,
      'deviceId': deviceId,
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }


}
