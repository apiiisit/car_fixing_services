import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:car_fixing_services/screens/otp.dart';
import 'package:car_fixing_services/util/showDialog.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController phoneController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  Future verifyNumber() async {
    if (phoneController.text.isEmpty) {
      showMyDialog(context, "Phone number", "Please enter your phone number.");
    } else {
      await auth.verifyPhoneNumber(
          phoneNumber: "+66" + phoneController.text,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await auth.signInWithCredential(credential).then((value) {
              print("You are logged in successfully");
            });
          },
          verificationFailed: (FirebaseAuthException exception) {
            print(exception.message);
            showMyDialog(
                context, "Phone number", "Please enter a valid phone number.");
          },
          codeSent: (String verificationID, int? resendToken) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => Otp(verificationID)),
            );
          },
          codeAutoRetrievalTimeout: (String verificationID) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 26),
          child: Column(
            children: [
              Container(
                width: 248,
                height: 248,
                child: Image.asset(
                  'assets/images/signin.png',
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              const Text(
                'Sign in',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 48,
              ),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10)),
                        prefix: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '(+66)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 36,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await verifyNumber();
                        },
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xFFF07B3F)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Request OTP',
                            style: TextStyle(fontSize: 22),
                          ),
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
