import 'package:equatable/equatable.dart';
import 'package:kanban_demo/models/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;

  const TaskLoaded({required this.tasks});

  @override
  List<Object?> get props => [tasks]; // Ensure tasks are part of equality checks
}

class TaskAdded extends TaskState {
  final Task task;

  const TaskAdded({required this.task});

  @override
  List<Object?> get props => [task]; // Ensure task is part of equality checks
}

class TaskUpdated extends TaskState {
  final Task task;

  const TaskUpdated({required this.task});

  @override
  List<Object?> get props => [task]; // Ensure task is part of equality checks
}

class TaskDeleted extends TaskState {
  final int taskId;

  const TaskDeleted({required this.taskId});

  @override
  List<Object?> get props => [taskId]; // Ensure taskId is part of equality checks
}

class TaskError extends TaskState {
  final String message;

  const TaskError({required this.message});

  @override
  List<Object?> get props => [message]; // Ensure message is part of equality checks
}
