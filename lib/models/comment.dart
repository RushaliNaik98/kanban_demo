class AddCommentRequest {
  final String taskId;
  final String content;
  final Attachment? attachment;

  AddCommentRequest({
    required this.taskId,
    required this.content,
    this.attachment,
  });

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'content': content,
      if (attachment != null) 'attachment': attachment!.toJson(),
    };
  }
}

class Attachment {
  final String resourceType;
  final String fileUrl;
  final String fileType;
  final String fileName;

  Attachment({
    required this.resourceType,
    required this.fileUrl,
    required this.fileType,
    required this.fileName,
  });

  // Convert JSON to Attachment object
  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      resourceType: json['resource_type'] as String,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String,
      fileName: json['file_name'] as String,
    );
  }

  // Convert Attachment object to JSON
  Map<String, dynamic> toJson() {
    return {
      'resource_type': resourceType,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_name': fileName,
    };
  }
}


class AddCommentResponse {
  final String id;
  final String content;
  final String taskId;
  final String? projectId;
  final DateTime postedAt;
  final Attachment? attachment;

  AddCommentResponse({
    required this.id,
    required this.content,
    required this.taskId,
    this.projectId,
    required this.postedAt,
    this.attachment,
  });

  factory AddCommentResponse.fromJson(Map<String, dynamic> json) {
    return AddCommentResponse(
      id: json['id'],
      content: json['content'],
      taskId: json['task_id'],
      projectId: json['project_id'],
      postedAt: DateTime.parse(json['posted_at']),
      attachment: json['attachment'] != null
          ? Attachment.fromJson(json['attachment'])
          : null,
    );
  }
}