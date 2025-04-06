import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gdg_solution/buyer/HomePage_buy.dart';
import 'package:gdg_solution/farmer/mainNav.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _usernameController =
      TextEditingController(); // Added username controller

  String _role = 'Farmer';
  bool _isLoading = false;
  bool _isPhoneLogin = false;
  String? _verificationId;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _usernameController.dispose(); // Dispose username controller
    super.dispose();
  }

  Future<void> _verifyPhoneNumber() async {
    setState(() => _isLoading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: "+91${_phoneController.text.trim()}",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _navigateToHome(_usernameController.text.trim()); // Use username
        },
        verificationFailed: (FirebaseAuthException e) {
          _showErrorDialog(e.message ?? 'Verification failed');
          setState(() => _isLoading = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
            _isPhoneLogin = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _showErrorDialog('Phone verification failed: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithPhoneNumber() async {
    setState(() => _isLoading = true);

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Update the user profile with the username
      await userCredential.user?.updateDisplayName(
        _usernameController.text.trim(),
      );

      _navigateToHome(_usernameController.text.trim()); // Use username
    } catch (e) {
      _showErrorDialog('Invalid OTP. Please try again.');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToHome(String username) {
    if (_role == 'Buyer') {
      // print("Buyer");
      print('Buyer number : ${_phoneController.text}');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => HomepageBuy(
                username: username,
                uniqueID: ('b${_phoneController.text}'),
              ),
        ),
      );
    } else {
      // print("Seller ${_phoneController.text}");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => MainNavigation(
                username: username,
                UniqueId: ('f${_phoneController.text}'),
                selectedIndex: 0,
              ),
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Error'),
            content: Text("Something went wrong."),
            actions: [
              TextButton(
                child: Text('Okay', style: TextStyle(color: Colors.black)),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal.shade300, Colors.green.shade300],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco, size: 80, color: Colors.white),
                    SizedBox(height: 24),
                    Text(
                      'Welcome to Fasal Mitra',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField<String>(
                        value: _role,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Select Role',
                        ),
                        items:
                            ['Farmer', 'Buyer'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _role = newValue!;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_isPhoneLogin) ...[
                      TextFormField(
                        cursorColor: Colors.black54,

                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter OTP',
                          hintStyle: TextStyle(color: Colors.grey.shade900),
                          prefixIcon: Icon(Icons.lock, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Please enter OTP' : null,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signInWithPhoneNumber,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Verify OTP',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ] else ...[
                      // Username field
                      TextFormField(
                        cursorColor: Colors.black54,

                        controller: _usernameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Username',
                          hintStyle: TextStyle(color: Colors.grey.shade900),
                          prefixIcon: Icon(Icons.person, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Please enter a username'
                                    : null,
                      ),
                      SizedBox(height: 16),
                      // Phone number field
                      TextFormField(
                        cursorColor: Colors.black54,

                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(color: Colors.grey.shade900),
                          prefixIcon: Icon(Icons.phone, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Please enter your phone number'
                                    : null,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _isLoading ? null : _verifyPhoneNumber,
                        child: Text('Send OTP', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                    if (_isLoading)
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
