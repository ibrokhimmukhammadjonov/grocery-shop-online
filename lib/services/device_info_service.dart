import 'package:flutter/services.dart';
import 'package:device_id_info/device_id_info.dart';
import 'package:flutter/material.dart';

class DeviceInfoService with ChangeNotifier {
  String? _deviceId;
  final _deviceIdInfoPlugin = DeviceIdInfo("com.appromobile.Hotel");

  String? get deviceId => _deviceId;

  Future<void> initDeviceId() async {
    try {
      _deviceId = await _deviceIdInfoPlugin.getDeviceId();
      print("Device ID: $_deviceId");
    } on PlatformException {
      _deviceId = 'Failed to get platform version.';
    }

    notifyListeners();
  }
}