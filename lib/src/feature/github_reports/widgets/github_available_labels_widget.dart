import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_reports_state_mixin.dart';

class GithubAvailableLabelsWidget extends StatefulWidget {
  const GithubAvailableLabelsWidget({super.key});

  @override
  State<GithubAvailableLabelsWidget> createState() => _GithubAvailableLabelsWidgetState();
}

class _GithubAvailableLabelsWidgetState extends State<GithubAvailableLabelsWidget>
    with GithubReportsStateMixin {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: githubReportsDataController,
      builder: (context, child) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: githubReportsDataController.availableLabels.map((label) {
            final isSelected = githubReportsDataController.selectedLabels.contains(label);
            return _buildLabelChip(label, isSelected);
          }).toList(),
        );
      },
    );
  }

  Widget _buildLabelChip(final String label, final bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          githubReportsDataController.removeLabel(label);
        } else {
          githubReportsDataController.addLabel(label);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFd41132).withValues(alpha: 0.2) : Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFd41132).withValues(alpha: 0.5)
                : const Color(0xFFd41132).withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.check, color: Color(0xFFd41132), size: 18),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFd41132) : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
