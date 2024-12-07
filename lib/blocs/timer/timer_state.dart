import 'package:equatable/equatable.dart';

// TimerState
abstract class TimerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TimerInitial extends TimerState {}

class TimerRunning extends TimerState {
  final Duration elapsedTime;

  TimerRunning(this.elapsedTime);

  @override
  List<Object?> get props => [elapsedTime];
}

class TimerStopped extends TimerState {
  final Duration elapsedTime;

  TimerStopped(this.elapsedTime);

  @override
  List<Object?> get props => [elapsedTime];
}

class TimerReset extends TimerState {
  @override
  List<Object?> get props => [];
}
