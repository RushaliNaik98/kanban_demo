import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_demo/blocs/task/task_bloc.dart';
import 'package:kanban_demo/blocs/task/task_event.dart';
import 'package:kanban_demo/ui/widgets/kanban_column.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dispatch FetchTasksEvent when HomeScreen is built
    context.read<TaskBloc>().add(FetchTasksEvent());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanban Board'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KanbanColumn(
                  columnTitle: "To Do",
                  status: "To Do",
                  color: Colors.orangeAccent,
                  icon: Icons.task,
                ),
                SizedBox(width: 16),
                KanbanColumn(
                  columnTitle: "In Progress",
                  status: "In Progress",
                  color: Colors.blueAccent,
                  icon: Icons.sync,
                ),
                SizedBox(width: 16),
                KanbanColumn(
                  columnTitle: "Completed",
                  status: "Completed",
                  color: Colors.greenAccent,
                  icon: Icons.check_circle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
