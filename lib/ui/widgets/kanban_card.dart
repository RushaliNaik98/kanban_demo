import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_demo/models/task.dart';
import 'package:kanban_demo/utils/colors.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../blocs/timer/timer_bloc.dart';
import '../../blocs/timer/timer_event.dart';
import '../../blocs/timer/timer_state.dart';
import '../../utils/helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class KanbanCard extends StatelessWidget {
  final Task task;

  KanbanCard({required this.task});

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Draggable<Task>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 200,
          // height: 80,
          child: Card(
            elevation: 8,
            color: _getCardColorForStatus(context),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(capitalize(task.content),
                  style: const TextStyle(color: Colors.black)),
            ),
          ),
        ),
      ),
      childWhenDragging: const Opacity(opacity: 0.5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getCardColorForStatus(context),
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
              contentPadding: const EdgeInsets.only(left: 16, right: 4.0),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          capitalize(task.content),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "${AppLocalizations.of(context)!
                          .priority}: ${getPriorityLabel(task.priority ?? 0)}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: isDarkTheme ? Colors.white : Colors.grey[800],
                    ),
                    onPressed: () {
                      final int? taskId = int.tryParse(task.id ?? '');
                      if (taskId != null) {
                        context
                            .read<TaskBloc>()
                            .add(DeleteTaskEvent(taskId: taskId));
                      } else {
                        print("Error: Task ID is invalid or null");
                      }
                    },
                  ),
                ],
              ),
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
                            padding:
                                const EdgeInsets.only(bottom: 8.0, left: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.lock_clock_outlined,
                                    color: isDarkTheme
                                        ? const Color(0xfff4b400)
                                        : Colors.white),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "Time Taken: ${task.duration?.amount == 1 ? 'Less than 1' : task.duration?.amount} Min",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Display time for "In Progress" tasks with timer
                        if (task.description == 'In Progress')
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8.0, left: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.av_timer_outlined,
                                    color: isDarkTheme
                                        ? const Color(0xfff4b400)
                                        : Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  "Time: $timerText Mins",
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
  Color _getCardColorForStatus(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    switch (task.description) {
      case 'In Progress':
        return isDarkTheme ? const Color(0xff4a90e2) : const Color(0xff7bc3f0);
      case 'Completed':
        return isDarkTheme ? const Color(0xff1cb878) : const Color(0xff5bd9a6);
      default:
        return isDarkTheme ? const Color(0xffa6a6a6) : const Color(0xffe0e0e0);
    }
  }
}
