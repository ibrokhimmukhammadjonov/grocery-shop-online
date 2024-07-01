import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address_model.dart';

class FirestoreService {
  final CollectionReference _addressCollection = FirebaseFirestore.instance.collection('addresses');
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');

  Future<List<Address>> fetchAddresses(String userId) async {
    QuerySnapshot snapshot = await _addressCollection.where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => Address.fromFirestore(doc)).toList();
  }

  Future<void> addAddress(Address address) async {
    await _addressCollection.add(address.toFirestore());
  }

  Future<void> updateAddress(Address address) async {
    await _addressCollection.doc(address.id).update(address.toFirestore());
  }

  Future<void> deleteAddress(String addressId) async {
    await _addressCollection.doc(addressId).delete();
  }

  Future<void> updateUserShippingAddress(String userId, Address address) async {
    await _userCollection.doc(userId).update({
      'shipping-address': address.location,
    });
  }
}
