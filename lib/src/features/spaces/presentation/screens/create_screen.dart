import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/models/submission_model.dart';
import 'package:rever/src/data/providers/submission_providers.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final profileId = ref.read(activeProfileIdProvider);
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a profile first')),
      );
      return;
    }
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title and article body')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(submissionRepositoryProvider).submit(profileId, title, body);
      _titleController.clear();
      _bodyController.clear();
      ref.invalidate(mySubmissionsProvider(profileId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitted for review')),
      );
    } catch (e) {
      debugPrint('[create] submit failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _withdraw(String id) async {
    final profileId = ref.read(activeProfileIdProvider);
    if (profileId == null) return;
    await ref.read(submissionRepositoryProvider).withdraw(id);
    ref.invalidate(mySubmissionsProvider(profileId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileId = ref.watch(activeProfileIdProvider);
    final submissionsAsync = profileId == null
        ? null
        : ref.watch(mySubmissionsProvider(profileId));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create', style: theme.textTheme.displayLarge),
              const SizedBox(height: 4),
              Text(
                'Publish your article or blog. Approved posts become '
                'community content for other learners.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. My notes on systems thinking',
                  prefixIcon: const Icon(Icons.title),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bodyController,
                minLines: 6,
                maxLines: 14,
                decoration: InputDecoration(
                  labelText: 'Article body',
                  hintText:
                      'Write or paste your article here...\n\n'
                      'Plain text or markdown.',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _submitting ? 'Submitting...' : 'Submit for Review',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text('My Submissions', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Approved posts are visible to other users. Pending posts '
                'can be withdrawn.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 12),
              if (submissionsAsync == null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Select a profile to see your submissions',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                )
              else
                submissionsAsync.when(
                  data: (submissions) {
                    if (submissions.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Nothing here yet — submit your first article above.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: submissions
                          .map(
                            (s) => _SubmissionTile(
                              submission: s,
                              onWithdraw: () => _withdraw(s.id),
                            ),
                          )
                          .toList(),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Could not load submissions',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmissionTile extends StatelessWidget {
  final SubmissionModel submission;
  final VoidCallback onWithdraw;

  const _SubmissionTile({
    required this.submission,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusColor, statusLabel) = switch (submission.status) {
      'approved' => (const Color(0xFF00C853), 'Approved'),
      'rejected' => (theme.colorScheme.error, 'Rejected'),
      _ => (Colors.amber.shade700, 'Pending review'),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    submission.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              submission.body,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (submission.isPending) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onWithdraw,
                  child: const Text('Withdraw'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/* ============================================================================
   DEFERRED — URL / YouTube / note extraction (NotebookLM-style one-shot
   distillation). Disabled by product decision until a reliable LLM API is
   available. Re-enable by restoring the tab UI and calling `_processSource`
   (git history: HEAD of this file). Keep `url_text_fetcher.dart` for the
   fetch step.

  Future<void> _processSource(String text) async { ... }  // LLM one-shot
  class _UrlTab / _NoteTab / _YoutubeTab / _ProcessingView / _ReviewBar
============================================================================ */
