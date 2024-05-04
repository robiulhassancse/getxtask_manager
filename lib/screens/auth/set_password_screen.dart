import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/data/services/network_caller.dart';
import 'package:task_manager/data/utlity/urls.dart';
import 'package:task_manager/screens/auth/sign_in_screen.dart';
import 'package:task_manager/widgets/background_body.dart';
import 'package:task_manager/widgets/snack_bar_message.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key, required this.email, required this.otp});
  final String email, otp;

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final TextEditingController _passwordTEController = TextEditingController();
  final TextEditingController _confirmTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _setPasswordInProgress = false;

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
                    'Set Password',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text('Minimum length password 8 character with Latter and number combination',style: TextStyle(
                    color: Colors.grey.shade600,
                  ),),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _passwordTEController,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                    ),
                    validator: (String? value){
                      if(value?.isEmpty ?? true){
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _confirmTEController,
                    decoration: const InputDecoration(
                      hintText: 'Confirm Password',
                    ),
                    validator: (String? value){
                      if(value?.isEmpty ?? true){
                        return 'Enter your confirm password';
                      }else if(value! != _passwordTEController.text){
                        return 'Confirm password doesn\'t match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),

                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if(!_formKey.currentState!.validate()){
                          return;
                        }
                        resetPassword();
                      },
                      child: const Text('Confirm'),
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
  Future<void> resetPassword() async{
    _setPasswordInProgress = true;
    if(mounted){
      setState(() {});
    }
    Map<String,dynamic> inputParams={
      "email":widget.email,
      "OTP":widget.otp,
      "password":_passwordTEController.text,
    };

    final response = await NetworkCaller.postRequest(Urls.resetPassword, inputParams);
    _setPasswordInProgress = false;
    if(mounted){
      setState(() {});
    }
    if(response.isSuccess){
      // if(mounted) {
      //   Navigator.pushAndRemoveUntil(
      //       context, MaterialPageRoute(builder: (context) => const SignInScreen()), (
      //       route) => false);
      // }
      Get.offAll(()=> const SignInScreen());
    }else{
      if(mounted) {
        showSnackBarMessage(
            context, response.errorMessage ?? 'Reset verification failed');
      }
    }
  }
  @override
  void dispose() {
    _passwordTEController.dispose();
    _confirmTEController.dispose();
    super.dispose();
  }
}
