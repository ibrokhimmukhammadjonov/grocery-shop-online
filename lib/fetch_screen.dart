import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grocery_shop_app/providers/cart_provider.dart';
import 'package:grocery_shop_app/providers/orders_provider.dart';
import 'package:grocery_shop_app/providers/wishlist_provider.dart';
import 'package:grocery_shop_app/screens/btm_bar.dart';
import 'package:provider/provider.dart';
import 'package:grocery_shop_app/services/globals.dart' as globals;
import '../providers/products_provider.dart';
import '../providers/user_provider.dart';
import '../providers/account_provider.dart';

class FetchScreen extends StatefulWidget {
  const FetchScreen({Key? key}) : super(key: key);

  @override
  State<FetchScreen> createState() => _FetchScreenState();
}

class _FetchScreenState extends State<FetchScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final wishListProvider = Provider.of<WishlistProvider>(context, listen: false);
      final orderProvider = Provider.of<OrdersProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final accountProvider = Provider.of<AccountProvider>(context, listen: false);

      if (globals.userData == null) {
        globals.userData = await accountProvider.userData;
        print('User data fetched from accountProvider:');
      } else {
        print('User already logged in:');
      }
      print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
      print(globals.userData);
      print('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
      await productsProvider.fetchProducts();

      Map<String, dynamic>? userData = globals.userData;

      if (userData == null) {
        cartProvider.clearLocalCart();
        wishListProvider.clearLocalWishlist();
        orderProvider.clearLocalOrder();
        userProvider.resetUser();
      } else {
        await accountProvider.fetchAccounts(context);
        await cartProvider.fetchCart();
        await wishListProvider.fetchWishlist();
        await orderProvider.fetchOrders();
        //await userProvider.fetchUserData(context);
      }

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (ctx) => const BottomBarScreen(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/landing/buyfood.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          const Center(
            child: SpinKitFadingFour(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
