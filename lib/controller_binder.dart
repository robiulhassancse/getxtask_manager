import 'package:get/get.dart';
import 'package:task_manager/controllers/count_task_by_status_controller.dart';
import 'package:task_manager/controllers/new_task_controller.dart';
import 'package:task_manager/controllers/sign_in_controller.dart';

class ControllerBinder extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => SignInController());
    Get.lazyPut(() => CountTaskByStatusController());
    Get.lazyPut(() => NewTaskController());
  }

}