import 'package:control/Control.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:no_sleep/src/feature/github_reports/controller/github_reports_controller.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_reports_config_widget.dart';

class GithubReportsMobileWidget extends StatefulWidget {
  const GithubReportsMobileWidget({super.key});

  @override
  State<GithubReportsMobileWidget> createState() => _GithubReportsMobileWidgetState();
}

class _GithubReportsMobileWidgetState extends State<GithubReportsMobileWidget> {
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
          child: CustomScrollView(
            slivers: [
              // Issue Title Section
              SliverToBoxAdapter(child: _buildSectionHeader('ISSUE TITLE', Icons.title)),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              SliverToBoxAdapter(
                child: _buildTextField(
                  controller: _titleController,
                  hintText: 'Enter issue title...',
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
                  hintText: 'Describe the issue in detail...',
                  maxLines: 8,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Labels Section
              SliverToBoxAdapter(child: _buildSectionHeader('LABELS', Icons.label_outline)),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              SliverToBoxAdapter(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableLabels.map((label) {
                    final isSelected = _selectedLabels.contains(label);
                    return _buildLabelChip(label, isSelected);
                  }).toList(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Submit Button & Status
              StateConsumer<GithubReportsController, GithubReportsState>(
                controller: _githubReportsController,
                builder: (context, state, child) {
                  return SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
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
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'CREATING ISSUE...',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'CREATE ISSUE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Status Messages
                        if (state is GithubReports$ErrorState)
                          _buildStatusCard(
                            icon: Icons.error_outline,
                            title: 'ERROR',
                            message: state.message,
                            color: const Color(0xFFd41132),
                          )
                        else if (state is GithubReports$SuccessState)
                          _buildStatusCard(
                            icon: Icons.check_circle_outline,
                            title: 'SUCCESS',
                            message: 'Issue created: ${state.issue.title}',
                            color: const Color(0xFF32d456),
                            extraWidget: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: GestureDetector(
                                onTap: () {
                                  // Could add URL launcher here
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF32d456).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF32d456).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        FontAwesomeIcons.github,
                                        color: Color(0xFF32d456),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          state.issue.htmlUrl,
                                          style: const TextStyle(
                                            color: Color(0xFF32d456),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.open_in_new,
                                        color: Color(0xFF32d456),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.check, color: Color(0xFFd41132), size: 16),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFd41132) : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(fontSize: 14, color: Colors.grey[300], height: 1.4)),
          if (extraWidget != null) extraWidget,
        ],
      ),
    );
  }
}
