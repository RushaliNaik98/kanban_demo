import 'package:equatable/equatable.dart';

// TimerEvent
abstract class TimerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartTimerEvent extends TimerEvent {
  final Duration initialElapsedTime;

  StartTimerEvent({required this.initialElapsedTime});
}

class StopTimerEvent extends TimerEvent {
  @override
  List<Object?> get props => [];
}

class ResetTimerEvent extends TimerEvent {
  @override
  List<Object?> get props => [];
}

class LoadTimerEvent extends TimerEvent {
  final String taskId;

  LoadTimerEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class UpdateTimerEvent extends TimerEvent {
  final Duration elapsedTime;

  UpdateTimerEvent(this.elapsedTime);

  @override
  List<Object?> get props => [elapsedTime];
}
