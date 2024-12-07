import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_demo/models/task.dart';
import '../../blocs/timer/timer_bloc.dart';
import '../../blocs/timer/timer_event.dart';
import '../../blocs/timer/timer_state.dart';

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
            elevation: 4,
            child: ListTile(
              title: Text(task.content),
            ),
          ),
        ),
      ),
      childWhenDragging: const Opacity(opacity: 0.5),
      child: Card(
        margin: const EdgeInsets.all(8),
        elevation: 4,
        child: Column(
          children: [
            ListTile(
              title: Text(task.content),
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
                      final elapsedTime =
                          DateTime.now().difference(createdAt);
                      timerBloc.add(
                          StartTimerEvent(initialElapsedTime: elapsedTime));
                    }
                  } else if (task.description == 'Completed') {
                    if (createdAt != null) {
                      final elapsedTime =
                          DateTime.now().difference(createdAt);
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
                              ? DateTime.now()
                                  .difference(DateTime.parse(task.due!.datetime!))
                              : Duration.zero);

                      final minutes = elapsedTime.inMinutes;
                      final seconds = elapsedTime.inSeconds % 60;
                      timerText =
                          "$minutes:${seconds.toString().padLeft(2, '0')}";
                    }

                    return Column(
                      children: [
                        if (task.description == 'Completed')
                          Text("Time Taken: ${ task.duration?.amount == 1 ? 'Less than 1' : task.duration?.amount} Min"),
                        if (task.description == 'In Progress')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Time: $timerText"),
                              // IconButton(
                              //   icon: const Icon(Icons.pause),
                              //   onPressed: () {
                              //     context
                              //         .read<TimerBloc>()
                              //         .add(StopTimerEvent());
                              //   },
                              // ),
                            ],
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
}
