import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_demo/blocs/task/task_bloc.dart';
import 'package:kanban_demo/blocs/task/task_event.dart';
import 'package:kanban_demo/models/task.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/comment/comment_bloc.dart';
import '../../blocs/comment/comment_event.dart';
import '../../blocs/comment/comment_state.dart';
import '../../blocs/task/task_state.dart';
import '../../models/comment.dart';
import 'kanban_card.dart';

class KanbanColumn extends StatelessWidget {
  final String columnTitle;
  final String status;
  final Color color;
  final IconData icon;

  const KanbanColumn({
    required this.columnTitle,
    required this.status,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and To Do Button inside a Row
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 8),
                    Text(
                      columnTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                Visibility(
                    visible: status == 'To Do',
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddTaskDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      child: const Icon(Icons.add, color: Colors.blue),
                    )),
              ],
            ),
          ),
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
                    duration: status == 'Completed' ? durationData : null);

                // Dispatch update event and then fetch tasks again to update the UI
                context
                    .read<TaskBloc>()
                    .add(UpdateTaskEvent(task: updatedTask));
                // context.read<TaskBloc>().add(FetchTasksEvent());
              },
              builder: (context, candidateData, rejectedData) {
                return BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    debugPrint('state $state');
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
                              _showEditTaskDialog(context, task);
                            },
                            child: KanbanCard(task: task),
                          );
                        },
                      );
                    } else if (state is TaskUpdated) {
                      final tasks =
                          state.task.description == status ? [state.task] : [];

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
                      final tasks =
                          state.task.description == status ? [state.task] : [];

                      // context.read<TaskBloc>().add(FetchTasksEvent());

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
  }

  void _showAddTaskDialog(BuildContext context) {
    final taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Task to $columnTitle"),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(hintText: "Enter task title"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  // Create a task and dispatch AddTaskEvent
                  final task = Task(
                    content: taskController.text,
                    description: status,
                    priority: 1,
                  );
                  print("Dispatching AddTaskEvent with task: ${task.content}");
                  context.read<TaskBloc>().add(AddTaskEvent(task: task));

                  // Trigger a fetch of tasks after the task is added
                  // context.read<TaskBloc>().add(FetchTasksEvent());

                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            )
          ],
        );
      },
    );
  }
}

void _showEditTaskDialog(BuildContext context, Task task) {
  final TextEditingController titleController =
      TextEditingController(text: task.content);
  final TextEditingController commentController = TextEditingController();
  final TextEditingController fileUrlController = TextEditingController();
  final TextEditingController fileNameController = TextEditingController();
  final TextEditingController fileTypeController = TextEditingController();

  context.read<CommentBloc>().add(FetchCommentsEvent(taskId: task.id ?? ''));

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Task Details"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Prevents intrinsic height calculation
              children: [
                // Display comments
                BlocBuilder<CommentBloc, CommentState>(
                  builder: (context, state) {
                    if (state is CommentLoading) {
                      return const CircularProgressIndicator();
                    } else if (state is CommentLoaded) {
                      return Column(
                        children: state.comments.map((comment) {
                          return ListTile(
                            title: Text(comment.content),
                            subtitle: Text(
                              "Added on ${comment.postedAt.toLocal()}",
                            ),
                          );
                        }).toList(),
                      );
                    } else if (state is CommentError) {
                      return Text("Failed to load comments: ${state.error}");
                    }
                    return Container();
                  },
                ),
                const SizedBox(height: 16),

                // Task Title
                Text(
                  task.description == 'To Do' ? "Edit Title:" : "Title",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: "Enter task title",
                    border: OutlineInputBorder(),
                  ),
                  readOnly: task.description != 'To Do',
                ),
                const SizedBox(height: 16),

                // Add Comment
                const Text(
                  "Add Comment:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: "Enter comments",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Title cannot be empty')),
                    );
                    return;
                  }
                  if (task.description == 'To Do') {
                    // Dispatch the UpdateTaskEvent with updated task details
                    final updatedTask = Task(
                      id: task.id,
                      content: titleController.text,
                      description: task.description,
                      priority: task.priority,
                    );

                    // Call the API to update the task title
                    context
                        .read<TaskBloc>()
                        .add(UpdateTaskEvent(task: updatedTask));
                  }

                  // If a comment was entered, add it to the task
                  if (commentController.text.isNotEmpty) {
                    final attachment = (fileUrlController.text.isNotEmpty &&
                            fileNameController.text.isNotEmpty &&
                            fileTypeController.text.isNotEmpty)
                        ? Attachment(
                            fileUrl: fileUrlController.text,
                            fileName: fileNameController.text,
                            fileType: fileTypeController.text,
                            resourceType: 'file',
                          )
                        : null;

                    final addCommentRequest = AddCommentRequest(
                      taskId: task.id ?? '',
                      content: commentController.text,
                      attachment: attachment,
                    );

                    // Trigger AddComment API call
                    context
                        .read<CommentBloc>()
                        .add(AddCommentEvent(request: addCommentRequest));
                  }

                  Navigator.pop(context); // Close the dialog
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}
