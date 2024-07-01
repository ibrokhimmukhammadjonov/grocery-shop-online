import 'package:flutter/material.dart';
import 'package:grocery_shop_app/screens/auth/placemark_map_object_page.dart';
import 'package:telephony/telephony.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../consts/firebase_const.dart';
import '../../fetch_screen.dart';
import '../../services/global_methods.dart';
import '../loading_manager.dart';
import 'package:grocery_shop_app/controllers/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/LoginScreen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Telephony telephony = Telephony.instance;

  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void listenToIncomingSMS(BuildContext context) {
    print("Listening to sms.");
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        print("SMS received: ${message.body}");
        if (message.body!.contains("phone-auth-15bdb")) {
          String otpCode = message.body!.substring(0, 6);
          setState(() {
            _otpController.text = otpCode;
            Future.delayed(Duration(seconds: 1), () {
              handleSubmit(context);
            });
          });
        }
      },
      listenInBackground: false,
    );
  }

  void handleSubmit(BuildContext parentContext) async {
    if (_formKey1.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final value = await AuthService.loginWithOtp(otp: _otpController.text);
        if (value == "Success") {
          final User? user = authInstance.currentUser;

          Navigator.pop(parentContext); // Use the parent context directly

          final Point? selectedLocation = await Navigator.push(
            parentContext,
            MaterialPageRoute(builder: (context) => LocationPickerPage(name: _nameController.text)),
          );

          // At this point, user data and location are already saved by LocationPickerPage
          if (selectedLocation != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const FetchScreen()),
            );
          }
        } else {
          ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(
            content: Text(
              value,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ));
        }
      } on FirebaseException catch (error) {
        GlobalMethods.errorDialog(
          subtitle: '${error.message}',
          context: parentContext, // Use the parent context
        );
      } catch (error) {
        GlobalMethods.errorDialog(
          subtitle: '$error',
          context: parentContext, // Use the parent context
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LoadingManager(
        isLoading: _isLoading,
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.asset(
                  "assets/images/login.png",
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back 👋",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                    ),
                    Text("Enter your phone number to continue."),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              prefixText: "+998 ",
                              labelText: "Enter your phone number",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            validator: (value) {
                              if (value!.length != 9) return "Invalid phone number";
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              labelText: "Enter your name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) return "Please enter your name";
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            AuthService.sentOtp(
                              phone: _phoneController.text,
                              errorStep: () {
                                setState(() {
                                  _isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    "Error in sending OTP",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ));
                              },
                              nextStep: () {
                                setState(() {
                                  _isLoading = false;
                                });
                                listenToIncomingSMS(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("OTP Verification"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Enter 6 digit OTP"),
                                        SizedBox(height: 12),
                                        Form(
                                          key: _formKey1,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: _otpController,
                                            decoration: InputDecoration(
                                              labelText: "Enter OTP",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(32),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value!.length != 6) return "Invalid OTP";
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => handleSubmit(context),
                                        child: Text("Submit"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: Text("Send OTP"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
