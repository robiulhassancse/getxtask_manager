import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/controllers/count_task_by_status_controller.dart';
import 'package:task_manager/controllers/new_task_controller.dart';
import 'package:task_manager/data/models/count_by_staurs_wrapper.dart';
import 'package:task_manager/data/models/task_list_wrapper.dart';
import 'package:task_manager/data/services/network_caller.dart';
import 'package:task_manager/data/utlity/urls.dart';
import 'package:task_manager/screens/add_new_task_screen.dart';
import 'package:task_manager/widgets/snack_bar_message.dart';

import '../data/models/task_count_by_status_data.dart';
import '../widgets/empty_list_widget.dart';
import '../widgets/profileAppBar.dart';
import '../widgets/task_counter_card.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  bool _getAllTaskCountByStatusInProgress = false;
  // TaskListWrapper _newTaskListWrapper = TaskListWrapper();
  // bool _getNewTaskListInProgress = false;
  bool _deleteTaskInProgress = false;
  bool _updatesTaskInProgress = false;

  @override
  void initState() {
    super.initState();
    _getDataFromApis();
  }

  void _getDataFromApis() {
    Get.find<CountTaskByStatusController>().getCountByTaskStatus();
    // _getAllTaskCountByStatus();
    // _getAllNewTaskList();
    Get.find<NewTaskController>().getNewTaskList();


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: profileAppBar,
      body: RefreshIndicator(
        onRefresh: () async {
          _getDataFromApis();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GetBuilder<CountTaskByStatusController>(
                builder: (controller) {
                  return Visibility(
                      visible: controller.inProgress == false,
                      replacement: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(),
                      ),
                      child: taskCounterSection(controller.countByStatusWrapper.listOfTaskByStatusData ?? [],),);
                }
              ),
              Expanded(
                child: GetBuilder<NewTaskController>(
                  builder: (newTaskController) {
                    return Visibility(
                      visible: newTaskController.inProgress == false &&
                          _deleteTaskInProgress == false &&
                          _updatesTaskInProgress == false,
                      replacement: const Center(
                        child: CircularProgressIndicator(),
                      ),
                      child: Visibility(
                        visible: newTaskController.newTaskListWrapper.taskList?.isNotEmpty ?? false,
                        replacement: const EmptyListWidget(),
                        child: ListView.builder(
                            itemCount: newTaskController.newTaskListWrapper.taskList?.length ?? 0,
                            itemBuilder: (context, index) {
                              return Card(
                                color: Colors.white,
                                child: ListTile(
                                  title: Text(
                                      newTaskController.newTaskListWrapper.taskList![index].title ??
                                          ''),
                                  subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          newTaskController.newTaskListWrapper.
                                                  taskList![index].description ??
                                              '',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                            'Date: ${newTaskController.newTaskListWrapper.taskList?[index].createdDate}'),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Chip(
                                              label: Text(
                                                newTaskController.newTaskListWrapper
                                                        .taskList![index].status ??
                                                    '',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              backgroundColor: Colors.blue,
                                            ),
                                            const Spacer(),
                                            Visibility(
                                              visible:
                                                  _updatesTaskInProgress == false,
                                              replacement:
                                                  const CircularProgressIndicator(),
                                              child: IconButton(
                                                onPressed: () {
                                                  _showUpdatesStateDialog(
                                                      newTaskController.newTaskListWrapper
                                                          .taskList![index].sId!);
                                                },
                                                icon: const Icon(Icons.edit),
                                              ),
                                            ),
                                            Visibility(
                                              visible: _deleteTaskInProgress == false,
                                              replacement:
                                                  const CircularProgressIndicator(),
                                              child: IconButton(
                                                onPressed: () {
                                                  _deleteTaskById(newTaskController.newTaskListWrapper
                                                      .taskList![index].sId!);
                                                },
                                                icon: const Icon(
                                                    Icons.delete_forever_outlined,
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]),
                                ),
                              );
                            }),
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNewTaskScreen()),
          );

          if(result != null && result == true){
            _getDataFromApis();
          }
        },
        child: const Icon(
          Icons.add,
          size: 30,
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget taskCounterSection(List<TaskCountByStatusData> listOfTaskByStatusData) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
          itemCount: listOfTaskByStatusData.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return TaskCounterCard(
              title: listOfTaskByStatusData![index].sId ??
                  '',
              amount:
                  listOfTaskByStatusData![index].sum ?? 0,
            );
          },
          separatorBuilder: (_, __) {
            return const SizedBox(
              width: 8,
            );
          }),
    );
  }

  void _showUpdatesStateDialog(String id) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 ListTile(
                  title: const Text('New'),
                  trailing: _isCurrentStatus('New') ?const Icon(Icons.check) : null,
                   onTap: (){
                    if(_isCurrentStatus('New')){
                      return;
                    }
                    _updateTaskById(id, 'New');
                    Navigator.pop(context);
                   },
                ),
                ListTile(
                  title: const Text('Completed'),
                  trailing: _isCurrentStatus('Completed') ?const Icon(Icons.check) : null,
                  onTap: (){
                    if(_isCurrentStatus('Completed')){
                      return;
                    }
                    _updateTaskById(id, 'Completed');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Progress'),
                  trailing: _isCurrentStatus('Progress') ?const Icon(Icons.check) : null,
                  onTap: (){
                    if(_isCurrentStatus('Progress')){
                      return;
                    }
                    _updateTaskById(id, 'Progress');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Cancelled'),
                  trailing: _isCurrentStatus('Cancelled') ?const Icon(Icons.check) : null,
                  onTap: (){
                    if(_isCurrentStatus('Cancelled')){
                      return;
                    }
                    _updateTaskById(id, 'Cancelled');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }
  // bool _isCurrentStatus(String status) {
  //   for (final task in newTask) {
  //     if (task.status == status) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }


  bool _isCurrentStatus(String status) {
    var newTaskController;
    final newTaskList = newTaskController.newTaskListWrapper.taskList;
    if (newTaskList != null) {
      for (final task in newTaskList) {
        if (task.status == status) {
          return true;
        }
      }
    }
    return false;
  }



  // bool _isCurrentStatus(String status) {
  //   return _newTaskListWrapper.status == status;
  // }

  Future<void> _getAllTaskCountByStatus() async {
    _getAllTaskCountByStatusInProgress = true;
    setState(() {});

    final response = await NetworkCaller.getRequest(Urls.taskCountByStatus);
    if (response.isSuccess) {
      final CountByStatusWrapper result =
          CountByStatusWrapper.fromJson(response.responseBody);
      _getAllTaskCountByStatusInProgress = false;
      setState(() {});
    } else {
      _getAllTaskCountByStatusInProgress = false;
      setState(() {});
      if (mounted) {
        showSnackBarMessage(
            context,
            response.errorMessage ??
                'Get task count by status has been failed');
      }
    }
  }



  Future<void> _deleteTaskById(String id) async {
    _deleteTaskInProgress = true;
    setState(() {});

    final response = await NetworkCaller.getRequest(Urls.deleteTask(id));
    _deleteTaskInProgress = false;
    if (response.isSuccess) {
      _getDataFromApis();
    } else {
      _deleteTaskInProgress = false;
      setState(() {});
      if (mounted) {
        showSnackBarMessage(
            context, response.errorMessage ?? 'Delete task has been failed');
      }
    }
  }

  Future<void> _updateTaskById(String id, String status) async {
    _updatesTaskInProgress = true;
    setState(() {});

    final response =
        await NetworkCaller.getRequest(Urls.updateTaskStatus(id, status));
    _updatesTaskInProgress = false;
    setState(() {});

    if (response.isSuccess) {
      _updatesTaskInProgress = false;
      setState(() {});
      _getDataFromApis();
    } else {
      setState(() {});
      if (mounted) {
        showSnackBarMessage(context,
            response.errorMessage ?? 'Update task status has been failed');
      }
    }
  }
}


