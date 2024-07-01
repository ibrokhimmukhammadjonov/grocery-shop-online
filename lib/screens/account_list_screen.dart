import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../fetch_screen.dart';
import '../providers/account_provider.dart';
import '../widgets/account_tile_widget.dart';
import 'auth/login.dart';

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({Key? key}) : super(key: key);
  static const routeName = '/AccountScreen';

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountProvider = Provider.of<AccountProvider>(context, listen: false);
      accountProvider.fetchAccounts(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final accounts = accountProvider.accounts;
    final Color primaryColor = Colors.teal;
    final Color accentColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manage Accounts",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
        backgroundColor: accentColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: accounts.isEmpty
          ? Center(
        child: Text(
          "No accounts found.",
          style: TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontFamily: 'Montserrat',
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                title: Text(
                  account.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                  ),
                ),
                subtitle: Text(
                  account.phoneNumber,
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.6),
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        accountProvider.removeAccount(account);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.login, color: primaryColor),
                      onPressed: () async {
                        await accountProvider.login(account);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => FetchScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
