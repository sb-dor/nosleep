import 'package:control/Control.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:no_sleep/src/feature/github_reports/controller/github_reports_controller.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_reports_config_widget.dart';

class GithubReportsTabletWidget extends StatefulWidget {
  const GithubReportsTabletWidget({super.key});

  @override
  State<GithubReportsTabletWidget> createState() => _GithubReportsTabletWidgetState();
}

class _GithubReportsTabletWidgetState extends State<GithubReportsTabletWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final List<String> _availableLabels = ['bug', 'enhancement', 'documentation'];
  final List<String> _selectedLabels = [];

  late final _githubReportsInhWidget = GithubReportsConfigInhWidget.of(context);
  late final _githubReportsController = _githubReportsInhWidget.githubReportsController;
  late final _githubReportsDataController = _githubReportsInhWidget.githubReportsDataController;

  @override
  void initState() {
    super.initState();
    _githubReportsDataController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _githubReportsDataController.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {});
  }

  void _submitIssue() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

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

    _githubReportsDataController.setIsCreatingIssue(true);
    _githubReportsController.createIssue(title: title, body: body, labels: _selectedLabels);
  }

  @override
  Widget build(BuildContext context) {
    return StateConsumer<GithubReportsController, GithubReportsState>(
      controller: _githubReportsController,
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
                        SliverToBoxAdapter(child: _buildSectionHeader('ISSUE TITLE', Icons.title)),

                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                        SliverToBoxAdapter(
                          child: _buildTextField(
                            controller: _titleController,
                            hintText: 'Enter a descriptive title for the issue',
                            maxLines: 2,
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 24)),

                        // Issue Description Section
                        SliverToBoxAdapter(
                          child: _buildSectionHeader('DESCRIPTION', Icons.description_outlined),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                        SliverToBoxAdapter(
                          child: _buildTextField(
                            controller: _bodyController,
                            hintText: 'Provide detailed information about the issue...',
                            maxLines: 10,
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 24)),

                        // Labels Section
                        SliverToBoxAdapter(
                          child: _buildSectionHeader('LABELS', Icons.label_outline),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                        SliverToBoxAdapter(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _availableLabels.map((label) {
                              final isSelected = _selectedLabels.contains(label);
                              return _buildLabelChip(label, isSelected);
                            }).toList(),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 32)),

                        // Submit Button
                        SliverToBoxAdapter(
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  state is GithubReports$InProgressState ||
                                      state is GithubReports$SuccessState
                                  ? null
                                  : _submitIssue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFd41132),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey[800],
                                disabledForegroundColor: Colors.grey[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: state is GithubReports$InProgressState
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1.5,
                                      ),
                                    )
                                  : const Text(
                                      'CREATE ISSUE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 32),

                  // Right Side - Status
                  SizedBox(width: 250, child: _buildStatusPanel(state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFd41132), size: 18),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
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

  Widget _buildLabelChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedLabels.remove(label);
            _githubReportsDataController.removeLabel(label);
          } else {
            _selectedLabels.add(label);
            _githubReportsDataController.addLabel(label);
          }
        });
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

  Widget _buildStatusPanel(final GithubReportsState state) {
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
            padding: const EdgeInsets.all(4),
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
          _buildStatusContent(state),
        ],
      ),
    );
  }

  Widget _buildStatusContent(GithubReportsState state) {
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
      return _buildStatusCard(
        icon: Icons.error_outline,
        title: 'ERROR',
        message: state.message,
        color: const Color(0xFFd41132),
      );
    } else if (state is GithubReports$SuccessState) {
      return _buildStatusCard(
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

  Widget _buildStatusCard({
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
