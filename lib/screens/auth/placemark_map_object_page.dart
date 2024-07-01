import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../../consts/firebase_const.dart';
import '../../fetch_screen.dart';
import '../../models/address_model.dart';
import '../../services/device_info_service.dart';
import '../../services/global_methods.dart';
import '../route_right_to_left.dart';


class LocationPickerPage extends StatefulWidget {
  final String? name;
  final Address? address;

  const LocationPickerPage({Key? key, this.name, this.address}) : super(key: key);
  static const routeName = '/LocationPickerPage';

  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late YandexMapController _mapController;
  late Point _selectedLocation;
  bool _isLoading = false;
  String _address = '';

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.address != null
        ? Point(
      latitude: widget.address!.location.latitude,
      longitude: widget.address!.location.longitude,
    )
        : Point(latitude: 41.311151, longitude: 69.279737); // Default location

    if (widget.address != null) {
      _address = widget.address!.address;
    } else {
      _determinePosition();
    }
  }

  Future<void> _determinePosition() async {
    // Assume that you have permission and location services are enabled
    // Add your logic to get the current user's location
    // For now, we use a hardcoded point
    Point currentUserLocation = Point(latitude: 41.311151, longitude: 69.279737); // Example coordinates

    if (mounted) {
      setState(() {
        _selectedLocation = currentUserLocation;
        _getAddressFromLatLng(_selectedLocation);
      });
    }
  }

  Future<void> _getAddressFromLatLng(Point position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String newAddress = '${placemark.thoroughfare}, ${placemark.locality}, ${placemark.country}';
        if (mounted) {
          setState(() {
            _address = newAddress;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _onMapCreated(YandexMapController controller) {
    _mapController = controller;
    _mapController.moveCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: _selectedLocation)),
    );
  }

  void _onCameraPositionChanged(CameraPosition cameraPosition, CameraUpdateReason reason, bool finished) {
    if (finished && mounted) {
      setState(() {
        _selectedLocation = cameraPosition.target;
        _getAddressFromLatLng(_selectedLocation);
      });
    }
  }

  void _confirmSelection() async {
    final deviceInfoService = Provider.of<DeviceInfoService>(context, listen: false);
    await deviceInfoService.initDeviceId();
    final String? deviceId = deviceInfoService.deviceId;
    if (widget.name != null) {
      Navigator.pop(context, _selectedLocation);

      if (_selectedLocation != null) {
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }

        try {
          final User? user = authInstance.currentUser;
          final String _uid = user!.uid;

          await FirebaseFirestore.instance.collection('users').doc(_uid).set({
            'id': _uid,
            'name': widget.name,
            'phone': user.phoneNumber,
            'shipping-address': GeoPoint(_selectedLocation.latitude, _selectedLocation.longitude),
            'userWish': [],
            'userCart': [],
            'createdAt': Timestamp.now(),
          });

          await FirebaseFirestore.instance.collection('account').doc(_uid).set({
            'uId': _uid,
            'deviceId': deviceId,
            'name': widget.name,
            'phoneNumber': user.phoneNumber,
          });

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const FetchScreen(),
            ),
          );
        } on FirebaseException catch (error) {
          if (mounted) {
            GlobalMethods.errorDialog(
              subtitle: '${error.message}',
              context: context, // Use the parent context
            );
          }
        } catch (error) {
          if (mounted) {
            GlobalMethods.errorDialog(
              subtitle: '$error',
              context: context, // Use the parent context
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          GlobalMethods.errorDialog(
            subtitle: 'No location selected.',
            context: context, // Use the parent context
          );
        }
      }
    } else {
      if (mounted) {
        final User? user = authInstance.currentUser;
        final address = Address(
          id: widget.address?.id ?? '',
          userId: user!.uid,
          name: widget.address?.name ?? '',
          address: _address,
          location: GeoPoint(_selectedLocation.latitude, _selectedLocation.longitude),
        );
        Navigator.pop(context, address);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () => _confirmSelection(),
          ),
        ],
      ),
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: _onMapCreated,
            onCameraPositionChanged: _onCameraPositionChanged,
          ),
          Center(
            child: Icon(Icons.location_pin, color: Colors.red, size: 50),
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.white,
              child: Text(
                _address,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
