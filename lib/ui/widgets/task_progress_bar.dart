import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../blocs/task/task_state.dart';
import '../../models/task.dart';
import '../../utils/colors.dart';

class TaskProgressBar extends StatefulWidget {
  const TaskProgressBar({super.key});

  @override
  _TaskProgressBarState createState() => _TaskProgressBarState();
}

class _TaskProgressBarState extends State<TaskProgressBar> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    // Dispatch FetchTasksEvent to load tasks
    context.read<TaskBloc>().add(FetchTasksEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Detect if the app is in dark mode
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          // Show loading indicator while fetching tasks
          return const Center(child: CircularProgressIndicator());
        } else if (state is TaskLoaded) {
          tasks = state.tasks;

          int totalTasks = tasks.length;

          // Categorize tasks based on their description or relevant logic
          int toDoTasks = tasks
              .where((task) =>
                  task.description != null && task.description == 'To Do')
              .length;
          int inProgressTasks = tasks
              .where((task) =>
                  task.description != null && task.description == 'In Progress')
              .length;
          int completedTasks = tasks
              .where((task) =>
                  task.description != null && task.description == 'Completed')
              .length;

          double progress = totalTasks > 0 ? completedTasks / totalTasks : 0;

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress: ${(progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textColor(isDarkMode),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 10.0,
                  child: LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(12),
                    value: progress,
                    backgroundColor: AppColors.todoColor(isDarkMode),
                    color: AppColors.primaryColor(isDarkMode),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Tasks: $totalTasks | To Do: $toDoTasks | In Progress: $inProgressTasks | Completed: $completedTasks',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.statusBarTextColor(isDarkMode),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        } else if (state is TaskError) {
          // Show error message
          return Center(
            child: Text(
              'Error loading tasks: ${state.message}',
              style: TextStyle(color: AppColors.textColor(isDarkMode)),
            ),
          );
        } else {
          // Fallback UI
          return Center(
            child: Text(
              'Unexpected state',
              style: TextStyle(color: AppColors.textColor(isDarkMode)),
            ),
          );
        }
      },
    );
  }
}
