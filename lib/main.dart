import 'package:flutter/material.dart';
import 'package:kanban_demo/repositories/comment_repository.dart';

import 'app.dart';
import 'repositories/task_repository.dart';

String baseUrl = "https://api.todoist.com/rest/v2";
const String token = 'a084279cd597fd0465b02b64abc33568d17df13a';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final localStorageService = LocalStorageService();

  // Initialize repositories
  final taskRepository = TaskRepository();
  final commentRepository =
      CommentRepository(baseUrl: baseUrl, authToken: token);

  // Initialize the app
  runApp(MyApp(
      taskRepository: taskRepository, commentRepository: commentRepository));
}
