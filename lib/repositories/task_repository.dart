import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // Import the HTTP package for making API requests
import 'package:kanban_demo/models/task.dart'; // Import the Task model

class TaskRepository {
  final String token = 'a084279cd597fd0465b02b64abc33568d17df13a';

  // Method to fetch all tasks from Todoist API
  Future<List<Task>> fetchTasks() async {
    debugPrint('im here1');
    final url = Uri.parse('https://api.todoist.com/rest/v2/tasks');

    final headers = {
      'Authorization': 'Bearer $token',
    };
    debugPrint('im here');
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((taskJson) => Task.fromJson(taskJson)).toList();
      } else {
        throw Exception('Failed to fetch tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  // Method to add a task to Todoist
  Future<Task> addTask(Task task) async {
    final url = Uri.parse('https://api.todoist.com/rest/v2/tasks');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = json.encode({
      'content': task.content,
      'description': task.description,
      'priority': task.priority,
      // Add any other parameters you want to send (e.g., due_date, etc.)
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final taskJson = json.decode(response.body);
        return Task.fromJson(taskJson);
      } else {
        throw Exception('Failed to add task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  // Method to update an existing task
  Future<Task> updateTask(Task task) async {
    final url = Uri.parse('https://api.todoist.com/rest/v2/tasks/${task.id}');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = json.encode({
      'content': task.content,
      'description': task.description,
      'priority': task.priority,
      'created_at': task.createdAt,
      'due_datetime': task.date,
      'duration': task.duration?.amount == 0 ? 1 : task.duration?.amount,
      'duration_unit': task.duration?.unit,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final taskJson = json.decode(response.body);
        return Task.fromJson(taskJson);
      } else {
        throw Exception('Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Method to delete a task
  Future<void> deleteTask(int taskId) async {
    final url = Uri.parse('https://api.todoist.com/rest/v2/tasks/$taskId');
    final headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode != 204) {
        throw Exception('Failed to delete comment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
