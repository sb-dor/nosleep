import 'package:control/Control.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:no_sleep/src/feature/github_reports/controller/github_reports_controller.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_available_labels_widget.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_reports_button_widget.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_reports_state_mixin.dart';

class GithubReportsTabletWidget extends StatefulWidget {
  const GithubReportsTabletWidget({super.key});

  @override
  State<GithubReportsTabletWidget> createState() => _GithubReportsTabletWidgetState();
}

class _GithubReportsTabletWidgetState extends State<GithubReportsTabletWidget>
    with GithubReportsStateMixin {
  @override
  Widget build(BuildContext context) {
    return StateConsumer<GithubReportsController, GithubReportsState>(
      controller: githubReportsController,
      builder: (context, state, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0a0505),
          appBar: AppBar(
            forceMaterialTransparency: true,
            title: const Row(
              children: [
                Icon(FontAwesomeIcons.github, color: Color(0xFFd41132), size: 24),
                SizedBox(width: 12),
                Text(
                  'Report Issue',
                  style: TextStyle(
                    color: Color(0xFFd41132),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side - Form
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        // Create New Issue Header
                        SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFd41132).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFd41132).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.bug_report_outlined,
                                  color: Color(0xFFd41132),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  'Create New Issue',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 32)),

                        // Issue Title Section
                        SliverToBoxAdapter(child: buildSectionHeader('ISSUE TITLE', Icons.title)),

                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                        SliverToBoxAdapter(
                          child: buildTextField(
                            controller: titleController,
                            hintText: 'Enter a descriptive title for the issue',
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
                            hintText: 'Provide detailed information about the issue...',
                            maxLines: 10,
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 24)),

                        // Labels Section
                        SliverToBoxAdapter(
                          child: buildSectionHeader('LABELS', Icons.label_outline),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                        const SliverToBoxAdapter(child: GithubAvailableLabelsWidget()),

                        const SliverToBoxAdapter(child: SizedBox(height: 32)),

                        // Submit Button
                        const SliverToBoxAdapter(child: GithubReportsButtonWidget()),
                      ],
                    ),
                  ),

                  const SizedBox(width: 32),

                  // Right Side - Status
                  SizedBox(width: 250, child: buildStatusPanel(state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
