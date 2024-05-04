import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:task_manager/data/services/network_caller.dart';
import 'package:task_manager/screens/auth/set_password_screen.dart';
import 'package:task_manager/screens/auth/sign_in_screen.dart';
import 'package:task_manager/widgets/background_body.dart';
import 'package:task_manager/widgets/snack_bar_message.dart';

import '../../data/utlity/urls.dart';

class PinVerificationScreen extends StatefulWidget {
  const PinVerificationScreen({super.key, required this.email});

  final String email;

  @override
  State<PinVerificationScreen> createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  final TextEditingController _otpTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _otpVerificationInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundScreen(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  const Text(
                    'PIN Verification',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'A 6 digit verification pin will send to your email address',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  PinCodeTextField(
                    controller: _otpTEController,
                    keyboardType: TextInputType.number,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: Colors.white,
                      activeColor: Colors.white,
                      inactiveColor: Colors.green,
                      inactiveFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    onChanged: (value) {},
                    appContext: context,
                  ),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: Visibility(
                      visible: _otpVerificationInProgress == false,
                      replacement: const Center(child: CircularProgressIndicator(),),
                      child: ElevatedButton(
                        onPressed: () {
                          if(!_formKey.currentState!.validate()){
                            return;
                          }
                          OtpVerify();
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => SetPasswordScreen(
                          //       email: widget.email,
                          //       otp: _otpTEController.text,
                          //     ),
                          //   ),
                          // );
                        },
                        child: const Text('Verify'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Have account?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigator.pushAndRemoveUntil(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => const SignInScreen()),
                          //     (route) => false);
                          Get.offAll(()=> SignInScreen());
                        },
                        child: const Text(
                          "Sign in",
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> OtpVerify() async {
    _otpVerificationInProgress = true;
    if (mounted) {
      setState(() {});
    }
    final response = await NetworkCaller.getRequest(
        Urls.otpVerificationRequest(widget.email, _otpTEController.text));
    _otpVerificationInProgress = false;
    if (mounted) {
      setState(() {});
    }
    if (response.isSuccess) {
      // if (mounted) {
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => SetPasswordScreen(
      //                 email: widget.email,
      //                 otp: _otpTEController.text,
      //               )));
      // }
      Get.to(()=> SetPasswordScreen(email: widget.email, otp: _otpTEController.text));
    } else {
      if (mounted) {
        showSnackBarMessage(
            context, response.errorMessage ?? ' OTP verification failed');
      }
    }
  }
}
