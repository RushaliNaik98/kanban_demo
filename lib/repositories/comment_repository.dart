import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/comment.dart';

class CommentRepository {
  final String baseUrl;
  final String authToken;

  CommentRepository({required this.baseUrl, required this.authToken});

  Future<AddCommentResponse> addComment(AddCommentRequest request) async {
    final url = Uri.parse('$baseUrl/comments');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AddCommentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add comment: ${response.body}');
    }
  }

  Future<List<AddCommentResponse>> getComments({required String taskId}) async {
    final url = 'https://api.todoist.com/rest/v2/comments?task_id=$taskId';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => AddCommentResponse.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch comments");
    }
  }
}
