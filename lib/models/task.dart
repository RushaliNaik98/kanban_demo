class Task {
  final String? id;
  final String? creatorId;
  final String? createdAt;
  final String content;
  final String? description;
  final bool? isCompleted;
  final int? priority;
  final String? assigneeId;
  final String? assignerId;
  final int? commentCount;
  final DurationModel? duration;
  final String? projectId;
  final String? sectionId;
  final String? parentId;
  final String? url;
  final Due? due; // Nested due object
  final List<String>? labels;
  final int? order;
  final String? date;
  final String? completedDate;

  Task({
    this.id,
    this.creatorId,
    this.createdAt,
    required this.content,
    this.description,
    this.isCompleted,
    this.priority,
    this.assigneeId,
    this.assignerId,
    this.commentCount,
    this.duration,
    this.projectId,
    this.sectionId,
    this.parentId,
    this.url,
    this.due,
    this.labels,
    this.order,
    this.date,
    this.completedDate,
  });

  // Factory constructor to create Task object from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String? ?? '', // Default to empty string
      creatorId: json['creator_id'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      content: json['content'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? false,
      priority: json['priority'] as int? ?? 0,
      assigneeId: json['assignee_id'] as String?,
      assignerId: json['assigner_id'] as String?,
      commentCount: json['comment_count'] as int? ?? 0,
      duration: json['duration'] != null
          ? DurationModel.fromJson(json['duration'])
          : null,
      projectId: json['project_id'] as String? ?? '',
      sectionId: json['section_id'] as String?,
      parentId: json['parent_id'] as String?,
      url: json['url'] as String? ?? '',
      due: json['due'] != null ? Due.fromJson(json['due']) : null,
      labels: (json['labels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      order: json['order'] as int? ?? 0,
      date: json['due_datetime'] as String? ?? '',
      completedDate: json['duration_unit'] as String? ?? '',
    );
  }

  // Converts Task object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'created_at': createdAt,
      'content': content,
      'description': description,
      'is_completed': isCompleted,
      'priority': priority,
      'assignee_id': assigneeId,
      'assigner_id': assignerId,
      'comment_count': commentCount,
      'duration': duration?.toJson(),
      'project_id': projectId,
      'section_id': sectionId,
      'parent_id': parentId,
      'url': url,
      'due': due?.toJson(),
      'labels': labels,
      'order': order,
      'date':date,
      'completedDate':completedDate
    };
  }
}

class Due {
  final String? date;
  final bool? isRecurring;
  final String? datetime;
  final String? string;
  final String? timezone;

  Due({
     this.date,
     this.isRecurring,
     this.datetime,
     this.string,
     this.timezone,
  });

  // Factory constructor to create Due object from JSON
  factory Due.fromJson(Map<String, dynamic> json) {
    return Due(
      date: json['date'] as String? ?? '', // Default to empty string
      isRecurring: json['is_recurring'] as bool? ?? false,
      datetime: json['datetime'] as String? ?? '',
      string: json['string'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
    );
  }

  // Converts Due object to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'is_recurring': isRecurring,
      'datetime': datetime,
      'string': string,
      'timezone': timezone,
    };
  }
}

class DurationModel {
  final int amount;
  final String unit;

  DurationModel({
    required this.amount,
    required this.unit,
  });

  // Factory constructor to create DurationModel object from JSON
  factory DurationModel.fromJson(Map<String, dynamic> json) {
    return DurationModel(
      amount: json['amount'] as int? ?? 0,
      unit: json['unit'] as String? ?? 'minute',
    );
  }

  // Converts DurationModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'unit': unit,
    };
  }
}