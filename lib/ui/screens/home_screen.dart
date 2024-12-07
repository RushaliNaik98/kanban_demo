import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_demo/blocs/task/task_bloc.dart';
import 'package:kanban_demo/blocs/task/task_event.dart';
import 'package:kanban_demo/blocs/task/task_state.dart';
import 'package:kanban_demo/ui/widgets/kanban_column.dart';

import '../../utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Tabs mapping to statuses
  final List<String> _statuses = ["Home", "To Do", "In Progress", "Completed"];

  @override
  void initState() {
    super.initState();
    // Dispatch FetchTasksEvent to load tasks
    context.read<TaskBloc>().add(FetchTasksEvent());
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kanban Board',
          style: TextStyle(color: Colors.white),
        ),
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
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (_selectedIndex == 0) {
              // Show Kanban columns for "Home" tab
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KanbanColumn(
                        columnTitle: "To Do",
                        status: "To Do",
                        color: Colors
                            .orangeAccent, // Adjusted to a more vibrant orange
                        icon: Icons.task,
                        titleColor: Colors.black, // Darker color for title text
                        iconColor: Colors.black, // Darker icon color
                      ),
                      SizedBox(width: 16),
                      KanbanColumn(
                        columnTitle: "In Progress",
                        status: "In Progress",
                        color: Colors.blueAccent, // Lively blue
                        icon: Icons.sync,
                        titleColor:
                            Colors.white, // White title for better contrast
                        iconColor:
                            Colors.white, // White icon color for readability
                      ),
                      SizedBox(width: 16),
                      KanbanColumn(
                        columnTitle: "Done",
                        status: "Completed",
                        color: Colors.lightGreen, // Fresh green
                        icon: Icons.check_circle,
                        titleColor:
                            Colors.white, // White title for better contrast
                        iconColor:
                            Colors.white, // White icon color for readability
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TaskLoaded) {
              // Filter tasks based on the selected status
              final filteredTasks = state.tasks
                  .where(
                      (task) => task.description == _statuses[_selectedIndex])
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        task.content,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        task.description == 'Completed'
                            ? Text(
                                'Time taken: ${task.duration!.amount.toString()} Min')
                            : Text(task.description ?? ''),
                            Text('Created on: ${formatDate(task.createdAt)}'),
                            Text('Created on: ${task.priority}')
                      ]),
                      leading: Icon(
                        _selectedIndex == 1
                            ? Icons.task
                            : _selectedIndex == 2
                                ? Icons.sync 
                                : Icons.check_circle,
                        color: _selectedIndex == 1
                            ? Colors.orangeAccent
                            : _selectedIndex == 2
                                ? Colors.blueAccent
                                : Colors.lightGreen,
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('Failed to load tasks'));
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // fixedColor: Colors.deepPurple,
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        backgroundColor: Colors.deepPurple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'To Do',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            label: 'In Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Completed',
          ),
        ],
      ),
    );
  }
}
