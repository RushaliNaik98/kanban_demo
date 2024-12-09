
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_demo/models/task.dart';
import 'package:kanban_demo/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;

  TaskBloc({required this.taskRepository}) : super(TaskInitial()) {
    on<FetchTasksEvent>(_mapFetchTasksToState);
    on<AddTaskEvent>(_mapAddTaskToState);
    on<UpdateTaskEvent>(_mapUpdateTaskToState);
    on<DeleteTaskEvent>(_mapDeleteTaskToState);
    on<MoveTaskEvent>(_mapMoveTaskToState);
  }

  // Event Handlers
  Future<void> _mapFetchTasksToState(
    FetchTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(TaskLoading());
      final tasks = await taskRepository.fetchTasks();
      emit(TaskLoaded(tasks: tasks));
    } catch (error, stackTrace) {
      print("Error in _mapFetchTasksToState: $error");
      print("Stack trace: $stackTrace");
      emit(const TaskError(message: "Failed to load tasks"));
    }
  }

  Future<void> _mapAddTaskToState(
      AddTaskEvent event, Emitter<TaskState> emit) async {
    try {
      // Call the addTask API to add the task to the backend
      final addedTask = await taskRepository.addTask(event.task);

      final currentState = state;

      if (currentState is TaskLoaded) {
        // Update the task list with the newly added task
        final updatedTasks = List<Task>.from(currentState.tasks)
          ..add(addedTask);

        // // Emit the updated task list
        // emit(TaskLoaded(tasks: updatedTasks));
        emit(TaskLoading());

        // Emit TaskAdded state to show success
        // emit(TaskAdded(task: addedTask));
        final tasks = await taskRepository.fetchTasks();
        emit(TaskLoaded(tasks: tasks));
      }
    } catch (error) {
      print("Error in _mapAddTaskToState: $error");
      emit(TaskError(message: "Failed to add task: $error"));
    }
  }

  Future<void> _mapUpdateTaskToState(
    UpdateTaskEvent event, Emitter<TaskState> emit) async {
  try {
    print("Entered _mapUpdateTaskToState with task: ${event.task.content}");

    // Emit loading state
    emit(TaskLoading());

    // Call the updateTask API to update the task in the backend
    final updatedTask = await taskRepository.updateTask(event.task);
    print("Task successfully updated in backend: ${updatedTask.content}");

    // Emit TaskUpdated to signal the update was successful
    // emit(TaskUpdated(task: updatedTask));

    // Fetch the latest tasks list
    final tasks = await taskRepository.fetchTasks();
    print("Fetched updated tasks list: ${tasks.map((task) => task.content).toList()}");

    // Emit TaskLoaded with the updated tasks list
    emit(TaskLoaded(tasks: tasks));
  } catch (error, stackTrace) {
    print("Error in _mapUpdateTaskToState: $error");
    print("Stack trace: $stackTrace");

    // Emit error state with a message
    emit(TaskError(message: "Failed to update task: $error"));
  }
}


  Future<void> _mapDeleteTaskToState(
      DeleteTaskEvent event, Emitter<TaskState> emit) async {
    try {
      emit(TaskLoading());
      await taskRepository.deleteTask(event.taskId);
      emit(TaskDeleted(taskId: event.taskId));
      add(FetchTasksEvent());
    } catch (_) {
      emit(TaskError(message: "Failed to delete task"));
    }
  }

  Future<void> _mapMoveTaskToState(
      MoveTaskEvent event, Emitter<TaskState> emit) async {
    try {
      emit(TaskLoading());
      final task = event.task;
      // task.parentId = event.newStatus;
      final updatedTask = await taskRepository.updateTask(task);
      emit(TaskUpdated(task: updatedTask));
    } catch (_) {
      emit(TaskError(message: "Failed to move task"));
    }
  }
}
