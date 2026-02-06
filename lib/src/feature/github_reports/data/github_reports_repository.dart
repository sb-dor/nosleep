import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:no_sleep/src/common/constant/config.dart';
import 'package:no_sleep/src/feature/github_reports/models/github_issue.dart';

abstract interface class IGithubReportsRepository {
  Future<GithubIssue> createIssue({
    required String title,
    String? body,
    List<String>? assignees,
    List<String>? labels,
  });
}

// Implementation
final class GithubReportsRepositoryImpl implements IGithubReportsRepository {
  GithubReportsRepositoryImpl({required final http.Client apiClient}) : _apiClient = apiClient;

  final http.Client _apiClient;

  @override
  Future<GithubIssue> createIssue({
    required String title,
    String? body,
    List<String>? assignees,
    List<String>? labels,
  }) async {
    final requestBody = {
      'title': title,
      if (body != null) 'body': body,
      if (assignees != null && assignees.isNotEmpty) 'assignees': assignees,
      if (labels != null && labels.isNotEmpty) 'labels': labels,
    };

    final response = await _apiClient.post(
      Uri.parse('https://api.github.com/repos/${Config.githubOwner}/${Config.githubRepo}/issues'),
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': 'Bearer ${Config.githubToken}',
        'X-GitHub-Api-Version': '2022-11-28',
      },
      body: jsonEncode(requestBody),
    );

    return GithubIssue.fromJson(jsonDecode(response.body) as Map<String, Object?>);
  }
}
