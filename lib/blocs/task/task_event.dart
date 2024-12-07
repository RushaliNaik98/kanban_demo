import 'package:equatable/equatable.dart';
import 'package:kanban_demo/models/task.dart';

// Abstract class that represents a task event
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class AddTaskEvent extends TaskEvent {
  final Task task;

  const AddTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];
}

// Event to fetch tasks from the repository
class FetchTasksEvent extends TaskEvent {}

// Event to update an existing task
class UpdateTaskEvent extends TaskEvent {
  final Task task;

  UpdateTaskEvent({required this.task});
}

// Event to delete a task
class DeleteTaskEvent extends TaskEvent {
  final int taskId;

  DeleteTaskEvent({required this.taskId});

  @override
  List<Object> get props => [taskId];
}

class MoveTaskEvent extends TaskEvent {
  final Task task;
  final String newStatus;  // New status to move the task to
  MoveTaskEvent({required this.task, required this.newStatus});
}
