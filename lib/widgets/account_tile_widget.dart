import 'package:flutter/material.dart';

import '../models/account.dart';

class AccountTile extends StatelessWidget {
  final Account account;
  final VoidCallback onDelete;
  final VoidCallback onSelect;

  const AccountTile({
    Key? key,
    required this.account,
    required this.onDelete,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(account.name),
      subtitle: Text(account.phoneNumber),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
          IconButton(
            icon: Icon(Icons.login, color: Colors.green),
            onPressed: onSelect,
          ),
        ],
      ),
    );
  }
}
