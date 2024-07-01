import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';
import 'package:grocery_shop_app/services/globals.dart' as globals;

class AddressProvider extends ChangeNotifier {
  var _user;
  List<Address> _addresses = [];

  List<Address> get addresses => _addresses;

  Future<void> fetchAddresses() async {
    try {
      _user = globals.userData;
      if (_user == null) {
        return;
      }
      String userId = _user!['id'];
      _addresses = await FirestoreService().fetchAddresses(userId);
      print(_addresses);
      print("}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}");
      notifyListeners();
    } catch (error) {
      print('Error fetching addresses: $error');
    }
  }

  Future<void> addAddress(Address address) async {
    await FirestoreService().addAddress(address);
    await fetchAddresses();
  }

  Future<void> updateAddress(Address address) async {
    await FirestoreService().updateAddress(address);
    await fetchAddresses();
  }

  Future<void> deleteAddress(String addressId) async {
    await FirestoreService().deleteAddress(addressId);
    await fetchAddresses();
  }

  Future<void> updateUserShippingAddress(Address address) async {
    try {
      _user = globals.userData;
      if (_user == null) {
        return;
      }
      String userId = _user!['id'];
      await FirestoreService().updateUserShippingAddress(userId, address);
      notifyListeners();
    } catch (error) {
      print('Error updating user shipping address: $error');
    }
  }
}
