import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_demo/blocs/task/task_bloc.dart';
import 'package:kanban_demo/blocs/task/task_event.dart';
import 'package:kanban_demo/models/task.dart';
import 'package:kanban_demo/utils/helpers.dart';
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
  final Color titleColor; // Added color for the column title
  final Color iconColor; // Added color for the icon

  const KanbanColumn({
    required this.columnTitle,
    required this.status,
    required this.color,
    required this.icon,
    required this.titleColor, // Initialize titleColor
    required this.iconColor, // Initialize iconColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header with Title and Add Task Button
          Container(
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
                Row(
                  children: [
                    Icon(icon, color: iconColor),
                    const SizedBox(width: 8),
                    Text(
                      columnTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: titleColor, // Use titleColor for the title text
                      ),
                    )
                  ],
                ),
                Visibility(
                  visible: status == 'To Do',
                  child: ElevatedButton(
                    onPressed: () {
                      _showAddTaskDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
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
                  description: status, // Update the status to match the column
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
    int priority = 1; // Default priority value

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
          ),
          backgroundColor: Colors.deepPurple[100], // Light purple background
          title: Text(
            "Add Task to \"$columnTitle\"",
            style: const TextStyle(
              color: Colors.deepPurple,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: taskController,
                  decoration: InputDecoration(
                    labelText: "Task Title",
                    hintText: "Enter task title",
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Rounded border
                      borderSide: const BorderSide(
                          color: Colors.deepPurple, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                          color: Colors.deepPurpleAccent, width: 2.0),
                    ),
                    prefixIcon: const Icon(Icons.task,
                        color: Colors.deepPurple), // Icon in the input field
                  ),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16.0), // Spacer between fields
                // Dropdown for Priority
                DropdownButtonFormField<int>(
                  value: priority,
                  onChanged: (newPriority) {
                    if (newPriority != null) {
                      priority = newPriority;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Priority",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                          color: Colors.deepPurple, width: 1.5),
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
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextButton(
                onPressed: () {
                  if (taskController.text.isNotEmpty) {
                    // Create a task and dispatch AddTaskEvent
                    final task = Task(
                      content: taskController.text,
                      description: status,
                      priority: priority, // Use the selected priority
                    );
                    print(
                        "Dispatching AddTaskEvent with task: ${task.content}");
                    context.read<TaskBloc>().add(AddTaskEvent(task: task));

                    // Trigger a fetch of tasks after the task is added (if necessary)
                    // context.read<TaskBloc>().add(FetchTasksEvent());

                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Text(
                    "Add",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
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
  int priority = task.priority ?? 0;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), // Rounded corners
            ),
            backgroundColor: Colors.white, // Light purple background
            title: const Column(
              children: [
                Text(
                  "Task Details",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Note: Only tasks in the 'To Do' state can be edited",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            content: SingleChildScrollView(
              // To make it scrollable if content is large
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Title

                  const SizedBox(height: 8),
                  Text(
                    task.description == 'To Do' ? "Edit Title:" : "Title",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: "Enter task title",
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12.0), // Rounded corners
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    readOnly: task.description !=
                        'To Do', // Prevent editing if task is not "To Do"
                  ),
                  const SizedBox(height: 16),
                  if (task.description == 'To Do')
                    DropdownButtonFormField<int>(
                      value: priority,
                      onChanged: (newPriority) {
                        if (newPriority != null) {
                          priority = newPriority;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Priority",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                              color: Colors.deepPurple, width: 1.5),
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
                  if (task.commentCount! > 0) const SizedBox(height: 16),
                  if (task.commentCount! > 0)
                    const Text(
                      "Comments",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  // Display comments
                  BlocBuilder<CommentBloc, CommentState>(
                    builder: (context, state) {
                      if (state is CommentLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is CommentLoaded) {
                        return Column(
                          children: state.comments.map((comment) {
                            TextEditingController commentController =
                                TextEditingController(text: comment.content);

                            bool isEditing = false;

                            return StatefulBuilder(
                              builder: (context, setState) {
                                return ListTile(
                                  title: isEditing
                                      ? TextField(
                                          controller: commentController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            hintText: "Edit comment",
                                          ),
                                          onSubmitted: (newContent) {
                                            if (newContent.isNotEmpty) {
                                              // Call the API to update the comment
                                              context.read<CommentBloc>().add(
                                                    UpdateCommentEvent(
                                                      commentId: comment.id ,
                                                      content: newContent, taskId: task.id ?? '',
                                                    ),
                                                  );
                                              setState(() => isEditing = false);
                                            }
                                          },
                                        )
                                      : Text(comment.content),
                                  subtitle: Text(
                                    "Added on ${formatDate(comment.postedAt.toString())}",
                                    style:
                                        const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          setState(
                                              () => isEditing = !isEditing);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          // Call the API to delete the comment
                                          context.read<CommentBloc>().add(
                                                DeleteCommentEvent(
                                                    commentId: comment.id, taskId: task.id ?? ''),
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
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
                  // Add Comment
                  const Text(
                    "Add Comment:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextFormField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: "Enter comments",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.deepPurple),
                ),
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
                      priority: priority,
                    );
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
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple, // White text
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
