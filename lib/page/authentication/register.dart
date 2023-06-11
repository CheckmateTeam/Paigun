import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:paigun/provider/userinfo.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../function/show_snackbar.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool _isLoading = false;
  bool showPass = true;
  String phoneNo = '';

  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(
          children: [
            Stack(children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 1.9,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                    color: Theme.of(context).primaryColor),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                    iconSize: 40,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_outlined,
                      color: Colors.white,
                    )),
              ),
              const Positioned(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                      children: [
                        Image(
                          width: 150,
                          height: 150,
                          image: AssetImage('assets/images/logo_w.png'),
                        ),
                        Text(
                          'REGISTER',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                  child: Center(
                child: Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width / 1.1,
                  margin: const EdgeInsets.only(
                    top: 250,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10))
                      ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IntlPhoneField(
                                decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(),
                                    ),
                                    counterText: ''),
                                initialCountryCode: 'TH',
                                onChanged: (phone) {
                                  phoneNo = phone.completeNumber;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "Full name",
                                    labelText: "Full name",
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 20),
                              TextField(
                                  controller: _passwordController,
                                  obscureText: showPass,
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      hintText: "Password",
                                      labelText: "Password",
                                      prefixIcon:
                                          const Icon(Icons.key_outlined),
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              showPass = !showPass;
                                            });
                                          },
                                          icon: showPass
                                              ? const Icon(Icons.visibility)
                                              : const Icon(
                                                  Icons.visibility_off))),
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 10),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [],
                              ),
                            ],
                          )),
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 1.6,
                          height: 50,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Theme.of(context).primaryColor)),
                              onPressed: () async {
                                String name = _nameController.text;
                                String password = _passwordController.text;
                                final phoneRegEx = RegExp(
                                    r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$');
                                if (phoneNo.isEmpty ||
                                    name.isEmpty ||
                                    password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Please fill all the fields'),
                                    ),
                                  );
                                } else {
                                  if (!phoneRegEx.hasMatch(phoneNo)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please enter a valid phone number'),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await supabase.auth.signInWithOtp(
                                      phone: phoneNo,
                                    );
                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    // ignore: use_build_context_synchronously
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Verification(
                                                name: name,
                                                password: password,
                                                phoneNo: phoneNo)));
                                  }
                                }
                              },
                              child: _isLoading
                                  ? const SpinKitWave(
                                      color: Colors.white,
                                      size: 30.0,
                                    )
                                  : const Text('Register',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal)))),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Sign up'))
                        ],
                      ),
                    ],
                  ),
                ),
              ))
            ]),
          ],
        )),
      ),
    );
  }
}

class Verification extends StatefulWidget {
  final String phoneNo;
  final String name;
  final String password;
  const Verification(
      {super.key,
      required this.phoneNo,
      required this.name,
      required this.password});
  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  @override
  void initState() {
    super.initState();
  }

  String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 2.2,
          width: MediaQuery.of(context).size.width / 1.1,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Verification',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Column(
                children: [
                  const Text('Please enter the code sent to'),
                  Text(
                    widget.phoneNo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Pinput(
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                length: 6,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onCompleted: (pin) async {
                  try {
                    final AuthResponse res = await supabase.auth.verifyOTP(
                      type: OtpType.sms,
                      token: pin,
                      phone: widget.phoneNo,
                    );
                    final Session? session = res.session;
                    final User? user = res.user;
                    if (session != null && user != null) {
                      await context.read<UserInfo>().addNewUser(widget.phoneNo,
                          widget.name, encryptPassword(widget.password));
                    }
                    // ignore: use_build_context_synchronously
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              alignment: Alignment.center,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Congratulations',
                                      style: GoogleFonts.nunito(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(context).primaryColor,
                                      )),
                                ],
                              ),
                              content: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('You have successfully registered'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.6,
                                    height: 50,
                                    child: FilledButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context, '/home', (route) => false);
                                      },
                                      child: const Text('Let\'s start'),
                                    ),
                                  ),
                                )
                              ],
                            ));
                  } on AuthException catch (error) {
                    context.showErrorSnackBar(
                      message: error.message,
                    );
                    print(error.message);
                  } catch (error) {
                    context.showErrorSnackBar(
                      message: error.toString(),
                    );
                    print(error.toString());
                  }
                },
              ),
              Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.6,
                    height: 50,
                    child: FilledButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.secondary),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Go back'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
