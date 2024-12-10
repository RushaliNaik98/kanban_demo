import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/comment_repository.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository commentRepository;

  CommentBloc({required this.commentRepository}) : super(CommentInitial()) {
    on<AddCommentEvent>(_onAddCommentEvent);
    on<FetchCommentsEvent>(_onFetchCommentsEvent);
    on<UpdateCommentEvent>(_onUpdateCommentEvent);
    on<DeleteCommentEvent>(_onDeleteCommentEvent);
  }

  // Add Comment Event Handler
  Future<void> _onAddCommentEvent(
      AddCommentEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoading());    try {
      final response = await commentRepository.addComment(event.request);
      emit(CommentSuccess(response: response));
      add(FetchCommentsEvent(taskId: event.request.taskId)); // Refresh comments
    } catch (error) {
      emit(CommentFailure(error: error.toString()));
    }
  }

  // Fetch Comments Event Handler
  Future<void> _onFetchCommentsEvent(
      FetchCommentsEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoading());
    try {
      final comments = await commentRepository.getComments(taskId: event.taskId);
      emit(CommentLoaded(comments: comments));
    } catch (error) {
      emit(CommentError(error: error.toString()));
    }
  }

  Future<void> _onUpdateCommentEvent(
    UpdateCommentEvent event, Emitter<CommentState> emit) async {
  emit(CommentLoading());
  try {
    await commentRepository.editComment(
      commentId: event.commentId, // Get commentId from event
      newContent: event.content,   // Get new content from event
    );
    add(FetchCommentsEvent(taskId: event.taskId)); // Refresh comments
  } catch (error) {
    emit(CommentError(error: error.toString()));
  }
}


  Future<void> _onDeleteCommentEvent(
    DeleteCommentEvent event, Emitter<CommentState> emit) async {
  emit(CommentLoading());
  try {
    await commentRepository.deleteComment(commentId: event.commentId); // Pass commentId
    add(FetchCommentsEvent(taskId: event.taskId)); // Refresh comments
  } catch (error) {
    emit(CommentError(error: error.toString()));
  }
}

}
