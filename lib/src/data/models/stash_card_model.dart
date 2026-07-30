enum StashType { overview, idea, takeaway }

class StashCard {
  final String title;
  final String content;
  final StashType type;

  const StashCard({
    required this.title,
    required this.content,
    this.type = StashType.idea,
  });
}
