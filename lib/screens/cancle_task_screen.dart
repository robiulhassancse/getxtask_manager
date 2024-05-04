import 'package:flutter/material.dart';
import 'package:task_manager/data/models/task_list_wrapper.dart';
import 'package:task_manager/widgets/empty_list_widget.dart';
import '../data/services/network_caller.dart';
import '../data/utlity/urls.dart';
import '../widgets/profileAppBar.dart';
import '../widgets/snack_bar_message.dart';


class CancleTaskScreen extends StatefulWidget {
  const CancleTaskScreen({super.key});

  @override
  State<CancleTaskScreen> createState() => _CancleTaskScreenState();
}

class _CancleTaskScreenState extends State<CancleTaskScreen> {
  bool _getAllCancleTaskListInProgress = false;
  TaskListWrapper _cancleTaskListWrapper = TaskListWrapper();
  bool _deleteCloseTaskInProgress = false;

  @override
  void initState() {
    super.initState();
    _getDataFromApis();
  }

  void _getDataFromApis() {
    _getAllCancleTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: profileAppBar,
      body: RefreshIndicator(
        onRefresh: () async{
          _getDataFromApis();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Visibility(
                  visible: _cancleTaskListWrapper.taskList?.isNotEmpty ?? false,
                  replacement: const EmptyListWidget(),
                  child: Visibility(
                    visible: _getAllCancleTaskListInProgress == false,
                    replacement: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    child: ListView.builder(
                        itemCount: _cancleTaskListWrapper.taskList?.length ?? 0,
                      // itemCount: 10,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.white,
                            child: ListTile(
                              title: Text(
                                  _cancleTaskListWrapper.taskList![index].title ??
                                      ''),
                              subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _cancleTaskListWrapper.taskList![index].description ??
                                          '',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                     Text('Date: ${_cancleTaskListWrapper.taskList![index].createdDate ?? ''}'),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const Chip(
                                          label: Text(
                                            'Cancle',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () {},
                                          child: const Icon(Icons.edit),
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          child: const Icon(
                                              Icons.delete_forever_outlined,
                                              color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ]),
                            ),
                          );
                        }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getAllCancleTaskList() async {
    _getAllCancleTaskListInProgress = true;
    setState(() {});

    final response = await NetworkCaller.getRequest(Urls.closeTaskList);
    if (response.isSuccess) {
      _cancleTaskListWrapper = TaskListWrapper.fromJson(response.responseBody);
      _getAllCancleTaskListInProgress = false;
      setState(() {});
    } else {
      _getAllCancleTaskListInProgress = false;
      setState(() {});
      if (mounted) {
        showSnackBarMessage(context,
            response.errorMessage ?? 'Get Progress task list has been failed');
      }
    }
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
                  trailing:
                      _isCurrentStatus('New') ? const Icon(Icons.check) : null,
                  onTap: () {
                    if (_isCurrentStatus('New')) {
                      return;
                    }
                    _updateTaskById(id, 'New');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Completed'),
                  trailing: _isCurrentStatus('Completed')
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    if (_isCurrentStatus('Completed')) {
                      return;
                    }
                    _updateTaskById(id, 'Completed');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Progress'),
                  trailing: _isCurrentStatus('Progress')
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    if (_isCurrentStatus('Progress')) {
                      return;
                    }
                    _updateTaskById(id, 'Progress');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Cancelled'),
                  trailing: _isCurrentStatus('Cancelled')
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    if (_isCurrentStatus('Cancelled')) {
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

  bool _isCurrentStatus(String status) {
    for (final task in _cancleTaskListWrapper.taskList!) {
      if (task.status == status) {
        return true;
      }
    }
    return false;
  }

  Future<void> _updateTaskById(String id, String status) async {
    _getAllCancleTaskListInProgress = true;
    setState(() {});

    final response =
        await NetworkCaller.getRequest(Urls.updateTaskStatus(id, status));
    _getAllCancleTaskListInProgress = false;
    setState(() {});

    if (response.isSuccess) {
      _getAllCancleTaskListInProgress = false;
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

  // Future<void> _getAllNewTaskList() async {
  //   _getAllCancleTaskListInProgress = true;
  //   setState(() {});
  //
  //   final response = await NetworkCaller.getRequest(Urls.newTaskList);
  //   if (response.isSuccess) {
  //     _cancleTaskListWrapper = TaskListWrapper.fromJson(response.responseBody);
  //     _getAllCancleTaskListInProgress = false;
  //     setState(() {});
  //   } else {
  //     _getAllCancleTaskListInProgress = false;
  //     setState(() {});
  //     if (mounted) {
  //       showSnackBarMessage(context,
  //           response.errorMessage ?? 'Get new task list has been failed');
  //     }
  //   }
  // }

  Future<void> _deleteTaskById(String id) async {
    _deleteCloseTaskInProgress = true;
    setState(() {});

    final response = await NetworkCaller.getRequest(Urls.deleteTask(id));
    _deleteCloseTaskInProgress = false;
    if (response.isSuccess) {
      _getDataFromApis();
    } else {
      _deleteCloseTaskInProgress = false;
      setState(() {});
      if (mounted) {
        showSnackBarMessage(
            context, response.errorMessage ?? 'Delete task has been failed');
      }
    }
  }
}
