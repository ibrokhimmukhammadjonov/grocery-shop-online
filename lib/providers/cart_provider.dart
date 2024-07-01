import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:grocery_shop_app/models/cart_model.dart';
import 'package:grocery_shop_app/services/globals.dart' as globals;

class CartProvider with ChangeNotifier {
  Map<String, CartModel> _cartItems = {};

  Map<String, CartModel> get getCartItems {
    return _cartItems;
  }

  final userCollection = FirebaseFirestore.instance.collection('users');
  final productsCollection = FirebaseFirestore.instance.collection('products');

  Future<void> fetchCart() async {
    var user = globals.userData;

    final DocumentSnapshot userDoc = await userCollection.doc(user!['id']).get();
    if (!userDoc.exists) {
      return;
    }
    final leng = userDoc.get('userCart').length;
    for (int i = 0; i < leng; i++) {
      _cartItems.putIfAbsent(
          userDoc.get('userCart')[i]['productId'],
              () => CartModel(
            id: userDoc.get('userCart')[i]['cartId'],
            productId: userDoc.get('userCart')[i]['productId'],
            quantity: userDoc.get('userCart')[i]['quantity'],
          ));
    }
    notifyListeners();
  }

  Future<double> getTotalPrice() async {
    var user = globals.userData;
    double totalPrice = 0.0;
    final DocumentSnapshot userDoc = await userCollection.doc(user!['id']).get();

    if (!userDoc.exists) {
      return 0;
    }

    final leng = userDoc.get('userCart').length;
    for (int i = 0; i < leng; i++) {
      String productId = userDoc.get('userCart')[i]['productId'];
      int quantity = userDoc.get('userCart')[i]['quantity'];
      double productPrice = await getProductPriceById(productId);
      totalPrice += (productPrice * quantity);
    }

    return totalPrice;
  }

  Future<double> getProductPriceById(String productId) async {
    final DocumentSnapshot productDoc = await productsCollection.doc(productId).get();
    if (productDoc.exists) {
      if (productDoc.get('isOnSale') == true) {
        return productDoc.get('salePrice').toDouble();
      }else{
        return productDoc.get('price').toDouble();
      }
    }
    return 0.0;
  }

  void reduceQuantityByOne(String productId) {
    _cartItems.update(
      productId,
          (value) => CartModel(
        id: value.id,
        productId: productId,
        quantity: value.quantity - 1,
      ),
    );

    notifyListeners();
  }

  void increaseQuantityByOne(String productId) {
    _cartItems.update(
      productId,
          (value) => CartModel(
        id: value.id,
        productId: productId,
        quantity: value.quantity + 1,
      ),
    );
    notifyListeners();
  }

  Future<void> removeOneItem(
      {required String cartId,
        required String productId,
        required int quantity}) async {
    var user = globals.userData;
    await userCollection.doc(user!['id']).update({
      'userCart': FieldValue.arrayRemove([
        {'cartId': cartId, 'productId': productId, 'quantity': quantity}
      ])
    });
    _cartItems.remove(productId);
    await fetchCart();
    notifyListeners();
  }

  Future<void> clearOnlineCart() async {
    var user = globals.userData;
    await userCollection.doc(user!['id']).update({
      'userCart': [],
    });
    _cartItems.clear();
    notifyListeners();
  }

  void clearLocalCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
