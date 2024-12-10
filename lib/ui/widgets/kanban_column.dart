import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_demo/blocs/task/task_bloc.dart';
import 'package:kanban_demo/blocs/task/task_event.dart';
import 'package:kanban_demo/models/task.dart';
import 'package:kanban_demo/utils/responsive.dart';

import '../../blocs/task/task_state.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/theme/theme_state.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import '../screens/add_task_screen.dart';
import '../screens/edit_task_screen.dart';
import 'kanban_card.dart';

class KanbanColumn extends StatelessWidget {
  final String columnTitle;
  final String status;
  final Color color;
  final IconData icon;
  final Color titleColor; // Added color for the column title
  final Color iconColor; // Added color for the icon
  final Locale? locale;

  const KanbanColumn({
    required this.columnTitle,
    required this.status,
    required this.color,
    required this.icon,
    required this.titleColor, // Initialize titleColor
    required this.iconColor, // Initialize iconColor
    this.locale

  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (context, themeState) {
      final isDarkMode = themeState is DarkThemeState;
      return Container(
        width:Responsive.isDesktop(context) ? size.width * 0.3 : size.width * 0.5,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: AppColors.columnColor(isDarkMode),
          borderRadius: BorderRadius.circular(16),
          // border: Border.all(color: color, width: 2),
          // boxShadow: [
          //   BoxShadow(
          //     color: color.withOpacity(0.2),
          //     blurRadius: 8,
          //     offset: const Offset(0, 4),
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Column Header with Title and Add Task Button
            Container(
              height: 70,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(icon, color: iconColor),
                        const SizedBox(width: 4),
                        Text(
                          columnTitle,
                          style: TextStyle(
                            fontSize:  locale?.languageCode == 'en' ? 18 : 14,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: status == 'To Do',
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTaskScreen(
                              columnTitle: columnTitle,
                              status: status,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Icon(Icons.add, color: color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: DragTarget<Task>(
                onAccept: (task) {
                  final duedata = Due(datetime: DateTime.now().toString());
                  final durationData = status == 'Completed'
                      ? DurationModel(
                          amount: DateTime.now()
                              .difference(
                                  DateTime.parse(task.due?.datetime ?? ''))
                              .inMinutes,
                          unit: "minute",
                        )
                      : null;
                  // Update the task's status and trigger the API call
                  final updatedTask = Task(
                    id: task.id,
                    content: task.content,
                    description:
                        status, // Update the status to match the column
                    priority: task.priority,
                    createdAt: status == 'In Progress'
                        ? DateTime.now().toString()
                        : task.createdAt,
                    due: status == 'In Progress' ? duedata : Due(),
                    date: status == 'In Progress'
                        ? DateTime.now().toString()
                        : task.createdAt,
                    duration: status == 'Completed' ? durationData : null,
                  );
                  if (task.description != status) {
                    // Dispatch update event and then fetch tasks again to update the UI
                    context
                        .read<TaskBloc>()
                        .add(UpdateTaskEvent(task: updatedTask));
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  return BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, state) {
                      if (state is TaskLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is TaskLoaded) {
                        final tasks = state.tasks
                            .where((task) => task.description == status)
                            .toList();
                        return ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditTaskScreen(task: task),
                                  ),
                                );
                              },
                              child: KanbanCard(task: task),
                            );
                          },
                        );
                      } else if (state is TaskUpdated) {
                        final tasks = state.task.description == status
                            ? [state.task]
                            : [];
                        // context.read<TaskBloc>().add(FetchTasksEvent());
                        // WidgetsBinding.instance.addPostFrameCallback((_) {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(content: Text('Task updated successfully!')),
                        //   );
                        // });

                        return ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return KanbanCard(task: task);
                          },
                        );
                      } else if (state is TaskAdded) {
                        final tasks = state.task.description == status
                            ? [state.task]
                            : [];
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Task added successfully!')),
                          );
                        });
                        return ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return KanbanCard(task: task);
                          },
                        );
                      } else {
                        return const Center(child: Text('No tasks found'));
                      }
                    },
                  );
                },
              ),
            )
          ],
        ),
      );
    });
  }
}
