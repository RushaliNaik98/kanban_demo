import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/comment_repository.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository commentRepository;

  CommentBloc({required this.commentRepository}) : super(CommentInitial()) {
    on<AddCommentEvent>(_onAddCommentEvent);
    on<FetchCommentsEvent>(_onFetchComments);
  }

  Future<void> _onAddCommentEvent(
      AddCommentEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoading());

    try {
      final response = await commentRepository.addComment(event.request);
      emit(CommentSuccess(response: response));
    } catch (error) {
      emit(CommentFailure(error: error.toString()));
    }
  }

  Future<void> _onFetchComments(
      FetchCommentsEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoading());
    try {
      final comments = await commentRepository.getComments(taskId: event.taskId);
      emit(CommentLoaded(comments: comments));
    } catch (e) {
      emit(CommentError(error: e.toString()));
    }
  }
}


