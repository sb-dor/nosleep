import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:no_sleep/src/feature/github_reports/controller/github_reports_controller.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_reports_config_widget.dart';

mixin GithubReportsStateMixin<W extends StatefulWidget> on State<W> {
  late final _githubReportsInhWidget = GithubReportsConfigInhWidget.of(context);
  late final githubReportsController = _githubReportsInhWidget.githubReportsController;
  late final githubReportsDataController = _githubReportsInhWidget.githubReportsDataController;
  late final titleController = _githubReportsInhWidget.titleController;
  late final bodyController = _githubReportsInhWidget.bodyController;

  void submitIssue() {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a title for the issue'),
          backgroundColor: const Color(0xFFd41132),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    githubReportsController.createIssue(
      title: title,
      body: body,
      labels: githubReportsDataController.selectedLabels,
    );
  }

  Widget buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFd41132), size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget buildTextField({
    required final TextEditingController controller,
    required String hintText,
    required int maxLines,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFd41132).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset.zero,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget buildStatusPanel(final GithubReportsState state) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFd41132), size: 20),
                const SizedBox(width: 12),
                Text(
                  'STATUS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Content
          buildStatusContent(state),
        ],
      ),
    );
  }

  Widget buildStatusContent(GithubReportsState state) {
    if (state is GithubReports$InProgressState) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator.adaptive(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd41132)),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Creating issue...',
            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      );
    } else if (state is GithubReports$ErrorState) {
      return buildStatusCard(
        icon: Icons.error_outline,
        title: 'ERROR',
        message: state.message,
        color: const Color(0xFFd41132),
      );
    } else if (state is GithubReports$SuccessState) {
      return buildStatusCard(
        icon: Icons.check_circle_outline,
        title: 'SUCCESS',
        message: 'Issue created successfully:\n${state.issue.title}',
        color: const Color(0xFF32d456),
        extraWidget: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: GestureDetector(
            onTap: () {
              // Could add URL launcher here
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF32d456).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF32d456).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: .min,
                children: [
                  const Row(
                    children: [
                      Icon(FontAwesomeIcons.github, color: Color(0xFF32d456), size: 20),
                      SizedBox(width: 10),
                      Text(
                        'View on GitHub',
                        style: TextStyle(
                          color: Color(0xFF32d456),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.issue.htmlUrl,
                    style: const TextStyle(
                      color: Color(0xFF32d456),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Open in browser',
                        style: TextStyle(color: Color(0xFF32d456), fontSize: 12),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.open_in_new, color: Color(0xFF32d456), size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_document, color: Colors.grey[600], size: 64),
          const SizedBox(height: 24),
          Text(
            'Fill out the form\nto create a new issue.',
            style: TextStyle(color: Colors.grey[500], fontSize: 16, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildStatusCard({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
    Widget? extraWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color, letterSpacing: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(message, style: TextStyle(fontSize: 15, color: Colors.grey[300], height: 1.6)),
          if (extraWidget != null) extraWidget,
        ],
      ),
    );
  }
}
