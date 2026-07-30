class StashItem {
  final String stashId;
  final String ideaCardId;
  final DateTime addedAt;

  const StashItem({
    required this.stashId,
    required this.ideaCardId,
    required this.addedAt,
  });

  factory StashItem.fromJson(Map<String, dynamic> json) => StashItem(
        stashId: json['stash_id'] as String,
        ideaCardId: json['idea_card_id'] as String,
        addedAt: DateTime.parse(json['added_at'] as String),
      );
}
