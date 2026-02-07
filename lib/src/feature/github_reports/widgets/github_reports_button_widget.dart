import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/github_reports/controller/github_reports_controller.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_reports_state_mixin.dart';

class GithubReportsButtonWidget extends StatefulWidget {
  const GithubReportsButtonWidget({super.key});

  @override
  State<GithubReportsButtonWidget> createState() => _GithubReportsButtonWidgetState();
}

class _GithubReportsButtonWidgetState extends State<GithubReportsButtonWidget>
    with GithubReportsStateMixin {
  @override
  Widget build(BuildContext context) {
    return StateConsumer<GithubReportsController, GithubReportsState>(
      controller: githubReportsController,
      builder: (context, state, child) {
        return SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: state is GithubReports$InProgressState || state is GithubReports$SuccessState
                ? null
                : submitIssue,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFd41132),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[800],
              disabledForegroundColor: Colors.grey[600],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: state is GithubReports$InProgressState
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'CREATING ISSUE...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  )
                : state is GithubReports$SuccessState
                ? const Text(
                    'ISSUE CREATED',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5),
                  )
                : const Text(
                    'CREATE ISSUE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5),
                  ),
          ),
        );
      },
    );
  }
}
