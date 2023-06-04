import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:paigun/function/show_snackbar.dart';
import 'package:paigun/page/authentication/register.dart';
import 'package:pinput/pinput.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String phoneNo = '';
  final TextEditingController _passwordController = TextEditingController();
  bool showPass = true;

  String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

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
                          'WELCOME',
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
                                  controller: _passwordController,
                                  obscureText: showPass,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    hintText: "Password",
                                    labelText: "Password",
                                    prefixIcon: const Icon(Icons.key_outlined),
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showPass = !showPass;
                                          });
                                        },
                                        icon: showPass
                                            ? const Icon(Icons.visibility)
                                            : const Icon(Icons.visibility_off)),
                                  ),
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
                              final phoneRegEx = RegExp(
                                  r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$');
                              if (phoneNo.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Phone number required')));
                              } else if (!phoneRegEx.hasMatch(phoneNo)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Invalid phone number')));
                              } else if (_passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Password required')));
                              } else {
                                //login process
                                String phone = phoneNo;
                                String password = _passwordController.text;
                                try {
                                  final AuthResponse res =
                                      await supabase.auth.signInWithPassword(
                                    phone: phone,
                                    password: encryptPassword(password),
                                  );
                                  final Session? session = res.session;
                                  final User? user = res.user;

                                  Navigator.pushReplacementNamed(
                                      context, '/loading');
                                } catch (e) {
                                  print(e.toString());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Incorrect phone number or password')));
                                }
                              }
                            },
                            child: const Text('Sign in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ))),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.6,
                        height: 50,
                        child: ElevatedButton(
                            style: const ButtonStyle(),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SmsLogin()));
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone),
                                Text('Sign in with SMS')
                              ],
                            )),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Don\'t have an account?'),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Signup()));
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

class SmsLogin extends StatefulWidget {
  const SmsLogin({super.key});

  @override
  State<SmsLogin> createState() => _SmsLoginState();
}

class _SmsLoginState extends State<SmsLogin> {
  late String phoneNo;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
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
                'Sign in with SMS',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                initialCountryCode: 'TH',
                onChanged: (phone) {
                  phoneNo = phone.completeNumber;
                },
              ),
              Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.6,
                    height: 50,
                    child: FilledButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });

                          final phoneRegEx = RegExp(
                              r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$');
                          if (!phoneRegEx.hasMatch(phoneNo)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Invalid phone number')));
                          } else {
                            await supabase.auth.signInWithOtp(
                              phone: phoneNo,
                            );
                            setState(() {
                              _isLoading = false;
                            });
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Verification(phoneNo: phoneNo)));
                          }
                          // ignore: use_build_context_synchronously
                        },
                        child: _isLoading
                            ? const SpinKitWave(
                                color: Colors.white,
                                size: 30.0,
                              )
                            : const Text('Send OTP')),
                  ),
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
  }
}

class Verification extends StatefulWidget {
  final String phoneNo;
  const Verification({super.key, required this.phoneNo});
  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  @override
  void initState() {
    super.initState();
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
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/loading', (_) => false);
                  } on AuthException catch (error) {
                    context.showErrorSnackBar(
                      message: error.message,
                    );
                  } catch (error) {
                    context.showErrorSnackBar(
                      message: error.toString(),
                    );
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
