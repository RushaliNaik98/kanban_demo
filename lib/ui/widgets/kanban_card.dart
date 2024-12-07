import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_demo/models/task.dart';
import '../../blocs/timer/timer_bloc.dart';
import '../../blocs/timer/timer_event.dart';
import '../../blocs/timer/timer_state.dart';
import '../../utils/helpers.dart';

class KanbanCard extends StatelessWidget {
  final Task task;

  KanbanCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Draggable<Task>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 200,
          height: 80,
          child: Card(
            elevation: 8,
            color: Colors.blueGrey.withOpacity(0.7),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(task.content,
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
      childWhenDragging: const Opacity(opacity: 0.5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getCardColorForStatus(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(capitalize(task.content),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            if (task.description == 'In Progress' ||
                task.description == 'Completed')
              BlocProvider(
                create: (context) {
                  final createdAtString = task.due?.datetime;
                  final createdAt = createdAtString != null
                      ? DateTime.tryParse(createdAtString)
                      : DateTime.now();

                  final timerBloc = TimerBloc();

                  if (task.description == 'In Progress') {
                    if (createdAt != null) {
                      final elapsedTime = DateTime.now().difference(createdAt);
                      timerBloc.add(
                          StartTimerEvent(initialElapsedTime: elapsedTime));
                    }
                  } else if (task.description == 'Completed') {
                    if (createdAt != null) {
                      final elapsedTime = DateTime.now().difference(createdAt);
                      timerBloc.add(StopTimerEvent());
                    }
                  }

                  return timerBloc;
                },
                child: BlocBuilder<TimerBloc, TimerState>(
                  builder: (context, state) {
                    String timerText = "00:00";

                    if (state is TimerRunning || state is TimerStopped) {
                      final elapsedTime = state is TimerRunning
                          ? state.elapsedTime
                          : (task.due?.datetime != null
                              ? DateTime.now().difference(
                                  DateTime.parse(task.due!.datetime!))
                              : Duration.zero);

                      final minutes = elapsedTime.inMinutes;
                      final seconds = elapsedTime.inSeconds % 60;
                      timerText =
                          "$minutes:${seconds.toString().padLeft(2, '0')}";
                    }

                    return Column(
                      children: [
                        // Display time for "Completed" tasks
                        if (task.description == 'Completed')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0, left: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  "Time Taken: ${task.duration?.amount == 1 ? 'Less than 1' : task.duration?.amount} Min",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Display time for "In Progress" tasks with timer
                        if (task.description == 'In Progress')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0, left : 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.timer,
                                    color: Colors.orangeAccent),
                                const SizedBox(width: 8),
                                Text(
                                  "Time: $timerText",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                // const SizedBox(width: 20),
                                // IconButton(
                                //   icon: const Icon(Icons.pause,
                                //       color: Colors.white),
                                //   onPressed: () {
                                //     // Add logic to stop timer
                                //     context
                                //         .read<TimerBloc>()
                                //         .add(StopTimerEvent());
                                //   },
                                // ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper function to get the card color based on task status
  Color _getCardColorForStatus() {
    switch (task.description) {
      case 'In Progress':
        return Colors.blueAccent.withOpacity(0.8); // Blue for In Progress
      case 'Completed':
        return Colors.lightGreen.withOpacity(0.8); // Green for Completed
      default:
        return Colors.orangeAccent
            .withOpacity(0.8); // Orange for default status (e.g., To Do)
    }
  }
}
