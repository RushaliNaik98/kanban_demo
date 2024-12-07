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
