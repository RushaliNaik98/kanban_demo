import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this dependency in pubspec.yaml

import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_state.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TaskLoaded) {
          final totalTasks = state.tasks.length;
          final completedTasks = state.tasks
              .where((task) => task.description == "Completed")
              .length;
          final inProgressTasks = state.tasks
              .where((task) => task.description == "In Progress")
              .length;
          final toDoTasks = state.tasks
              .where((task) => task.description == "To Do")
              .length;

          // Adjust colors for dark and light themes
          final completedColor = isDarkMode ? Color(0xff757575) : Color(0xff949494);
          final inProgressColor = isDarkMode ? Color(0xff2196f3) : Color(0xff3eaced);
          final toDoColor = isDarkMode ? Color(0xff4caf50) : Color(0xff38c589);

          // Pie chart data
          final pieChartSections = [
            if (completedTasks > 0)
              PieChartSectionData(
                value: completedTasks.toDouble(),
                title: 'Completed',
                color: completedColor,
                radius: 50,
                titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            if (inProgressTasks > 0)
              PieChartSectionData(
                value: inProgressTasks.toDouble(),
                title: 'In Progress',
                color: inProgressColor,
                radius: 50,
                titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            if (toDoTasks > 0)
              PieChartSectionData(
                value: toDoTasks.toDouble(),
                title: 'To Do',
                color: toDoColor,
                radius: 50,
                titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
              ),
          ];

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                "$totalTasks tasks in total",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              // Pie chart with legend in a row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    child: PieChart(
                      PieChartData(
                        sections: pieChartSections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 4,
                        borderData: FlBorderData(show: false),
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            if (response == null || response.touchedSection == null) {
                              return;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Legend(color: toDoColor, text: "To Do"),
                  const SizedBox(height: 8),
                  Legend(color: inProgressColor, text: "In Progress"),
                  const SizedBox(height: 8),
                  Legend(color: completedColor, text: "Completed"),
                ],
              ),
            ],
          );
        } else {
          // Handle error or empty state
          return const Center(
            child: Text("No data available"),
          );
        }
      },
    );
  }
}

class Legend extends StatelessWidget {
  final Color color;
  final String text;

  const Legend({Key? key, required this.color, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
