import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_shop_app/models/account.dart';
import 'package:provider/provider.dart';
import '../services/device_info_service.dart';

class AccountProvider with ChangeNotifier {
  List<Account> _accounts = [];
  Account? _currentAccount;
  Map<String, dynamic>? _userData;

  List<Account> get accounts => _accounts;
  Account? get currentAccount => _currentAccount;
  Map<String, dynamic>? get userData => _userData;


  void setUserData(Map<String, dynamic>? data) {
    _userData = data;
    notifyListeners();
  }

  AuthProvider() {
    // Initialize the accounts list when the provider is instantiated
  }

  Future<void> fetchAccounts(BuildContext context) async {
    try {
      final deviceInfoService = Provider.of<DeviceInfoService>(context, listen: false);
      await deviceInfoService.initDeviceId();
      final String? deviceId = deviceInfoService.deviceId;

      if (deviceId != null) {
        // Fetch accounts from Firestore where deviceId matches the current device ID
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('account')
            .where('deviceId', isEqualTo: deviceId)
            .get();

        _accounts = querySnapshot.docs.map((doc) => Account.fromFirestore(doc)).toList();
        notifyListeners();
      } else {
        print('Device ID is null');
      }
    } catch (e) {
      print('Error fetching accounts: $e');
      // Handle error scenario
    }
  }

  void addAccount(Account account) {
    _accounts.add(account);
    notifyListeners();
  }

  void removeAccount(Account account) {
    _accounts.remove(account);
    notifyListeners();
  }

  Future<void> login(Account account) async {
    _currentAccount = account;

    print(account.phoneNumber);
    // Fetch user data based on the account phone number
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: account.phoneNumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Store fetched user data in the provider
      _userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      _userData = null;
    }

    notifyListeners();
  }

  void logout() {
    _currentAccount = null;
    _userData = null;
    notifyListeners();
  }
}
