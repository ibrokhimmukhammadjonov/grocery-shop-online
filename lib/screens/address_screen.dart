import 'package:flutter/material.dart';
import 'package:grocery_shop_app/screens/route_right_to_left.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import 'auth/placemark_map_object_page.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({Key? key}) : super(key: key);
  static const routeName = '/AddressPage';

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);

    // Fetch addresses when the screen is built
    if (addressProvider.addresses.isEmpty) {
      addressProvider.fetchAddresses();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Addresses'),
      ),
      body: Consumer<AddressProvider>(
        builder: (context, addressProvider, child) {
          return ListView.builder(
            itemCount: addressProvider.addresses.length,
            itemBuilder: (context, index) {
              final address = addressProvider.addresses[index];
              return ListTile(
                title: Text(address.name),
                subtitle: Text(address.address),
                onTap: () async {
                  await addressProvider.updateUserShippingAddress(address);
                  Navigator.of(context).pop(address);
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        final updatedAddress = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LocationPickerPage(address: address),
                          ),
                        );
                        if (updatedAddress != null) {
                          addressProvider.updateAddress(updatedAddress);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => addressProvider.deleteAddress(address.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final newAddress = await Navigator.of(context).push(
            slideFromRightToLeftRoute(LocationPickerPage()),
          );

          if (newAddress != null) {
            addressProvider.addAddress(newAddress);
          }
        },
      ),
    );
  }
}
