import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/data/models/explore_content_model.dart';
import 'package:rever/src/data/models/stash_card_model.dart';
import 'package:rever/src/data/services/external_content_service.dart';

class ContentReelScreen extends ConsumerStatefulWidget {
  final List<ExploreContent> items;
  final int initialIndex;

  const ContentReelScreen({
    super.key,
    required this.items,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<ContentReelScreen> createState() => _ContentReelScreenState();
}

class _ContentReelScreenState extends ConsumerState<ContentReelScreen> {
  late int _itemIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _itemIndex = widget.initialIndex;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToItem(int index) {
    if (index < 0 || index >= widget.items.length) return;
    setState(() {
      _itemIndex = index;
    });
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[_itemIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: _StashPageView(
        item: item,
        items: widget.items,
        onComplete: () {
          if (_itemIndex + 1 < widget.items.length) {
            _goToItem(_itemIndex + 1);
          } else {
            Navigator.pop(context);
          }
        },
        onClose: () => Navigator.pop(context),
        itemIndex: _itemIndex,
        totalItems: widget.items.length,
        onGoToItem: _goToItem,
      ),
    );
  }
}

class _StashPageView extends ConsumerStatefulWidget {
  final ExploreContent item;
  final VoidCallback onComplete;
  final VoidCallback onClose;
  final int itemIndex;
  final int totalItems;
  final void Function(int) onGoToItem;
  final List<ExploreContent> items;

  const _StashPageView({
    required this.item,
    required this.onComplete,
    required this.onClose,
    required this.itemIndex,
    required this.totalItems,
    required this.onGoToItem,
    required this.items,
  });

  @override
  ConsumerState<_StashPageView> createState() => _StashPageViewState();
}

class _StashPageViewState extends ConsumerState<_StashPageView> {
  late PageController _page;
  int _current = 0;
  List<StashCard> _stashes = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _page = PageController();
  }

  @override
  void didUpdateWidget(covariant _StashPageView old) {
    super.didUpdateWidget(old);
    if (old.item.id != widget.item.id) {
      _current = 0;
      _loaded = false;
      _page.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stashesAsync = ref.watch(contentStashesProvider(widget.item));

    return Stack(
      children: [
        stashesAsync.when(
          data: (stashes) {
            _stashes = stashes;
            if (!_loaded && stashes.isNotEmpty) {
              _loaded = true;
            }
            if (stashes.isEmpty) {
              return _buildEmptyFallback();
            }
            return PageView.builder(
              controller: _page,
              scrollDirection: Axis.vertical,
              itemCount: stashes.length + 1,
              onPageChanged: (i) {
                if (i == stashes.length) {
                  widget.onComplete();
                } else {
                  setState(() => _current = i);
                }
              },
              itemBuilder: (_, i) {
                if (i == stashes.length) {
                  return _buildNextUp();
                }
                return _StashSlide(
                  stash: stashes[i],
                  item: widget.item,
                  index: i,
                  total: stashes.length,
                  color: _colorFor(widget.item.source),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white54),
          ),
          error: (_, __) => _buildEmptyFallback(),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 0,
          right: 0,
          child: _ProgressBar(
            total: _stashes.length,
            current: _current,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: widget.onClose,
          ),
        ),
        if (widget.totalItems > 1)
          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            left: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department,
                          size: 14,
                          color: Colors.orangeAccent.withValues(alpha: 0.9)),
                      const SizedBox(width: 4),
                      Text(
                        '3 day streak',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.itemIndex + 1} of ${widget.totalItems}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories,
                size: 48,
                color: _colorFor(widget.item.source).withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              widget.item.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Loading insights...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextUp() {
    final isLast = widget.itemIndex + 1 >= widget.totalItems;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _colorFor(widget.item.source).withValues(alpha: 0.2),
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline,
                  size: 64,
                  color: _colorFor(widget.item.source).withValues(alpha: 0.7)),
              const SizedBox(height: 24),
              Text(
                'Well done!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ve finished this item',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 24),
              if (!isLast) ...[
                FilledButton.icon(
                  onPressed: () {
                    final next = widget.itemIndex + 1;
                    if (next < widget.totalItems) {
                      widget.onGoToItem(next);
                    }
                  },
                  icon: const Icon(Icons.arrow_downward),
                  label: Text(
                    'Next: ${widget.items[widget.itemIndex + 1].title}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _colorFor(widget.item.source).withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextButton(
                onPressed: widget.onClose,
                child: const Text('Back to Library',
                    style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorFor(ContentSource source) {
    return source == ContentSource.book ? Colors.amber : Colors.cyan;
  }
}

class _ProgressBar extends StatelessWidget {
  final int total;
  final int current;
  const _ProgressBar({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    if (total <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 12),
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i <= current
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.25),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StashSlide extends StatelessWidget {
  final StashCard stash;
  final ExploreContent item;
  final int index;
  final int total;
  final Color color;

  const _StashSlide({
    required this.stash,
    required this.item,
    required this.index,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isIdea = stash.type == StashType.idea;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.22),
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            if (item.thumbnailUrl != null)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.07,
                  child: Image.network(
                    item.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 60, 28, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StashBadge(
                        label: isIdea ? 'IDEA ${index}' : 'ABOUT',
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.sourceLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.45),
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stash.content,
                            style: isIdea
                                ? textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  )
                                : textTheme.titleLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    fontWeight: FontWeight.w400,
                                    height: 1.55,
                                  ),
                          ),
                          const SizedBox(height: 28),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: color.withValues(alpha: 0.5),
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: textTheme.titleSmall?.copyWith(
                                    color:
                                        Colors.white.withValues(alpha: 0.75),
                                    height: 1.3,
                                  ),
                                ),
                                if (item.author != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    item.author!,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: color.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0),
                      Colors.black,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ReactionButton(
                          icon: Icons.favorite_outline,
                          activeIcon: Icons.favorite,
                          label: 'Like',
                          color: Colors.redAccent,
                        ),
                        _ReactionButton(
                          icon: Icons.whatshot_outlined,
                          activeIcon: Icons.whatshot,
                          label: 'Mind Blown',
                          color: Colors.orangeAccent,
                        ),
                        _ReactionButton(
                          icon: Icons.lightbulb_outline,
                          activeIcon: Icons.lightbulb,
                          label: 'Useful',
                          color: Colors.amberAccent,
                        ),
                        _ActionButton(
                          icon: Icons.bookmark_outline,
                          label: 'Stash',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Icon(Icons.swipe_vertical,
                        size: 20,
                        color: Colors.white.withValues(alpha: 0.2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StashBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StashBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  const _ActionButton({required this.icon, required this.label});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1, end: 1.3).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _onTap() {
    _anim.forward().then((_) => _anim.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(widget.icon,
                  color: Colors.white.withValues(alpha: 0.7), size: 22),
            ),
            const SizedBox(height: 4),
            Text(widget.label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                )),
          ],
        ),
      ),
    );
  }
}

class _ReactionButton extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  const _ReactionButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });

  @override
  State<_ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<_ReactionButton>
    with SingleTickerProviderStateMixin {
  bool _active = false;
  int _count = 0;
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 1, end: 1.4).animate(
      CurvedAnimation(parent: _anim, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _onTap() {
    setState(() {
      _active = !_active;
      _count += _active ? 1 : -1;
    });
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _active
                    ? widget.color.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                _active ? widget.activeIcon : widget.icon,
                color: _active
                    ? widget.color
                    : Colors.white.withValues(alpha: 0.7),
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _count > 0 ? '$_count' : widget.label,
              style: TextStyle(
                color: _active
                    ? widget.color.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
                fontWeight: _active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
