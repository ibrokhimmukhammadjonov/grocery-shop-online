import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:grocery_shop_app/models/wishlist_model.dart';
import 'package:grocery_shop_app/services/globals.dart' as globals;

class WishlistProvider with ChangeNotifier {
  Map<String, WishlistModel> _wishlistItems = {};

  Map<String, WishlistModel> get getWishlistItems {
    return _wishlistItems;
  }

  final userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> fetchWishlist() async {
    final Map<String, dynamic>? userData = globals.userData;
    if (userData == null) {
      return;
    }

    final String? userId = userData['id'] as String?;
    if (userId == null) {
      return;
    }

    final DocumentSnapshot userDoc = await userCollection.doc(userId).get();

    if (!userDoc.exists) {
      return;
    }

    final userWish = userDoc.get('userWish') as List<dynamic>;
    for (var wishItem in userWish) {
      _wishlistItems.putIfAbsent(
        wishItem['productId'],
            () => WishlistModel(
          id: wishItem['wishlistId'],
          productId: wishItem['productId'],
        ),
      );
    }
    notifyListeners();
  }

  Future<void> removeOneItem({
    required String wishlistId,
    required String productId,
  }) async {
    final Map<String, dynamic>? userData = globals.userData;
    final String? userId = userData?['id'] as String?;
    if (userId == null) {
      return;
    }

    await userCollection.doc(userId).update({
      'userWish': FieldValue.arrayRemove([
        {
          'wishlistId': wishlistId,
          'productId': productId,
        }
      ])
    });

    _wishlistItems.remove(productId);
    await fetchWishlist();
    notifyListeners();
  }

  Future<void> clearOnlineWishlist() async {
    final Map<String, dynamic>? userData = globals.userData;
    final String? userId = userData?['id'] as String?;
    if (userId == null) {
      return;
    }

    await userCollection.doc(userId).update({
      'userWish': [],
    });

    _wishlistItems.clear();
    notifyListeners();
  }

  void clearLocalWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }
}
