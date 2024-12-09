import 'package:flutter/material.dart';
import 'package:kanban_demo/blocs/comment/comment_bloc.dart';
import 'package:kanban_demo/blocs/theme/theme_bloc.dart';
import 'package:kanban_demo/blocs/theme/theme_state.dart';
import 'package:kanban_demo/repositories/comment_repository.dart';
import 'blocs/task/task_bloc.dart';
import 'blocs/timer/timer_bloc.dart';
import 'repositories/task_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ui/screens/home_screen.dart';

class MyApp extends StatelessWidget {
  final TaskRepository taskRepository;
  final CommentRepository commentRepository;

  const MyApp({
    Key? key,
    required this.taskRepository,
    required this.commentRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(
          create: (context) => TaskBloc(taskRepository: taskRepository),
        ),
        BlocProvider<CommentBloc>(
          create: (context) =>
              CommentBloc(commentRepository: commentRepository),
        ),
        BlocProvider<TimerBloc>(
          create: (context) => TimerBloc(),
        ),
        BlocProvider<ThemeBloc>(
          // Add ThemeBloc here
          create: (context) => ThemeBloc(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        // Listen for theme changes
        builder: (context, state) {
          return MaterialApp(
            title: 'Kanban Demo',
            theme: state.themeData, // Use the theme from ThemeBloc
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}
