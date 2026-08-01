import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/models/preferences_model.dart';
import 'package:rever/src/data/providers/preferences_provider.dart';

class PreferenceQuizScreen extends ConsumerStatefulWidget {
  final bool force;

  const PreferenceQuizScreen({super.key, this.force = false});

  @override
  ConsumerState<PreferenceQuizScreen> createState() =>
      _PreferenceQuizScreenState();
}

class _PreferenceQuizScreenState extends ConsumerState<PreferenceQuizScreen> {
  late final PageController _page;
  int _step = 0;

  final Set<String> _topics = {};
  String? _goal;
  String? _style;
  int _ideaGoal = 5;

  @override
  void initState() {
    super.initState();
    _page = PageController();
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  bool get _currentAnswered => switch (_step) {
        0 => _topics.isNotEmpty,
        1 => _goal != null,
        2 => _style != null,
        _ => true,
      };

  Future<void> _save({required bool skip}) async {
    final profileId = ref.read(activeProfileIdProvider);
    if (profileId == null) {
      context.go('/profiles');
      return;
    }
    final prefs = PreferencesModel(
      profileId: profileId,
      topics: skip ? const [] : _topics.toList(),
      goal: skip ? '' : _goal ?? '',
      learningStyle: skip ? '' : _style ?? '',
      dailyGoalIdeas: skip ? 3 : _ideaGoal,
    );
    await ref.read(preferenceRepositoryProvider).save(prefs);
    ref.invalidate(preferencesProvider(profileId));
    if (mounted) context.go('/home');
  }

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
      _page.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _save(skip: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileId = ref.watch(activeProfileIdProvider);
    final prefsAsync =
        ref.watch(preferencesProvider(profileId ?? ''));

    prefsAsync.whenData((prefs) {
      if (prefs != null && !widget.force && profileId != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/home');
        });
      }
    });

    if (profileId == null) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/profiles'),
            child: const Text('Select a profile'),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (_step + 1) / 4,
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _save(skip: true),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _TopicQuestion(
                    selected: _topics,
                    onToggle: (t) => setState(() {
                      _topics.contains(t) ? _topics.remove(t) : _topics.add(t);
                    }),
                  ),
                  _SingleQuestion(
                    title: 'What\'s your main goal?',
                    subtitle: 'Pick one that fits best today',
                    options: kGoalOptions,
                    icons: const [
                      Icons.work_outline,
                      Icons.auto_awesome,
                      Icons.school_outlined,
                      Icons.lightbulb_outline,
                      Icons.explore_outlined,
                    ],
                    selected: _goal,
                    onSelect: (v) => setState(() => _goal = v),
                  ),
                  _SingleQuestion(
                    title: 'How do you like to learn?',
                    subtitle: 'We\'ll shape your daily feed around this',
                    options: kStyleOptions,
                    icons: const [
                      Icons.bolt_outlined,
                      Icons.menu_book_outlined,
                      Icons.hub_outlined,
                    ],
                    selected: _style,
                    onSelect: (v) => setState(() => _style = v),
                  ),
                  _IdeaGoalQuestion(
                    selected: _ideaGoal,
                    onSelect: (v) => setState(() => _ideaGoal = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _currentAnswered ? _next : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: Text(_step == 3 ? 'Start learning' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicQuestion extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _TopicQuestion({required this.selected, required this.onToggle});

  static const _icons = <String, IconData>{
    'Psychology': Icons.psychology,
    'Business & Money': Icons.trending_up,
    'Science': Icons.science,
    'Technology': Icons.memory,
    'Philosophy': Icons.self_improvement,
    'Health': Icons.favorite_outline,
    'History': Icons.history_edu,
    'Art & Design': Icons.palette_outlined,
    'Productivity': Icons.task_alt,
    'Personal Growth': Icons.eco,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What are you most interested in?',
              style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Choose as many as you like — we\'ll use these to pick your books',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 28),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: kTopicOptions.map((topic) {
                  final isSelected = selected.contains(topic);
                  return GestureDetector(
                    onTap: () => onToggle(topic),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _icons[topic],
                            size: 18,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            topic,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleQuestion extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final List<IconData> icons;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _SingleQuestion({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.icons,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 28),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...List.generate(options.length, (i) {
                    final isSelected = selected == options[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => onSelect(options[i]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 18),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                icons[i],
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  options[i],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle,
                                    color: theme.colorScheme.primary),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdeaGoalQuestion extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _IdeaGoalQuestion({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How many ideas a day?',
              style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Small daily wins compound into big knowledge',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 28),
          Expanded(
            child: SingleChildScrollView(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: kIdeaGoals.map((goal) {
                  final isSelected = selected == goal;
                  return GestureDetector(
                    onTap: () => onSelect(goal),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$goal',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal == 3
                                ? 'Light'
                                : goal == 5
                                    ? 'Balanced'
                                    : goal == 10
                                        ? 'Ambitious'
                                        : 'Intense',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
