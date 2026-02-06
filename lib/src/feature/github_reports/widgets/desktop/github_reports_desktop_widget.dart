import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/github_reports/controller/github_reports_controller.dart';
import 'package:no_sleep/src/feature/github_reports/widgets/github_reports_config_widget.dart';

class GithubReportsDesktopWidget extends StatefulWidget {
  const GithubReportsDesktopWidget({super.key});

  @override
  State<GithubReportsDesktopWidget> createState() => _GithubReportsDesktopWidgetState();
}

class _GithubReportsDesktopWidgetState extends State<GithubReportsDesktopWidget> {
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

    // Listen to data controller changes
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
    setState(() {
      // Update UI when data controller changes
    });
  }

  void _submitIssue() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title for the issue')));
      return;
    }

    _githubReportsDataController.setIsCreatingIssue(true);

    _githubReportsController.createIssue(title: title, body: body, labels: _selectedLabels);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _githubReportsDataController,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Report Issue'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form Section
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create New Issue',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Issue Title',
                              hintText: 'Enter a descriptive title for the issue',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _bodyController,
                            decoration: const InputDecoration(
                              labelText: 'Issue Description',
                              hintText: 'Provide detailed information about the issue...',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 10,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Labels',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            children: _availableLabels.map((label) {
                              final isSelected = _selectedLabels.contains(label);
                              return FilterChip(
                                label: Text(label),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedLabels.add(label);
                                    } else {
                                      _selectedLabels.remove(label);
                                    }
                                  });

                                  if (selected) {
                                    _githubReportsDataController.addLabel(label);
                                  } else {
                                    _githubReportsDataController.removeLabel(label);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: _githubReportsDataController.isCreatingIssue
                                  ? null
                                  : _submitIssue,
                              child: _githubReportsDataController.isCreatingIssue
                                  ? const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Creating...'),
                                      ],
                                    )
                                  : const Text('Create Issue'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Status Section
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          // Display status based on controller state
                          Expanded(
                            child: ValueListenableBuilder(
                              valueListenable: ValueNotifier(_githubReportsController.state),
                              builder: (context, state, child) {
                                if (state is GithubReports$InProgressState) {
                                  return const Center(child: CircularProgressIndicator.adaptive());
                                } else if (state is GithubReports$ErrorState) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Error',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(state.message),
                                      ],
                                    ),
                                  );
                                } else if (state is GithubReports$SuccessState) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.green),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Success!',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Issue created successfully: ${state.issue.title}'),
                                        const SizedBox(height: 8),
                                        SelectableText(
                                          'Issue URL: ${state.issue.htmlUrl}',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const Text('Fill out the form to create a new issue.');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
