import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/theme/theme_state.dart';
import '../../models/task.dart';
import '../../utils/colors.dart';

class AddTaskScreen extends StatefulWidget {
  final String columnTitle;
  final String status;

  const AddTaskScreen(
      {Key? key, required this.columnTitle, required this.status})
      : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController taskController = TextEditingController();
  int priority = 1; // Default priority value

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (context, themeState) {
      final isDarkMode = themeState is DarkThemeState;
      return Scaffold(
        appBar: AppBar(
          title: Text('Add Task to "${widget.columnTitle}"',
              style: TextStyle(
                  color: AppColors.appNameColor(isDarkMode),
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          backgroundColor: AppColors.backgroundColor(isDarkMode),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                      color: AppColors.innerScreenTextColor(isDarkMode),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  labelText: "Task Title",
                  hintText: "Enter task title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Rounded border
                    borderSide:
                        const BorderSide(color: Colors.deepPurple, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                        color: Colors.deepPurpleAccent, width: 2.0),
                  ),
                  prefixIcon: const Icon(Icons.task,
                      color: Colors.deepPurple), // Icon in the input field
                ),
                style: const TextStyle(fontSize: 16.0, color: Colors.black),
              ),
              const SizedBox(height: 16.0), // Spacer between fields
              DropdownButtonFormField<int>(
                value: priority,
                onChanged: (newPriority) {
                  if (newPriority != null) {
                    setState(() {
                      priority = newPriority;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: "Priority",
                  labelStyle: TextStyle(
                      color: AppColors.innerScreenTextColor(isDarkMode),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide:
                        const BorderSide(color: Colors.deepPurple, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                        color: Colors.deepPurpleAccent, width: 2.0),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text("Normal")),
                  DropdownMenuItem(value: 2, child: Text("High")),
                  DropdownMenuItem(value: 3, child: Text("Very High")),
                  DropdownMenuItem(value: 4, child: Text("Urgent")),
                ],
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    if (taskController.text.isNotEmpty) {
                      // Create a task and dispatch AddTaskEvent
                      final task = Task(
                        content: taskController.text,
                        description: widget.status,
                        priority: priority, // Use the selected priority
                      );
                      print(
                          "Dispatching AddTaskEvent with task: ${task.content}");
                      context.read<TaskBloc>().add(AddTaskEvent(task: task));

                      // Navigate back after adding the task
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    "Add",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
