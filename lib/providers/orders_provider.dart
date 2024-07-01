import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_shop_app/models/order_model.dart';
import 'package:grocery_shop_app/services/globals.dart' as globals;

class OrdersProvider with ChangeNotifier {
  static List<OrderModel> _orders = [];

  List<OrderModel> get getOrders {
    return _orders;
  }

  Future<void> fetchOrders() async {
    try {
      final Map<String, dynamic>? userData = globals.userData;
      if (userData == null) {
        return;
      }

      final String? userId = userData['id'] as String?;
      if (userId == null) {
        return;
      }

      await FirebaseFirestore.instance
          .collection('orders')
          .where("userId", isEqualTo: userId)
      //.orderBy('orderDate', descending: false)
          .get()
          .then((QuerySnapshot ordersSnapshot) {
        _orders = [];
        ordersSnapshot.docs.forEach((element) {
          _orders.insert(
            0,
            OrderModel(
              orderId: element.get('orderId'),
              userId: element.get('userId'),
              productId: element.get('productId'),
              userName: element.get('userName'),
              price: element.get('price').toString(),
              imageUrl: element.get('imageUrl'),
              quantity: element.get('quantity').toString(),
              orderDate: element.get('orderDate'),
            ),
          );
        });
      });
      notifyListeners();
    } catch (e) {
      print('Error From Firebase $e');
    }
  }

  void clearLocalOrder() {
    _orders.clear();
    notifyListeners();
  }
}
