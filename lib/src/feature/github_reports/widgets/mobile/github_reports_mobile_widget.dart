import 'package:control/Control.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:no_sleep/src/feature/github_reports/controller/github_reports_controller.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_available_labels_widget.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_reports_button_widget.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_reports_state_mixin.dart';

class GithubReportsMobileWidget extends StatefulWidget {
  const GithubReportsMobileWidget({super.key});

  @override
  State<GithubReportsMobileWidget> createState() => _GithubReportsMobileWidgetState();
}

class _GithubReportsMobileWidgetState extends State<GithubReportsMobileWidget>
    with GithubReportsStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0505),
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Row(
          children: [
            Icon(FontAwesomeIcons.github, color: Color(0xFFd41132), size: 20),
            SizedBox(width: 12),
            Text(
              'Report Issue',
              style: TextStyle(
                color: Color(0xFFd41132),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StateConsumer<GithubReportsController, GithubReportsState>(
            controller: githubReportsController,
            builder: (context, state, child) {
              return CustomScrollView(
                slivers: [
                  // Issue Title Section
                  SliverToBoxAdapter(child: buildSectionHeader('ISSUE TITLE', Icons.title)),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  SliverToBoxAdapter(
                    child: buildTextField(
                      controller: titleController,
                      hintText: 'Enter issue title...',
                      maxLines: 2,
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Issue Description Section
                  SliverToBoxAdapter(
                    child: buildSectionHeader('DESCRIPTION', Icons.description_outlined),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  SliverToBoxAdapter(
                    child: buildTextField(
                      controller: bodyController,
                      hintText: 'Describe the issue in detail...',
                      maxLines: 8,
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Labels Section
                  SliverToBoxAdapter(child: buildSectionHeader('LABELS', Icons.label_outline)),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  const SliverToBoxAdapter(child: GithubAvailableLabelsWidget()),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // Submit Button & Status
                  const SliverToBoxAdapter(child: GithubReportsButtonWidget()),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  SliverToBoxAdapter(child: buildStatusPanel(state)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
