import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/comment/comment_bloc.dart';
import '../../blocs/comment/comment_event.dart';
import '../../blocs/comment/comment_state.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../models/comment.dart';
import '../../models/task.dart';
import '../../utils/helpers.dart';

// Import your required models, blocs, and utility functions here.

class EditTaskScreen extends StatelessWidget {
  final Task task;

  const EditTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController =
        TextEditingController(text: task.content);
    final TextEditingController commentController = TextEditingController();
    final TextEditingController fileUrlController = TextEditingController();
    final TextEditingController fileNameController = TextEditingController();
    final TextEditingController fileTypeController = TextEditingController();

    context.read<CommentBloc>().add(FetchCommentsEvent(taskId: task.id ?? ''));
    int priority = task.priority ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title
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
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              readOnly: task.description != 'To Do',
            ),
            const SizedBox(height: 16),

            // Priority Dropdown
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
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text("Normal")),
                  DropdownMenuItem(value: 2, child: Text("High")),
                  DropdownMenuItem(value: 3, child: Text("Very High")),
                  DropdownMenuItem(value: 4, child: Text("Urgent")),
                ],
              ),
            const SizedBox(height: 16),

            // Comments Section
            if (task.commentCount! > 0)
              const Text(
                "Comments",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            if (task.commentCount! > 0)
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
                                    )
                                  : Text(comment.content),
                              subtitle: Text(
                                "Added on ${formatDate(comment.postedAt.toString())}",
                                style: const TextStyle(color: Colors.black54),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isEditing ? Icons.check : Icons.edit,
                                      color: isEditing
                                          ? Colors.green
                                          : Colors.blue,
                                    ),
                                    onPressed: () {
                                      if (isEditing) {
                                        // Save action
                                        if (commentController.text.isNotEmpty) {
                                          context.read<CommentBloc>().add(
                                                UpdateCommentEvent(
                                                  commentId: comment.id,
                                                  content:
                                                      commentController.text,
                                                  taskId: task.id ?? '',
                                                ),
                                              );

                                          setState(() => isEditing = false);
                                        }
                                      } else {
                                        // Edit action
                                        setState(() => isEditing = true);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      // Delete action
                                      context.read<CommentBloc>().add(
                                            DeleteCommentEvent(
                                              commentId: comment.id,
                                              taskId: task.id ?? '',
                                            ),
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
                    print('error $CommentError');
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Save Button
            Center(
              child: ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple, // White text
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  ),
                ),
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
