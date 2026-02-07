import 'package:control/Control.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:no_sleep/src/feature/github_reports/controller/github_reports_controller.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_available_labels_widget.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_reports_button_widget.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_reports_state_mixin.dart';

class GithubReportsDesktopWidget extends StatefulWidget {
  const GithubReportsDesktopWidget({super.key});

  @override
  State<GithubReportsDesktopWidget> createState() => _GithubReportsDesktopWidgetState();
}

class _GithubReportsDesktopWidgetState extends State<GithubReportsDesktopWidget>
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Row(
              children: [
                Icon(FontAwesomeIcons.github, color: Color(0xFFd41132), size: 28),
                SizedBox(width: 16),
                Text(
                  'Report Issue',
                  style: TextStyle(
                    color: Color(0xFFd41132),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Section - Left
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900]?.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFd41132).withValues(alpha: 0.2),
                            ),
                          ),
                          padding: const EdgeInsets.all(32),
                          child: CustomScrollView(
                            slivers: [
                              // Header
                              SliverToBoxAdapter(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFd41132).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFd41132).withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.bug_report_outlined,
                                        color: Color(0xFFd41132),
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    const Text(
                                      'Create New Issue',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SliverToBoxAdapter(child: SizedBox(height: 40)),

                              // Issue Title Section
                              SliverToBoxAdapter(
                                child: buildSectionHeader('ISSUE TITLE', Icons.title),
                              ),

                              const SliverToBoxAdapter(child: SizedBox(height: 16)),

                              SliverToBoxAdapter(
                                child: buildTextField(
                                  controller: titleController,
                                  hintText: 'Enter a descriptive title for the issue',
                                  maxLines: 2,
                                ),
                              ),

                              const SliverToBoxAdapter(child: SizedBox(height: 32)),

                              // Issue Description Section
                              SliverToBoxAdapter(
                                child: buildSectionHeader(
                                  'DESCRIPTION',
                                  Icons.description_outlined,
                                ),
                              ),

                              const SliverToBoxAdapter(child: SizedBox(height: 16)),

                              SliverToBoxAdapter(
                                child: buildTextField(
                                  controller: bodyController,
                                  hintText: 'Provide detailed information about the issue...',
                                  maxLines: 12,
                                ),
                              ),

                              const SliverToBoxAdapter(child: SizedBox(height: 32)),

                              // Labels Section
                              SliverToBoxAdapter(
                                child: buildSectionHeader('LABELS', Icons.label_outline),
                              ),

                              const SliverToBoxAdapter(child: SizedBox(height: 16)),

                              const SliverToBoxAdapter(child: GithubAvailableLabelsWidget()),

                              const SliverToBoxAdapter(child: SizedBox(height: 40)),

                              // Submit Button
                              const SliverToBoxAdapter(child: GithubReportsButtonWidget()),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 48),

                      // Status Section - Right
                      Expanded(child: buildStatusPanel(state)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
