import 'package:flutter/foundation.dart';

@immutable
class GithubIssue {
  const GithubIssue({
    required this.id,
    required this.nodeId,
    required this.url,
    required this.repositoryUrl,
    required this.labelsUrl,
    required this.commentsUrl,
    required this.eventsUrl,
    required this.htmlUrl,
    required this.number,
    required this.state,
    required this.title,
    this.body,
    this.user,
    this.labels,
    this.assignee,
    this.assignees,
    this.milestone,
    required this.locked,
    this.activeLockReason,
    required this.comments,
    this.pullRequest,
    this.closedAt,
    required this.createdAt,
    required this.updatedAt,
    this.closedBy,
    required this.authorAssociation,
    this.stateReason,
  });

  factory GithubIssue.fromJson(final Map<String, Object?> json) {
    return GithubIssue(
      id: json['id'] as int,
      nodeId: json['node_id'] as String,
      url: json['url'] as String,
      repositoryUrl: json['repository_url'] as String,
      labelsUrl: json['labels_url'] as String,
      commentsUrl: json['comments_url'] as String,
      eventsUrl: json['events_url'] as String,
      htmlUrl: json['html_url'] as String,
      number: json['number'] as int,
      state: json['state'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      user: json['user'],
      labels: json['labels'] != null
          ? (json['labels'] as List<dynamic>).cast<dynamic>()
          : null,
      assignee: json['assignee'],
      assignees: json['assignees'] != null
          ? (json['assignees'] as List<dynamic>).cast<dynamic>()
          : null,
      milestone: json['milestone'],
      locked: json['locked'] as bool,
      activeLockReason: json['active_lock_reason'] as String?,
      comments: json['comments'] as int,
      pullRequest: json['pull_request'],
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      closedBy: json['closed_by'],
      authorAssociation: json['author_association'] as String,
      stateReason: json['state_reason'] as String?,
    );
  }

  final int id;
  final String nodeId;
  final String url;
  final String repositoryUrl;
  final String labelsUrl;
  final String commentsUrl;
  final String eventsUrl;
  final String htmlUrl;
  final int number;
  final String state;
  final String title;
  final String? body;
  final dynamic user;
  final List<dynamic>? labels;
  final dynamic assignee;
  final List<dynamic>? assignees;
  final dynamic milestone;
  final bool locked;
  final String? activeLockReason;
  final int comments;
  final dynamic pullRequest;
  final DateTime? closedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic closedBy;
  final String authorAssociation;
  final String? stateReason;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'node_id': nodeId,
      'url': url,
      'repository_url': repositoryUrl,
      'labels_url': labelsUrl,
      'comments_url': commentsUrl,
      'events_url': eventsUrl,
      'html_url': htmlUrl,
      'number': number,
      'state': state,
      'title': title,
      'body': body,
      'user': user,
      'labels': labels,
      'assignee': assignee,
      'assignees': assignees,
      'milestone': milestone,
      'locked': locked,
      'active_lock_reason': activeLockReason,
      'comments': comments,
      'pull_request': pullRequest,
      'closed_at': closedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'closed_by': closedBy,
      'author_association': authorAssociation,
      'state_reason': stateReason,
    };
  }

  GithubIssue copyWith({
    int? id,
    String? nodeId,
    String? url,
    String? repositoryUrl,
    String? labelsUrl,
    String? commentsUrl,
    String? eventsUrl,
    String? htmlUrl,
    int? number,
    String? state,
    String? title,
    ValueGetter<String?>? body,
    ValueGetter<dynamic>? user,
    ValueGetter<List<dynamic>?>? labels,
    ValueGetter<dynamic>? assignee,
    ValueGetter<List<dynamic>?>? assignees,
    ValueGetter<dynamic>? milestone,
    bool? locked,
    ValueGetter<String?>? activeLockReason,
    int? comments,
    ValueGetter<dynamic>? pullRequest,
    ValueGetter<DateTime?>? closedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    ValueGetter<dynamic>? closedBy,
    String? authorAssociation,
    ValueGetter<String?>? stateReason,
  }) {
    return GithubIssue(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      url: url ?? this.url,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      labelsUrl: labelsUrl ?? this.labelsUrl,
      commentsUrl: commentsUrl ?? this.commentsUrl,
      eventsUrl: eventsUrl ?? this.eventsUrl,
      htmlUrl: htmlUrl ?? this.htmlUrl,
      number: number ?? this.number,
      state: state ?? this.state,
      title: title ?? this.title,
      body: body != null ? body() : this.body,
      user: user != null ? user() : this.user,
      labels: labels != null ? labels() : this.labels,
      assignee: assignee != null ? assignee() : this.assignee,
      assignees: assignees != null ? assignees() : this.assignees,
      milestone: milestone != null ? milestone() : this.milestone,
      locked: locked ?? this.locked,
      activeLockReason: activeLockReason != null ? activeLockReason() : this.activeLockReason,
      comments: comments ?? this.comments,
      pullRequest: pullRequest != null ? pullRequest() : this.pullRequest,
      closedAt: closedAt != null ? closedAt() : this.closedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedBy: closedBy != null ? closedBy() : this.closedBy,
      authorAssociation: authorAssociation ?? this.authorAssociation,
      stateReason: stateReason != null ? stateReason() : this.stateReason,
    );
  }
}