import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/data/services/network_caller.dart';
import 'package:task_manager/data/utlity/urls.dart';
import 'package:task_manager/screens/auth/pin_verification_screen.dart';
import 'package:task_manager/screens/auth/sign_in_screen.dart';
import 'package:task_manager/widgets/background_body.dart';
import 'package:task_manager/widgets/snack_bar_message.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  final TextEditingController _emailTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _emailVerificationInProcess = false;

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
                  Text(
                    'Your Email Address',
                    style: Theme.of(context).textTheme.titleLarge,
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
                  TextFormField(
                    controller: _emailTEController,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: Visibility(
                      visible: _emailVerificationInProcess == false,
                      replacement: const Center(
                        child: CircularProgressIndicator(),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          sendOTPTOEmail();
                        },
                        child: const Icon(Icons.arrow_forward_ios),
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
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                              (route) => false);
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

  Future<void> sendOTPTOEmail() async {
    _emailVerificationInProcess = true;
    if (mounted) {
      setState(() {});
    }
    final response = await NetworkCaller.getRequest(
        Urls.emailVerificationRequest(_emailTEController.text.trim()));
    _emailVerificationInProcess = false;
    if (mounted) {
      setState(() {});
    }
    if (response.isSuccess) {
      // if (mounted) {
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => PinVerificationScreen(
      //               email: _emailTEController.text.trim())));
      // }
      Get.to(()=> PinVerificationScreen(email: _emailTEController.text.trim()));
    } else {
      if (mounted) {
        showSnackBarMessage(
            context, response.errorMessage ?? 'Email verification  failed');
      }
    }
  }


  @override
  void dispose() {
    _emailTEController.dispose();
    super.dispose();
  }
}
