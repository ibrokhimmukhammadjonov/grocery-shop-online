import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_shop_app/services/global_methods.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:grocery_shop_app/services/globals.dart' as globals;

class UserProvider with ChangeNotifier {
  User? _user;
  String? _phone;
  String? _name;
  String? _address;

  User? get user => _user;
  String? get phone => _phone;
  String? get name => _name;
  String? get address => _address;

  Future<void> fetchUserData(BuildContext context) async {
    try {
      final Map<String, dynamic>? userData = globals.userData;
      if (userData == null) {
        return;
      }
      String _uid = userData['id'];
      final DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      if (userDoc.exists) {
        _phone = userDoc.get('phone');
        _name = userDoc.get('name');
        GeoPoint geoPoint = userDoc.get('shipping-address');
        _address = await _getAddressFromCoordinates(
            geoPoint.latitude, geoPoint.longitude);
        notifyListeners();
      }
    } catch (error) {
      GlobalMethods.errorDialog(subtitle: error.toString(), context: context);
    }
  }


  Future<String> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    String apiKey = '85213841-5f80-412e-8745-506770a7e75b';
    String url =
        'https://geocode-maps.yandex.ru/1.x/?format=json&apikey=$apiKey&geocode=$longitude,$latitude';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final address = data['response']['GeoObjectCollection']['featureMember'][0]['GeoObject']['metaDataProperty']['GeocoderMetaData']['text'];
      return address;
    } else {
      throw Exception('Failed to load address');
    }
  }

  void resetUser() {
    _phone = null;
    _name = null;
    _address = null;
    globals.userData = null;
    notifyListeners();
  }
}
