import 'package:equatable/equatable.dart';
import 'package:kanban_demo/models/comment.dart';

abstract class CommentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddCommentEvent extends CommentEvent {
  final AddCommentRequest request;

  AddCommentEvent({required this.request});

  @override
  List<Object?> get props => [request];
}

class FetchCommentsEvent extends CommentEvent {
  final String taskId;

  FetchCommentsEvent({required this.taskId});
}

class UpdateCommentEvent extends CommentEvent {
  final String commentId;
  final String content; // Updated content
  final String taskId;

  UpdateCommentEvent({
    required this.commentId,
    required this.content,
    required this.taskId,
  });

  @override
  List<Object?> get props => [commentId, content, taskId];
}

class DeleteCommentEvent extends CommentEvent {
  final String commentId;
  final String taskId;

  DeleteCommentEvent({
    required this.commentId,
    required this.taskId,
  });

  @override
  List<Object?> get props => [commentId, taskId];
}