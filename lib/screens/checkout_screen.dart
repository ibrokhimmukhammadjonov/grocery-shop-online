import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:grocery_shop_app/providers/cart_provider.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';
import 'package:grocery_shop_app/services/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/cart_model.dart';
import '../providers/orders_provider.dart';
import '../providers/products_provider.dart';
import '../services/global_methods.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'Cash';
  String _promoCode = '';
  double _deliveryPrice = 5.0;
  double _servicePrice = 2.0;
  double _totalPrice = 0.0;
  String _userAddress = '';

  @override
  void initState() {
    super.initState();
    _calculateTotalPrice();
    _getUserAddress();
  }

  Future<void> _getUserAddress() async {
    var userData = globals.userData;
    if (userData != null && userData['shipping-address'] != null) {
      GeoPoint position = userData['shipping-address'];
      await _getAddressFromLatLng(position);
    }
  }

  Future<void> _getAddressFromLatLng(GeoPoint geopoint) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        geopoint.latitude,
        geopoint.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String newAddress = '${placemark.thoroughfare}, ${placemark.locality}, ${placemark.country}';
        if (mounted) {
          setState(() {
            _userAddress = newAddress;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _calculateTotalPrice() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    double cartTotal = await cartProvider.getTotalPrice();
    setState(() {
      _totalPrice = cartTotal + _deliveryPrice + _servicePrice;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchCartItemsWithPrices() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItems = cartProvider.getCartItems;
    List<Map<String, dynamic>> itemsWithPrices = [];

    for (String key in cartItems.keys) {
      CartModel cartItem = cartItems[key]!;
      double productPrice = await cartProvider.getProductPriceById(cartItem.productId);
      itemsWithPrices.add({
        'productId': cartItem.productId,
        'quantity': cartItem.quantity,
        'price': productPrice,
      });
    }

    return itemsWithPrices;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextWidget(
          text: 'Checkout',
          color: Colors.white,
          isTitle: true,
          textSize: 22,
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Address:'),
            _buildAddressWidget(),
            SizedBox(height: 20),
            _buildSectionTitle('Payment Method:'),
            _buildPaymentMethodWidget(),
            SizedBox(height: 20),
            _buildSectionTitle('Promo Code:'),
            _buildPromoCodeWidget(),
            SizedBox(height: 20),
            _buildSectionTitle('Order Summary:'),
            _buildOrderSummaryWidget(),
            SizedBox(height: 10),
            Divider(),
            _buildPriceRow('Delivery Price:', _deliveryPrice),
            SizedBox(height: 10),
            _buildPriceRow('Service Price:', _servicePrice),
            SizedBox(height: 10),
            _buildPriceRow('Total Price:', _totalPrice, isTotal: true),
            SizedBox(height: 20),
            _buildOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return TextWidget(
      text: title,
      color: Colors.teal,
      textSize: 18,
      isTitle: true,
    );
  }

  Widget _buildAddressWidget() {
    return TextWidget(
      text: _userAddress.isNotEmpty ? _userAddress : 'No address available',
      color: Colors.black54,
      textSize: 16,
    );
  }

  Widget _buildPaymentMethodWidget() {
    return Row(
      children: [
        _buildPaymentMethodRadio('Cash'),
        _buildPaymentMethodRadio('Card'),
      ],
    );
  }

  Widget _buildPaymentMethodRadio(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
          activeColor: Colors.teal,
        ),
        Text(value),
      ],
    );
  }

  Widget _buildPromoCodeWidget() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Enter Promo Code',
      ),
      onChanged: (value) {
        setState(() {
          _promoCode = value;
        });
      },
    );
  }

  Widget _buildOrderSummaryWidget() {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCartItemsWithPrices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items in the cart'));
          } else {
            List<Map<String, dynamic>> items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                var item = items[index];
                double itemTotalPrice = item['quantity'] * item['price'];
                return ListTile(
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Item Price: ${item['quantity']}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${itemTotalPrice.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildPriceRow(String label, double price, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.teal : Colors.black,
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.teal : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          var user = globals.userData;
          final cartProvider = Provider.of<CartProvider>(context, listen: false);
          final productProvider = Provider.of<ProductsProvider>(context, listen: false);
          final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

          try {
            // Fetch cart items
            var cartItems = cartProvider.getCartItems.values.toList();

            for (var cartItem in cartItems) {
              // Fetch current product details
              var getProduct = productProvider.findProById(cartItem.productId);
              var currentProduct = await getProduct;

              // Generate a unique order ID
              var orderId = const Uuid().v4();

              // Calculate total price for the current item
              var totalPrice = (currentProduct.isOnSale
                  ? currentProduct.salePrice
                  : currentProduct.price) *
                  cartItem.quantity;

              // Prepare data to be stored in Firestore
              var orderData = {
                'orderId': orderId,
                'userId': user!['id'],
                'productId': cartItem.productId,
                'price': totalPrice,
                'totalPrice': _totalPrice,
                'quantity': cartItem.quantity,
                'imageUrl': currentProduct.imageUrl,
                'userName': user['name'],
                'orderDate': Timestamp.now(),
              };

              // Save order data to Firestore
              await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);

              // Clear cart after placing order
              await cartProvider.clearOnlineCart();
              cartProvider.clearLocalCart();

              // Fetch updated orders
              ordersProvider.fetchOrders();
            }

            // Show success toast message
            Fluttertoast.showToast(
              msg: "Your order(s) have been placed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
            );
          } catch (error) {
            // Handle errors
            GlobalMethods.errorDialog(subtitle: error.toString(), context: context);
          }
        },
        child: Text('Order Now', style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        ),
      ),
    );
  }
}
