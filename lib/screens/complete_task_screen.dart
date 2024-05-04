import 'package:flutter/material.dart';
import 'package:task_manager/data/models/task_list_wrapper.dart';
import '../data/services/network_caller.dart';
import '../data/utlity/urls.dart';
import '../widgets/empty_list_widget.dart';
import '../widgets/profileAppBar.dart';
import '../widgets/snack_bar_message.dart';


class CompleteTaskScreen extends StatefulWidget {
  const CompleteTaskScreen({super.key});



  @override
  State<CompleteTaskScreen> createState() => _CompleteTaskScreenState();
}

class _CompleteTaskScreenState extends State<CompleteTaskScreen> {
  bool _getAllCompletedTaskListInProgress = false;
  TaskListWrapper _completedTaskListWrapper = TaskListWrapper();

  // @override
  // void initState() {
  //   super.initState();
  //   _getAllCompletedTaskList();
  // }

  @override
  void initState() {
    super.initState();
    _getDataFromApis();
  }

  void _getDataFromApis() {
    _getAllCompletedTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: profileAppBar,
      body:  RefreshIndicator(
        onRefresh: ()async{
          _getDataFromApis();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Visibility(
                  visible: _getAllCompletedTaskListInProgress == false,
                  replacement: const Center(child: CircularProgressIndicator(),),
                  child: Visibility(
                    visible: _completedTaskListWrapper.taskList?.isNotEmpty ?? false,
                    replacement: const EmptyListWidget(),
                    child: ListView.builder(
                        itemCount: _completedTaskListWrapper.taskList?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.white,
                            child: ListTile(
                              title:  Text(_completedTaskListWrapper.taskList![index].title ?? ''),
                              subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     Text(
                              _completedTaskListWrapper.taskList![index].description ?? '',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 10,
                                    ),
                                     Text('Date: ${_completedTaskListWrapper.taskList![index].title ?? ''}'),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const Chip(label: Text('Complete', style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),),
                                          backgroundColor: Colors.green,
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: () {
                                            _showUpdatesStateDialog(_completedTaskListWrapper.taskList![index].sId!);
                                          }, icon: const Icon(Icons.edit),),
                                        IconButton(onPressed: () {
                                          _deleteTaskById(_completedTaskListWrapper
                                              .taskList![index].sId!);
                                        },
                                          icon: const Icon(Icons.delete_forever_outlined,
                                              color: Colors.red),),
                                      ],
                                    ),
                                  ]
                              ),
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
  bool _isCurrentStatus(String status) {
    for (final task in _completedTaskListWrapper.taskList!) {
      if (task.status == status) {
        return true;
      }
    }
    return false;
  }
  // bool _isCurrentStatus(String status) {
  //   return _completedTaskListWrapper.status == status;
  // }
  Future<void>_getAllCompletedTaskList() async{
    _getAllCompletedTaskListInProgress = true;
    setState(() {});

    final response = await NetworkCaller.getRequest(Urls.completedTaskList);
    if(response.isSuccess){
      _completedTaskListWrapper = TaskListWrapper.fromJson(response.responseBody);
      _getAllCompletedTaskListInProgress =false;
      setState(() {});
    }else{
      _getAllCompletedTaskListInProgress = false;
      setState(() {});
      if(mounted) {
        showSnackBarMessage(context,
            response.errorMessage ?? 'Get completed task list has been failed');
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
  Future<void> _updateTaskById(String id,String status) async{
    _getAllCompletedTaskListInProgress = true;
    setState(() {});

    final response = await NetworkCaller.getRequest(Urls.updateTaskStatus(id, status));
    _getAllCompletedTaskListInProgress = false;
    setState(() {});

    if(response.isSuccess){
      _getAllCompletedTaskListInProgress =false;
      setState(() {});
      _getDataFromApis();
    }else{
      setState(() {});
      if(mounted){
        showSnackBarMessage(context, response.errorMessage ?? 'Update task status has been failed');
      }
    }

  }
  Future<void>_getAllNewTaskList() async{
    setState(() {});

    final response = await NetworkCaller.getRequest(Urls.newTaskList);
    if(response.isSuccess){
      _completedTaskListWrapper = TaskListWrapper.fromJson(response.responseBody);
      setState(() {});
    }else{
      setState(() {});
      if(mounted) {
        showSnackBarMessage(context,
            response.errorMessage ?? 'Get new task list has been failed');
      }
    }
  }
  Future<void> _deleteTaskById(String id) async {
    setState(() {});

    final response = await NetworkCaller.getRequest(Urls.deleteTask(id));
    if (response.isSuccess) {
      _getDataFromApis();
    } else {
      setState(() {});
      if (mounted) {
        showSnackBarMessage(
            context, response.errorMessage ?? 'Delete task has been failed');
      }
    }
  }
}





