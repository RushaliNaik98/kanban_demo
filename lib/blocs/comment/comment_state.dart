import 'package:equatable/equatable.dart';
import 'package:kanban_demo/models/comment.dart';

abstract class CommentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

/// State when a comment is successfully added
class CommentSuccess extends CommentState {
  final AddCommentResponse response;

  CommentSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

/// State when fetching comments is successful
class CommentLoaded extends CommentState {
  final List<AddCommentResponse> comments;

  CommentLoaded({required this.comments});

  @override
  List<Object?> get props => [comments];
}

class CommentFailure extends CommentState {
  final String error;

  CommentFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

/// State when an error occurs while fetching comments
class CommentError extends CommentState {
  final String error;

  CommentError({required this.error});

  @override
  List<Object?> get props => [error];
}
