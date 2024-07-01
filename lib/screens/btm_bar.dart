import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:grocery_shop_app/providers/cart_provider.dart';
import 'package:grocery_shop_app/screens/account_list_screen.dart';
import 'package:grocery_shop_app/screens/cart/cart_screen.dart';
import 'package:grocery_shop_app/screens/categories.dart';
import 'package:grocery_shop_app/screens/home_screen.dart';
import 'package:grocery_shop_app/screens/user.dart';
import 'package:grocery_shop_app/services/globals.dart' as globals;
import 'package:grocery_shop_app/widgets/text_widget.dart';
import 'package:badges/badges.dart' as badges;

import '../provider/dark_theme_provider.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({Key? key}) : super(key: key);

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {'page': const HomeScreen(), 'title': 'Home'},
    {'page': CategoriesScreen(), 'title': 'Categories'},
    {'page': const CartScreen(), 'title': 'Cart'},
    {'page': const UserScreen(), 'title': 'User'},
  ];

  Future<void> _selectedPage(int index) async {
    if (index == 3) {
      var userData = globals.userData;
      if (userData == null) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AccountListScreen(),
        ));
      } else {
        setState(() {
          _selectedIndex = index;
        });
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    bool _isDark = themeState.getDarkTheme;
    return Scaffold(
      body: _pages[_selectedIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _isDark ? Theme.of(context).cardColor : Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        unselectedItemColor: _isDark ? Colors.white24 : Colors.black45,
        selectedItemColor: _isDark ? Colors.lightBlue.shade200 : Colors.black87,
        onTap: _selectedPage,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 0 ? IconlyBold.home : IconlyLight.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 1 ? IconlyBold.category : IconlyLight.category),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (_, myCart, ch) {
                return badges.Badge(
                  badgeAnimation: const badges.BadgeAnimation.slide(
                    toAnimate: true,
                    animationDuration: Duration(seconds: 1),
                  ),
                  showBadge: true,
                  position: badges.BadgePosition.topEnd(top: -7, end: -7),
                  badgeContent: FittedBox(
                    child: TextWidget(
                      text: myCart.getCartItems.length.toString(),
                      color: Colors.white,
                      textSize: 15,
                    ),
                  ),
                  child: Icon(_selectedIndex == 2 ? IconlyBold.buy : IconlyLight.buy),
                );
              },
            ),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 3 ? IconlyBold.user2 : IconlyLight.user2),
            label: "User",
          ),
        ],
      ),
    );
  }
}
