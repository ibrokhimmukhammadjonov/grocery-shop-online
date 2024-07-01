import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:grocery_shop_app/fetch_logout.dart';
import 'package:grocery_shop_app/fetch_screen.dart';
import 'package:grocery_shop_app/models/address_model.dart';
import 'package:grocery_shop_app/screens/address_screen.dart';
import 'package:grocery_shop_app/screens/route_right_to_left.dart';
import 'package:grocery_shop_app/screens/viewed_recently/viewed_recently.dart';
import 'package:grocery_shop_app/screens/wishlist/wishlist_screen.dart';
import 'package:grocery_shop_app/services/global_methods.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../consts/firebase_const.dart';
import '../providers/address_provider.dart';
import '../providers/user_provider.dart';
import '../provider/dark_theme_provider.dart';
import 'auth/forget_pass.dart';
import 'auth/login.dart';
import 'auth/placemark_map_object_page.dart';
import 'orders/orders_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:grocery_shop_app/services/globals.dart' as globals;


class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String? _address;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<UserProvider>(context, listen: false).fetchUserData(context));
  }

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    final Color color = themeState.getDarkTheme ? Colors.white : Colors.black;
    final userProvider = Provider.of<UserProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);
    final String? _name = userProvider.name;
    final String? _phone = userProvider.phone;
    _address = userProvider.address;


    return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Hi,  ',
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: _name ?? 'User',
                            style: TextStyle(
                              color: color,
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                print('My name is pressed');
                              }),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextWidget(
                    text: _phone ?? 'Phone',
                    color: color,
                    textSize: 18,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(
                    thickness: 2,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _listTiles(
                    title: 'Address',
                    subtitle: _address,
                    icon: IconlyLight.profile,
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        slideFromRightToLeftRoute(
                          AddressListScreen(),
                        ),
                      );

                      if (result != null && result is Point) {
                        print("::::::::::::::::::::::::::::::::::::::");
                        print(result);
                        final newAddress = await _getAddressFromLatLng(result);
                        setState(() {
                          _address = newAddress;
                        });
                        await addressProvider.updateAddress(newAddress as Address);
                      }
                    },
                    color: color,
                  ),
                  _listTiles(
                    title: 'Orders',
                    icon: IconlyLight.bag,
                    onPressed: () {
                      GlobalMethods.navigateTo(
                          ctx: context, routeName: OrdersScreen.routeName);
                    },
                    color: color,
                  ),
                  _listTiles(
                    title: 'Wishlist',
                    icon: IconlyLight.heart,
                    onPressed: () {
                      GlobalMethods.navigateTo(
                          ctx: context, routeName: WishlistScreen.routeName);
                    },
                    color: color,
                  ),
                  _listTiles(
                    title: 'Viewed',
                    icon: IconlyLight.show,
                    onPressed: () {
                      GlobalMethods.navigateTo(
                          ctx: context, routeName: ViewedRecentlyScreen.routeName);
                    },
                    color: color,
                  ),
                  _listTiles(
                    title: 'Forget password',
                    icon: IconlyLight.unlock,
                    onPressed: () {
                      GlobalMethods.navigateTo(
                          ctx: context, routeName: ForgetPasswordScreen.routeName);
                    },
                    color: color,
                  ),
                  _listTiles(
                    title: globals.userData == null ? 'Login' : 'Logout',
                    icon: userProvider.user == null
                        ? IconlyLight.login
                        : IconlyLight.logout,
                    onPressed: () async {
                      if (globals.userData == null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                        return;
                      }

                      bool? shouldLogout = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Logout'),
                          content: Text('Do you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false); // Cancel
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true); // Confirm
                              },
                              child: Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true) {
                        try {
                          await globals.signOut();
                          globals.userData = null;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const FetchScreenLogout(),
                            ),
                          );
                          Fluttertoast.showToast(
                            msg: "You successfully logged out",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                          );
                        } catch (error) {
                          GlobalMethods.errorDialog(
                            subtitle: error.toString(),
                            context: context,
                          );
                        }
                      }
                    },
                    color: color,
                  ),
                  SwitchListTile(
                    title: TextWidget(
                      text: themeState.getDarkTheme ? 'Dark mode' : 'Light mode',
                      color: color,
                      textSize: 24,
                    ),
                    secondary: Icon(themeState.getDarkTheme
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined),
                    onChanged: (bool value) {
                      setState(() {
                        themeState.setDarkTheme = value;
                      });
                    },
                    value: themeState.getDarkTheme,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _listTiles({
    required String title,
    String? subtitle,
    required IconData icon,
    required Function onPressed,
    required Color color,
  }) {
    return ListTile(
      title: TextWidget(
        text: title,
        color: color,
        textSize: 22,
      ),
      subtitle: TextWidget(
        text: subtitle ?? "",
        color: color,
        textSize: 18,
      ),
      leading: Icon(icon),
      trailing: const Icon(IconlyLight.arrowRight2),
      onTap: () {
        onPressed();
      },
    );
  }

  Future<String> _getAddressFromLatLng(Point position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return '${placemark.thoroughfare}, ${placemark.locality}, ${placemark.country}';
      }
    } catch (e) {
      print(e);
    }
    return 'Unknown location';
  }
}
