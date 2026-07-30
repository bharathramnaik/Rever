import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/providers/quote_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _GreetingHeader(),
            SliverToBoxAdapter(child: SizedBox(height: 8)),
            _QuoteCard(),
            SliverToBoxAdapter(child: SizedBox(height: 32)),
            _QuickActions(),
            SliverToBoxAdapter(child: SizedBox(height: 24)),
            _DailySection(),
            SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _GreetingHeader extends ConsumerWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';

    final profileAsync = ref.watch(activeProfileProvider);
    final name = profileAsync.when(
      data: (p) => p?.name ?? 'Learner',
      loading: () => 'Learner',
      error: (_, __) => 'Learner',
    );

    return SliverAppBar(
      floating: true,
      backgroundColor: theme.colorScheme.surface,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              )),
          const SizedBox(height: 2),
          Text(name, style: theme.textTheme.titleLarge),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => context.go('/profiles'),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuoteCard extends ConsumerStatefulWidget {
  const _QuoteCard();

  @override
  ConsumerState<_QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends ConsumerState<_QuoteCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quoteAsync = ref.watch(randomQuoteProvider);

    return quoteAsync.when(
      data: (quote) {
        if (quote == null) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onLongPressStart: (_) => setState(() => _expanded = true),
              onLongPressEnd: (_) => setState(() => _expanded = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.all(_expanded ? 28 : 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                      theme.colorScheme.secondary.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.format_quote,
                            color: theme.colorScheme.primary, size: 32),
                        const Spacer(),
                        if (!_expanded)
                          AnimatedOpacity(
                            opacity: _expanded ? 0 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.touch_app,
                                      size: 14,
                                      color: theme.colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text('Hold to read',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                              color:
                                                  theme.colorScheme.primary)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: _expanded
                          ? theme.textTheme.titleLarge!.copyWith(height: 1.5)
                          : theme.textTheme.headlineSmall!.copyWith(
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                      child: Text(
                        quote.text,
                        style: TextStyle(
                          color: _expanded
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedOpacity(
                      opacity: _expanded ? 1 : 0.7,
                      duration: const Duration(milliseconds: 200),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quote.author,
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                if (quote.source != null && _expanded)
                                  Text(
                                    quote.source!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (_expanded && quote.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                quote.category!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_expanded) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.refresh,
                              size: 14,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Text('Tap to refresh quote',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              )),
                          const Spacer(),
                          Icon(Icons.share_outlined,
                              size: 18,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4)),
                          const SizedBox(width: 16),
                          Icon(Icons.bookmark_outline,
                              size: 18,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(child: Text('$e')),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = [
      _ActionItem(
        icon: Icons.auto_stories,
        label: 'Learn',
        color: theme.colorScheme.primary,
        onTap: () => context.go('/learn'),
      ),
      _ActionItem(
        icon: Icons.explore,
        label: 'Explore',
        color: theme.colorScheme.secondary,
        onTap: () => context.go('/explore'),
      ),
      _ActionItem(
        icon: Icons.replay,
        label: 'Review',
        color: Colors.amber.shade600,
        onTap: () => context.go('/review'),
      ),
      _ActionItem(
        icon: Icons.auto_awesome,
        label: 'AI Tutor',
        color: const Color(0xFFE040FB),
        onTap: () => context.go('/ai-tutor'),
      ),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: actions.map((a) => _QuickActionButton(action: a)).toList(),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final _ActionItem action;
  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(action.icon, color: action.color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(action.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              )),
        ],
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _DailySection extends ConsumerWidget {
  const _DailySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text('Today',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_fire_department,
                        color: Colors.amber, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Streak',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(height: 2),
                        Text('Start your learning journey today',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            )),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.go('/learn'),
                    child: const Text('Begin'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
