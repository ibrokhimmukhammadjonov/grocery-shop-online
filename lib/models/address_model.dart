import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  final String id;
  final String userId;
  final String name;
  final String address;
  final GeoPoint location;

  Address({required this.id, required this.userId, required this.name, required this.address, required this.location});

  factory Address.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Address(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      location: data['location'] ?? GeoPoint(0, 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'address': address,
      'location': location,
    };
  }
}
