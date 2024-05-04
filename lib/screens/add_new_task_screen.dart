import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/data/models/response_object.dart';
import 'package:task_manager/data/services/network_caller.dart';
import 'package:task_manager/data/utlity/urls.dart';
import 'package:task_manager/screens/new_task_screen.dart';
import 'package:task_manager/screens/auth/pin_verification_screen.dart';
import 'package:task_manager/screens/auth/email_verification_screen.dart';
import 'package:task_manager/screens/auth/sign_up_screen.dart';
import 'package:task_manager/widgets/background_body.dart';
import 'package:task_manager/widgets/main_bottom_nav_screen.dart';
import 'package:task_manager/widgets/profileAppBar.dart';
import 'package:task_manager/widgets/snack_bar_message.dart';

class AddNewTaskScreen extends StatefulWidget {
  const AddNewTaskScreen({super.key});


  @override
  State<AddNewTaskScreen> createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends State<AddNewTaskScreen> {
  final TextEditingController _subjectTEController = TextEditingController();
  final TextEditingController _descriptionTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _addNewTaskInProgress = false;
  bool _shouldRefreshNewTaskList = false;


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop){
        if(didPop) {
          return;
        }
          // Navigator.pop(context, _shouldRefreshNewTaskList);
        Get.back(result: _shouldRefreshNewTaskList);

      },
      child: Scaffold(
        appBar: profileAppBar,
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
                      height: 30,
                    ),
                    Text(
                      'Add New Task',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: _subjectTEController,
                      decoration: const InputDecoration(
                        hintText: 'subject',
                      ),
                      validator: (String? value){
                        if(value?.trim().isEmpty ?? true){
                          return 'Enter your subject';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: _descriptionTEController,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(top: 20,left: 24),
                        hintText: 'Description',
                      ),
                      validator: (String? value){
                        if(value?.trim().isEmpty ?? true){
                          return 'Enter your description';
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
                      child: Visibility(
                        visible: _addNewTaskInProgress == false,
                        replacement: const Center(child: CircularProgressIndicator(),),
                        child: ElevatedButton(
                          onPressed: () {
                            if(_formKey.currentState!.validate()){
                              _addNewTask();
                            }
                            // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> const MainBottomNavScren(),), (route) => false);
                          },
                          child: const Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
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
  Future<void> _addNewTask() async{
    _addNewTaskInProgress = true;
    setState(() {});

    Map<String, dynamic>inputParams={
      "title": _subjectTEController.text.trim(),
      "description": _descriptionTEController.text.trim(),
      "status":"New"
    };
    
    final response = await NetworkCaller.postRequest(Urls.createTask, inputParams);
    _addNewTaskInProgress = false;
    setState(() {});
    if(response.isSuccess){
      _shouldRefreshNewTaskList = true;
      _subjectTEController.clear();
      _descriptionTEController.clear();
      if(mounted) {
        showSnackBarMessage(context, 'New task has been added');
      }
    }else{
      if(mounted) {
        showSnackBarMessage(
            context, response.errorMessage ?? 'Add New task failed');
      }
    }

  }


  @override
  void dispose() {
    _subjectTEController.dispose();
    _descriptionTEController.dispose();
    super.dispose();
  }
}
