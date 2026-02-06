import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:no_sleep/src/common/constant/config.dart';
import 'package:no_sleep/src/feature/github_reports/data/github_reports_repository.dart';
import 'package:no_sleep/src/feature/github_reports/models/github_issue.dart';

part 'github_reports_controller.freezed.dart';

@freezed
sealed class GithubReportsState with _$GithubReportsState {
  const factory GithubReportsState.initial() = GithubReports$InitialState;

  const factory GithubReportsState.inProgress() = GithubReports$InProgressState;

  const factory GithubReportsState.error(String message) = GithubReports$ErrorState;

  const factory GithubReportsState.success(GithubIssue issue) = GithubReports$SuccessState;
}

final class GithubReportsController extends StateController<GithubReportsState>
    with SequentialControllerHandler {
  GithubReportsController({
    required final IGithubReportsRepository githubReportsRepository,
    super.initialState = const GithubReportsState.initial(),
  }) : _iGithubReportsRepository = githubReportsRepository;

  final IGithubReportsRepository _iGithubReportsRepository;

  void createIssue({
    required String title,
    String? body,
    List<String>? assignees,
    List<String>? labels,
  }) => handle(() async {
    setState(const GithubReportsState.inProgress());

    final issue = await _iGithubReportsRepository.createIssue(
      title: title,
      body: body,
      assignees: assignees ?? [Config.githubOwner],
      // Default assignee
      labels: labels,
    );

    setState(GithubReportsState.success(issue));
  }, error: (error, stackTrace) async => setState(GithubReportsState.error(error.toString())));
}
